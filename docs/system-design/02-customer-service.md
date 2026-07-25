# 系统设计：设计智能客服系统

## 1. 需求澄清

### 功能需求
- 用户输入问题，系统自动回答
- 支持 FAQ 检索、知识库检索、多轮对话
- 支持转人工
- 支持订单查询、退款等工具调用

### 非功能需求
- **响应时间**：< 2 秒
- **解决率**：> 70%（不转人工）
- **可用性**：99.95%
- **并发**：10K QPS

### 规模估算
| 指标 | 数值 |
|------|------|
| 日咨询量 | 100 万 |
| 平均对话轮次 | 5 |
| 知识库文档 | 10 万篇 |
| FAQ | 1 万条 |

---

## 2. 高层架构图

```
┌─────────────────────────────────────────────────────────────────┐
│                         用户入口                                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │ Web Chat │  │ App SDK  │  │  微信    │  │  电话    │        │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘        │
└───────┼─────────────┼─────────────┼─────────────┼───────────────┘
        │             │             │             │
        └─────────────┴──────┬──────┴─────────────┘
                             │
                    ┌────────▼────────┐
                    │   API Gateway   │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
     ┌────────▼────────┐    │    ┌────────▼────────┐
     │  意图识别       │    │    │  会话管理       │
     │  (NLU)          │    │    │  (Redis)        │
     └────────┬────────┘    │    └────────┬────────┘
              │              │             │
              │    ┌─────────▼─────────┐  │
              │    │   Router          │  │
              │    │  (路由分发)        │  │
              │    └─────────┬─────────┘  │
              │              │             │
     ┌────────▼──────────────▼─────────────▼────────┐
     │              处理层                           │
     │  ┌──────────┐ ┌──────────┐ ┌──────────┐     │
     │  │ FAQ      │ │ RAG      │ │ Agent    │     │
     │  │ 检索     │ │ Pipeline │ │ 工具调用 │     │
     │  └──────────┘ └──────────┘ └──────────┘     │
     └──────────────────────────────────────────────┘
                             │
                    ┌────────▼────────┐
                    │  兜底策略       │
                    │  (转人工/拒绝)  │
                    └─────────────────┘
```

---

## 3. 核心模块详解

### 3.1 意图识别（NLU）

**职责**：理解用户意图，路由到不同处理流

**技术选型**：
| 方案 | 准确率 | 延迟 | 成本 | 选择 |
|------|--------|------|------|------|
| BERT 分类 | 92% | 50ms | 低 | ✅ |
| LLM 分类 | 95% | 500ms | 高 | 复杂场景 |
| 规则引擎 | 70% | 5ms | 极低 | 兜底 |

**意图分类**：
```
├── 咨询类 → FAQ 检索
├── 操作类 → Agent 工具调用
├── 投诉类 → 转人工
└── 闲聊类 → LLM 生成
```

### 3.2 FAQ 检索

**流程**：
```
用户问题 → Embedding → 向量检索 → 重排序 → Top-3 FAQ
                                              │
                                         置信度 > 0.85?
                                         ├── 是 → 直接返回答案
                                         └── 否 → 转 RAG
```

**Embedding 模型**：BGE-large-zh-v1.5（中文最强）

### 3.3 RAG Pipeline

**文档处理**：
- 解析：PDF/HTML/Word → 纯文本
- 分块：递归分块 512 tokens + 50 overlap
- 索引：Milvus 向量数据库

**检索策略**：
- 混合检索：BM25 + 向量 → RRF 融合
- 重排序：BGE-Reranker-v2-m3
- 过滤：按业务类型/时间过滤

**生成策略**：
- Prompt：Context + Question + 约束
- 引用：标注答案来源文档
- 拒答：无相关信息时诚实拒绝

### 3.4 Agent 工具调用

**工具列表**：
```python
tools = [
    {
        "name": "query_order",
        "description": "查询订单状态",
        "parameters": {"order_id": "string"}
    },
    {
        "name": "request_refund",
        "description": "申请退款",
        "parameters": {"order_id": "string", "reason": "string"}
    },
    {
        "name": "get_user_info",
        "description": "获取用户信息",
        "parameters": {"user_id": "string"}
    }
]
```

**安全控制**：
- 敏感操作需用户确认
- 退款等操作需二次验证
- 所有操作记录审计日志

### 3.5 兜底策略

**置信度分级**：
```
> 0.9：直接回复
0.7-0.9：回复 + "如果没解决请转人工"
0.5-0.7：提供选项 + 转人工入口
< 0.5：直接转人工
```

**转人工策略**：
- 用户主动请求
- 连续 3 次未解决
- 投诉/负面情绪检测
- 高价值用户优先

---

## 4. 数据库 Schema

```sql
-- 知识库文档表
CREATE TABLE knowledge_docs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  category VARCHAR(100),
  tags TEXT[],
  embedding vector(1024),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- FAQ 表
CREATE TABLE faqs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question TEXT NOT NULL,
  answer TEXT NOT NULL,
  embedding vector(1024),
  category VARCHAR(100),
  hit_count INT DEFAULT 0
);

-- 对话表
CREATE TABLE cs_conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID,
  status VARCHAR(20) DEFAULT 'bot', -- bot/transfer/handled
  satisfaction INT, -- 1-5 评分
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 消息表
CREATE TABLE cs_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID REFERENCES cs_conversations(id),
  role VARCHAR(10),
  content TEXT,
  source VARCHAR(20), -- faq/rag/agent/human
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 索引
CREATE INDEX idx_faq_embedding ON faqs USING ivfflat (embedding vector_cosine_ops);
CREATE INDEX idx_docs_embedding ON knowledge_docs USING ivfflat (embedding vector_cosine_ops);
CREATE INDEX idx_conv_user ON cs_conversations(user_id, created_at DESC);
```

---

## 5. Trade-off 讨论

### Trade-off 1：FAQ vs RAG 优先
| | FAQ 优先 | RAG 优先 |
|---|---|---|
| 准确率 | 高（已知问题） | 中（依赖检索） |
| 延迟 | 低 | 高 |
| 覆盖 | 有限 | 广 |

**选择 FAQ 优先**：80% 问题是重复的，FAQ 更快更准。

### Trade-off 2：转人工阈值
| | 高阈值（少转） | 低阈值（多转） |
|---|---|---|
| 成本 | 低 | 高 |
| 满意度 | 可能低 | 高 |
| 解决率 | 可能低 | 高 |

**选择动态阈值**：根据问题复杂度、用户价值动态调整。

---

## 6. 高频追问

### Q1: 如何评估智能客服效果？
- **解决率**：不转人工就解决问题的比例
- **满意度**：用户评分（1-5）
- **平均处理时间**：从开始到解决的时间
- **转人工率**：转人工的比例（目标 < 30%）

### Q2: 知识库更新频率？
- 实时更新：FAQ 立即生效
- 每日增量：新增文档每日索引
- 每周全量：全量重建索引

### Q3: 多语言支持？
- 意图识别：多语言 BERT
- 检索：多语言 Embedding（BGE-m3）
- 生成：LLM 多语言能力
