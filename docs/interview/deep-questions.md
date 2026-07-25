# 深度面试题合集（29道）

## 目录
1. [系统设计（5题）](#系统设计)
2. [RAG 专项（5题）](#rag-专项)
3. [Agent 专项（5题）](#agent-专项)
4. [部署与运维（4题）](#部署与运维)
5. [项目深挖（5题）](#项目深挖)
6. [编码与算法（3题）](#编码与算法)
7. [行为面试（2题）](#行为面试)

---

## 系统设计

### S1: 设计 ChatGPT 类对话系统

**考察点**：流式输出、上下文管理、高可用、成本控制

**答题框架**：
```
1. 需求澄清：功能/非功能/规模
2. 架构图：Client → Gateway → Session → LLM
3. 核心模块：流式输出、上下文管理、会话存储、推理服务
4. 数据库 Schema
5. API 设计
6. Trade-off：SSE vs WebSocket、滑动窗口 vs 摘要压缩
7. 扩展性：水平扩展、多区域、降级
```

**标准答案**：

#### 流式输出
- SSE（Server-Sent Events）实现打字机效果
- 背压控制：客户端消费慢时降速
- 断线重连：sequence number 续传

#### 上下文窗口管理
- 滑动窗口：保留最近 N 轮
- 摘要压缩：旧对话生成摘要
- Token 计数：tiktoken 精确计算

#### 会话存储
- Redis：热数据（活跃会话），TTL 30min
- PostgreSQL：冷数据（历史持久化）

#### LLM 推理
- vLLM + PagedAttention（显存利用率 40%→95%）
- 连续批处理（吞吐 2-4x）
- 模型路由：简单→小模型，复杂→大模型

#### Trade-off
| 决策 | 选择 | 原因 |
|------|------|------|
| 流式协议 | SSE | 简单、自动重连 |
| 上下文策略 | 混合 | 短对话窗口+长对话摘要 |
| 模型部署 | 混合 | 核心自研+兜底API |

#### 追问
1. 流量增加10倍？→ 水平扩展 + 降级
2. 如何控制成本？→ 模型路由 + 缓存 + 批处理
3. 上下文溢出？→ 压缩 + 分级 + 用户提示

**评分标准**：
- 优秀：完整架构+Trade-off+追问对答如流
- 良好：核心模块清晰
- 及格：能说出基本流程

---

### S2: 设计智能客服系统

**考察点**：意图识别、RAG+Agent混合、兜底策略

**标准答案**：

#### 架构
```
用户 → 意图识别 → 路由
                ├── FAQ 检索
                ├── RAG Pipeline
                ├── Agent 工具调用
                └── 转人工
```

#### 核心模块
1. **意图识别**：BERT 分类（92%准确率，50ms延迟）
2. **FAQ 检索**：语义检索 + 置信度阈值
3. **RAG Pipeline**：文档解析 → 分块 → 检索 → 生成
4. **Agent 工具**：订单查询、退款申请等
5. **兜底策略**：置信度低 → 转人工

#### 评估指标
- 解决率 > 70%
- 转人工率 < 30%
- 用户满意度 > 4/5

#### 追问
1. 知识库更新？→ FAQ实时，文档每日增量
2. 多语言？→ 多语言BERT + BGE-m3
3. 如何评估？→ 解决率 + 满意度 + 转人工率

---

### S3: 设计代码助手（Copilot）

**考察点**：低延迟、跨文件理解、隐私保护

**标准答案**：

#### 核心挑战
- 延迟 < 200ms
- 上下文：当前文件 + 相关文件 + 项目结构
- 隐私：代码不出域

#### 推理优化
- Speculative Decoding：小模型猜+大模型验证
- KV Cache 复用：相同前缀只算一次
- 分级模型：简单→1-3B，复杂→70B

#### 跨文件理解
1. 项目级 Embedding 索引
2. Import 依赖分析
3. AST 调用链分析

#### 追问
1. 大型代码库？→ 分层索引 + 增量更新
2. 如何评估？→ 接受率 + 编辑相似度 + 延迟

---

### S4: 设计 AI 搜索

**考察点**：多源融合、摘要生成、成本控制

**标准答案**：

#### 架构
```
Query → Query理解 → 多源检索 → 重排序 → LLM摘要 → 输出
```

#### 多源检索
- Web：Search API
- 知识库：Milvus 向量检索
- 实时数据：API 调用

#### 融合算法
- RRF（Reciprocal Rank Fusion）
- 时效性加权

#### 追问
1. 虚假信息？→ 多源交叉验证 + 权威性加权
2. 成本优化？→ 缓存 + 分级模型

---

### S5: 设计多模态 RAG

**考察点**：多模态解析、统一向量空间、跨模态检索

**标准答案**：

#### 解析
- 文本：分块 + Embedding
- 图片：OCR + Caption → 文本
- 表格：Table Transformer → 描述
- 视频：关键帧 + ASR

#### 统一向量空间
- BGE-m3：多语言 + 多模态
- 所有模态转为文本后统一 Embedding

#### 追问
1. 图表理解？→ Chart OCR + 数据提取
2. 视频处理？→ 关键帧 + 时间戳对齐

---

## RAG 专项

### R1: RAG 中检索结果不相关怎么办？

**考察点**：问题诊断、多维度排查

**标准答案**：

#### 排查清单
```
Query 层面 → Query 改写（HyDE、Query Expansion）
检索层面 → 检查 Embedding 模型、混合检索
数据层面 → 检查解析质量、分块策略
```

#### 具体方案
1. **HyDE**：生成假答案再检索，Recall 提升 10-20%
2. **混合检索**：BM25 + 向量 → RRF 融合
3. **Query Expansion**：LLM 生成同义 Query
4. **重排序**：Cross-Encoder Reranker

#### 追问
1. HyDE 原理？→ 假答案的向量比 Query 更接近真实文档
2. 混合检索权重？→ 实验调参，通常 α=0.5-0.7

---

### R2: 如何评估 RAG 系统？

**考察点**：评估体系设计、工具使用

**标准答案**：

#### 评估维度
| 维度 | 指标 | 工具 |
|------|------|------|
| 检索 | Recall@K、MRR | 自定义 |
| 生成 | Faithfulness、Relevancy | RAGAS |
| 端到端 | RAGAS 四指标 | RAGAS |
| 在线 | 用户反馈、A/B | 自定义 |

#### RAGAS 指标
- Faithfulness：正确声明数/总声明数（检测幻觉）
- Answer Relevancy：反向问题相似度（检测答非所问）
- Context Recall：可归因声明数/GT 总声明数（检索完整性）
- Context Precision：有用片段数/总片段数（检索噪声）

#### 追问
1. 如何建立 Ground Truth？→ 人工标注 + 众包
2. 评估频率？→ 每次更新后离线评估 + 每周人工抽检

---

### R3: RAG 中幻觉如何抑制？

**考察点**：幻觉根因、多层防御

**标准答案**：

#### 多层防御
1. **检索层**：提高检索质量（更相关的 Context）
2. **Prompt 层**：约束"仅基于给定信息回答"
3. **引用层**：标注答案来源（便于验证）
4. **输出层**：LLM-as-Judge 检测幻觉
5. **拒答层**：无相关信息时诚实拒绝

#### 追问
1. 幻觉根因？→ LLM 基于概率生成，可能编造
2. 引用溯源实现？→ 标注文档 ID + 位置

---

### R4: 向量数据库如何选型？

**考察点**：技术选型、Trade-off

**标准答案**：

| 维度 | Milvus | Qdrant | Pinecone |
|------|--------|--------|----------|
| 规模 | 十亿级 | 亿级 | 托管 |
| 部署 | 自托管/K8s | Docker | 全托管 |
| 运维 | 复杂 | 简单 | 零运维 |
| 混合检索 | ✅ | ✅ | 有限 |

**选择**：
- 大规模生产：Milvus
- 中小规模：Qdrant
- 快速验证：Pinecone

---

### R5: 长文档如何处理？

**考察点**：分块策略、层级检索

**标准答案**：

#### 分块策略
- 固定大小：512 tokens + 50 overlap
- 递归分块：按段落→句子→词
- 语义分块：基于 Embedding 相似度
- 文档结构：按标题/章节

#### 层级检索
1. 先定位章节（粗粒度）
2. 再定位段落（细粒度）
3. 返回最相关的 Top-K

---

## Agent 专项

### A1: ReAct 和 Plan-and-Execute 的区别？

**标准答案**：

| | ReAct | Plan-and-Execute |
|---|---|---|
| 流程 | 思考→行动→观察（循环） | 先规划→再执行 |
| 适合 | 动态场景 | 步骤明确 |
| 灵活性 | 高 | 低 |
| 效率 | 低（每步都思考） | 高（一次规划） |

**选择**：复杂任务用混合（先 Plan 后 ReAct 执行）

---

### A2: Agent 中工具调用失败如何处理？

**标准答案**：

#### 三层容错
1. **重试**：指数退避（1s→2s→4s），最多3次
2. **降级**：换工具 / 换模型 / 部分结果
3. **兜底**：转人工 / 缓存 / 诚实拒绝

#### 追问
- 非幂等操作不重试（如支付）
- 参数错误不重试（重试无意义）

---

### A3: 如何评估 Agent 质量？

**标准答案**：

#### 三维度
1. **结果**：Task Completion + Output Quality
2. **路径**：步骤数 + 回溯次数 + Token 消耗
3. **工具**：选择正确率 + 参数正确率

#### 工具
- LangSmith：自动追踪 + LLM-as-Judge
- Arize Phoenix：轨迹可视化

---

### A4: LangGraph 和 LangChain 的关系？

**标准答案**：

- **LangChain**：线性 Chain，适合简单 Pipeline
- **LangGraph**：图编排扩展，适合复杂 Agent（有状态、有循环、有分支）

**选择**：简单 RAG 用 LangChain，复杂 Agent 必须 LangGraph

---

### A5: 多代理如何协作？

**标准答案**：

| 模式 | 特点 | 适合 |
|------|------|------|
| Supervisor | 中心化调度 | 任务分工明确 |
| 共享状态 | 去中心化 | 协作创作 |
| 层级管理 | 混合 | 复杂项目 |

---

## 部署与运维

### D1: vLLM 的核心优化技术？

**标准答案**：

1. **PagedAttention**：KV Cache 分页，显存利用率 40%→95%
2. **Continuous Batching**：每个 token 后可插入新请求，吞吐 2-4x
3. **Prefix Caching**：相同 System Prompt 复用 KV Cache
4. **Speculative Decoding**：小模型猜+大模型验证

---

### D2: LLM 应用如何做成本优化？

**标准答案**：

1. **Prompt 优化**：压缩 + System Prompt 缓存
2. **缓存**：精确缓存 + 语义缓存 + KV Cache
3. **模型路由**：简单→小模型，复杂→大模型
4. **监控**：Token 用量 Dashboard + 异常告警

---

### D3: Prompt Injection 如何防御？

**标准答案**：

#### 多层防御
1. **输入层**：长度限制 + 分类器检测
2. **Prompt 层**：明确指令边界 + 角色固化
3. **模型层**：安全微调 + 输出审核
4. **工具层**：最小权限 + 审计日志

#### 工具
- NeMo Guardrails（开源）
- LlamaGuard（安全分类）

---

### D4: 如何实现 LLM 推理高可用？

**标准答案**：

#### 降级策略
- 主模型 → 备用模型 → 缓存结果

#### 熔断
- 错误率 > 50% → 熔断 30s
- 超时 > 10s → 快速失败

#### 多区域
- 就近路由 + 数据异步复制

---

## 项目深挖

### P1: 描述你做过的一个 RAG 项目

**STAR 回答**：

**Situation**：公司知识库 10 万+ 文档，查找效率低。

**Task**：构建智能问答系统。

**Action**：
1. 文档解析：Marker + Table Transformer
2. 语义分块：递归 512 tokens
3. 混合检索：BM25 + 向量 → RRF
4. 重排序：BGE-Reranker
5. 评估：RAGAS 四指标

**Result**：
- Recall@5：65% → 89%
- 查找时间：15min → 30s
- 满意度：3.2 → 4.5

---

### P2: 描述一次你解决技术难题的经历

**STAR 回答**：

**Situation**：RAG 检索质量不达标，Recall@5 只有 60%。

**Task**：一个月内提升到 85%。

**Action**：
1. 分析 Bad Case：Query 和文档语义不匹配
2. 尝试方案：换 Embedding、混合检索、Query 改写
3. 组合方案 B+C

**Result**：Recall@5 达到 89%。

---

### P3: 如何评估微调效果？

**标准答案**：

1. **能力**：lm-eval-harness（MMLU、GSM8K、HumanEval）
2. **对齐**：MT-Bench、AlpacaEval
3. **业务**：线上 A/B 测试

---

### P4: 描述你做过的一个 Agent 项目

**STAR 回答**：

**项目**：多代理协作写作平台。

**架构**：Supervisor → {Researcher, Writer, Reviewer}

**挑战**：Agent 间协调 → Supervisor 模式

**结果**：文章质量 4.2/5，效率提升 5x。

---

### P5: 如何设计 LLM 应用的评估体系？

**标准答案**：

1. **离线**：测试集 500+ 题，RAGAS + lm-eval
2. **在线**：A/B 测试 + 用户反馈
3. **人工**：定期 Bad Case 分析

---

## 编码与算法

### C1: 实现一个 LRU Cache

**标准答案**：

```python
class LRUCache:
    def __init__(self, capacity: int):
        self.cap = capacity
        self.cache = {}
        self.head = Node(0, 0)
        self.tail = Node(0, 0)
        self.head.next = self.tail
        self.tail.prev = self.head

    def get(self, key: int) -> int:
        if key in self.cache:
            node = self.cache[key]
            self._remove(node)
            self._add(node)
            return node.val
        return -1

    def put(self, key: int, value: int) -> None:
        if key in self.cache:
            self._remove(self.cache[key])
        node = Node(key, value)
        self._add(node)
        self.cache[key] = node
        if len(self.cache) > self.cap:
            lru = self.head.next
            self._remove(lru)
            del self.cache[lru.key]
```

**追问**：
- 时间复杂度：O(1) for get/put
- 空间复杂度：O(capacity)

---

### C2: 实现语义缓存查找

**标准答案**：

```python
import numpy as np

class SemanticCache:
    def __init__(self, model="BAAI/bge-small-zh", threshold=0.92):
        self.model = SentenceTransformer(model)
        self.threshold = threshold
        self.cache = {}
        self.embeddings = []

    def get(self, query: str):
        if not self.cache:
            return None
        q_emb = self.model.encode(query)
        embs = np.array(self.embeddings)
        sims = np.dot(embs, q_emb) / (np.linalg.norm(embs, axis=1) * np.linalg.norm(q_emb))
        best_idx = np.argmax(sims)
        if sims[best_idx] >= self.threshold:
            return self.cache[list(self.cache.keys())[best_idx]]
        return None
```

---

### C3: 实现一个简单的 ReAct Agent

**标准答案**：

```python
class ReActAgent:
    def __init__(self, llm, tools):
        self.llm = llm
        self.tools = tools

    def run(self, query: str, max_steps=5):
        for step in range(max_steps):
            # Thought
            thought = self.llm.generate(f"Thought: {query}")
            
            # Action
            action = self.llm.generate(f"Action: {thought}")
            tool_name, args = parse_action(action)
            
            # Observation
            result = self.tools[tool_name](**args)
            
            if "final_answer" in result:
                return result
        
        return "Max steps reached"
```

---

## 行为面试

### B1: 你如何跟进最新 AI 技术？

**回答要点**：

1. **日常跟进**：
   - 论文：每周 1-2 篇（arXiv、Papers With Code）
   - 博客：OpenAI/Anthropic/LangChain 官方
   - 开源：GitHub Trending（AI 方向）

2. **动手实践**：
   - 每季度一个 Side Project
   - 复现经典论文

3. **社区参与**：
   - 技术分享（团队/社区）
   - 开源贡献

4. **最近学习**：
   - Graph RAG（微软开源）
   - LangGraph 多代理协作
   - GLM-5 技术报告

---

### B2: 描述一次团队合作解决难题的经历

**STAR 回答**：

**Situation**：团队 RAG 系统上线后用户反馈答案不准确。

**Task**：两周内将准确率从 70% 提升到 85%。

**Action**：
1. 我主导分析了 100 个 Bad Case
2. 发现主要问题是分块策略不当
3. 提出混合检索 + 重排序方案
4. 协调后端和前端同学一起实现

**Result**：准确率提升到 88%，用户满意度 +30%。
