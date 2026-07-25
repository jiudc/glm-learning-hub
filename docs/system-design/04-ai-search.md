# 系统设计：设计 AI 搜索

## 1. 需求澄清

### 功能需求
- 用户输入 Query，返回 AI 生成的摘要答案
- 支持多源检索（Web、知识库、实时数据）
- 支持引用溯源
- 支持多轮对话式搜索

### 非功能需求
- **响应时间**：< 3 秒
- **准确率**：摘要事实准确 > 95%
- **并发**：50K QPS

### 规模估算
| 指标 | 数值 |
|------|------|
| 日搜索量 | 1 亿 |
| 平均 Query 长度 | 4 个词 |
| 索引页面 | 100 亿 |
| 日均新增 | 1000 万 |

---

## 2. 高层架构图

```
┌─────────────────────────────────────────────────────────────────┐
│                         用户入口                                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                      │
│  │ Web      │  │ App      │  │ API      │                      │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘                      │
└───────┼─────────────┼─────────────┼─────────────────────────────┘
        │             │             │
        └─────────────┴──────┬──────┘
                             │
                    ┌────────▼────────┐
                    │   API Gateway   │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
     ┌────────▼────────┐    │    ┌────────▼────────┐
     │  Query          │    │    │   Cache         │
     │  Understanding  │    │    │   (Redis)       │
     └────────┬────────┘    │    └────────┬────────┘
              │              │             │
              │    ┌─────────▼─────────┐  │
              │    │   Multi-Source    │  │
              │    │   Retrieval       │  │
              │    └─────────┬─────────┘  │
              │              │             │
     ┌────────▼──────────────▼─────────────▼────────┐
     │              检索层                           │
     │  ┌──────────┐ ┌──────────┐ ┌──────────┐     │
     │  │ Web      │ │ RAG      │ │ Realtime │     │
     │  │ Search   │ │ Pipeline │ │ API      │     │
     │  └──────────┘ └──────────┘ └──────────┘     │
     └──────────────────────────────────────────────┘
                             │
                    ┌────────▼────────┐
                    │  Re-ranking     │
                    │  + LLM 摘要     │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │  输出 + 引用    │
                    └─────────────────┘
```

---

## 3. 核心模块详解

### 3.1 Query 理解

**处理流程**：
```
原始 Query → 拼写纠错 → 意图识别 → Query 改写 → 扩展 Query
```

**意图分类**：
- 导航类：直接返回官网
- 信息类：需要综合多源
- 事务类：需要实时数据
- 对话类：多轮搜索

**Query 改写**：
- HyDE：生成假答案再检索
- Query Expansion：添加同义词
- Multi-query：拆分子问题

### 3.2 多源检索

| 数据源 | 技术 | 延迟 | 覆盖 |
|--------|------|------|------|
| Web | Search API（Google/Bing） | 200ms | 广 |
| 知识库 | Milvus 向量检索 | 100ms | 中 |
| 实时数据 | API 调用 | 500ms | 精准 |
| 自有索引 | Elasticsearch | 50ms | 可控 |

**融合策略**：
- RRF（Reciprocal Rank Fusion）
- 加权融合：`score = α*web + β*rag + γ*realtime`
- 时效性加权：新内容权重更高

### 3.3 Re-ranking

**重排序模型**：
- Cross-Encoder（BGE-Reranker-v2-m3）
- LLM 重排：让 LLM 判断相关性
- 多维度：相关性 + 时效性 + 权威性

### 3.4 LLM 摘要

**Prompt 设计**：
```
System: 你是一个搜索助手。基于以下搜索结果，生成简洁准确的答案。
要求：
1. 综合多个来源
2. 标注引用来源 [1][2]
3. 不确定的信息标注"可能"
4. 无相关信息时诚实说明

Context:
[1] {result1}
[2] {result2}
...

Question: {query}
```

**输出格式**：
```
## 答案
{summary}

## 引用
[1] {title} - {url}
[2] {title} - {url}

## 相关问题
- {related1}
- {related2}
```

---

## 4. 数据库 Schema

```sql
-- 搜索日志
CREATE TABLE search_logs (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID,
  query TEXT NOT NULL,
  results JSONB,
  latency_ms INT,
  source VARCHAR(20), -- web/rag/realtime
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 网页索引
CREATE TABLE web_index (
  id BIGSERIAL PRIMARY KEY,
  url TEXT UNIQUE NOT NULL,
  title TEXT,
  content TEXT,
  embedding vector(1024),
  pagerank FLOAT,
  last_crawled TIMESTAMPTZ
);

-- 缓存
CREATE TABLE search_cache (
  query_hash VARCHAR(64) PRIMARY KEY,
  results JSONB,
  expires_at TIMESTAMPTZ
);

-- 索引
CREATE INDEX idx_search_user ON search_logs(user_id, created_at DESC);
CREATE INDEX idx_web_embedding ON web_index USING ivfflat (embedding vector_cosine_ops);
CREATE INDEX idx_cache_expires ON search_cache(expires_at);
```

---

## 5. Trade-off 讨论

### Trade-off 1：实时性 vs 性能
| | 实时检索 | 缓存优先 |
|---|---|---|
| 新鲜度 | 高 | 低 |
| 延迟 | 高 | 低 |
| 成本 | 高 | 低 |

**选择混合**：热门 Query 缓存，长尾 Query 实时检索。

### Trade-off 2：摘要长度
| | 短摘要 | 长摘要 |
|---|---|---|
| 用户体验 | 快 | 全面 |
| 幻觉风险 | 低 | 高 |
| Token 成本 | 低 | 高 |

**选择动态**：根据 Query 复杂度动态调整摘要长度。

---

## 6. 高频追问

### Q1: 如何处理虚假信息？
1. 多源交叉验证
2. 权威性加权（权威站点权重高）
3. 事实核查（调用事实核查 API）
4. 不确定性标注

### Q2: 如何优化成本？
1. 缓存热门 Query（80% 请求命中缓存）
2. 分级模型：简单 Query 用小模型
3. 索引分层：热数据 SSD，冷数据 HDD
4. 批处理：非实时请求批量处理

### Q3: 与传统搜索的区别？
1. 理解语义（不仅是关键词）
2. 综合多源生成摘要
3. 支持对话式搜索
4. 支持复杂问题推理
