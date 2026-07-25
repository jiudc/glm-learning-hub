# RAG 系统设计与实战 — 完整知识体系

## 目录
1. [RAG 架构演进](#架构演进)
2. [文档处理层](#文档处理)
3. [检索引擎](#检索引擎)
4. [重排序](#重排序)
5. [高级 RAG 模式](#高级模式)
6. [RAG 评估体系](#评估体系)
7. [面试高频问题](#面试问题)

---

## 1. 架构演进

### Naive RAG（基础版）
```
用户问题 → Embedding → 向量检索 → 拼接 Prompt → LLM 生成
```
**问题**：检索质量差、上下文冗余、多跳推理弱、幻觉无法抑制

### Advanced RAG（进阶版）
```
用户问题 → Query 改写 → 混合检索 → 重排序 → 过滤 → LLM 生成
```
**改进**：HyDE、Query Expansion、Reranker、上下文压缩

### Agentic RAG（智能版）
```
用户问题 → Agent 规划 → 动态检索 → 工具调用 → 反思 → 生成
```
**特点**：Agent 自主决定检索策略、多轮检索、自我修正

### Graph RAG（图谱版）
结合知识图谱 + 向量检索，擅长多跳推理和关系查询
- 微软 Graph RAG：社区检测 + 全局摘要
-  Neo4j + 向量：实体关系 + 语义检索

### Modular RAG（模块化版）
将各组件模块化，按需组合，支持插件式扩展

---

## 2. 文档处理层

### 文档解析
| 文档类型 | 工具 | 特点 |
|---------|------|------|
| PDF | Nougat, Marker, PyMuPDF | Nougat 擅长学术 PDF，Marker 支持表格 |
| HTML | BeautifulSoup, trafilata | trafilata 自动提取正文 |
| 表格 | Table Transformer, Camelot | TATR 结构识别 + 单元格检测 |
| 图片 | GPT-4V, CogAgent | 视觉理解生成描述 |
| Office | python-docx, python-pptx | 原生解析 |

### 分块策略
| 策略 | 参数 | 适用场景 |
|------|------|---------|
| 固定大小 | 512 tokens, overlap 50 | 通用场景 |
| 递归分块 | 按段落→句子→词 | 保留层级结构 |
| 语义分块 | 基于 Embedding 相似度 | 主题切换明显 |
| 文档结构 | 按标题/章节 | 结构化文档 |
| 滑动窗口 | 窗口 512, 步长 256 | 需要高召回 |

### 分块最佳实践
- 中文：256-512 tokens/块，overlap 50-100
- 保持句子完整（不在句中切断）
- 保留元数据（来源、页码、章节标题）
- 表格单独分块（不拆散表格结构）

---

## 3. 检索引擎

### Embedding 模型选型
| 模型 | 维度 | 语言 | 特点 |
|------|------|------|------|
| BGE-large-zh-v1.5 | 1024 | 中文 | 中文最强开源 |
| BGE-m3 | 1024 | 多语言 | 稀疏+稠密+多向量 |
| text-embedding-3-large | 3072 | 多语言 | OpenAI 最强 |
| m3e-base | 768 | 中文 | 轻量快速 |
| GTE-large-zh | 1024 | 中文 | 阿里开源 |
| Cohere embed-v3 | 1024 | 多语言 | SOTA |

### 向量数据库对比
| 维度 | Milvus | Qdrant | Pinecone | Weaviate |
|------|--------|--------|----------|----------|
| 规模 | 十亿级 | 亿级 | 托管 | 亿级 |
| 部署 | 自托管/K8s | Docker/自托管 | 全托管 | 自托管 |
| 运维 | 复杂 | 简单 | 零运维 | 中等 |
| 混合检索 | 支持 | 支持 | 有限 | 支持 |
| 成本 | 硬件 | 适中 | 按量 | 硬件 |

### 混合检索
**为什么需要？**
- 向量检索：擅长语义匹配（"汽车"≈"轿车"）
- BM25：擅长关键词匹配（"GLM-4"精确匹配）

**融合算法**：
- RRF（Reciprocal Rank Fusion）：`score = Σ 1/(k + rank_i)`
- 加权融合：`score = α * dense + (1-α) * sparse`
- 交叉编码器重排序

---

## 4. 重排序

### 为什么需要重排序？
- 向量检索是 bi-encoder（独立编码），损失交互信息
- 重排序用 cross-encoder（联合编码），精度更高
- 2-stage 架构：检索召回（快）→ 重排序（准）

### Reranker 选型
| 模型 | 语言 | 速度 | 精度 |
|------|------|------|------|
| BGE-Reranker-v2-m3 | 多语言 | 快 | 高 |
| BGE-Reranker-v2-gemma | 英文 | 中 | 很高 |
| Cohere Rerank 3.5 | 多语言 | 快 | SOTA |
| Jina Reranker v2 | 多语言 | 中 | 很高 |

### 实践建议
- 检索 Top-50 → Rerank → 取 Top-5 给 LLM
- Reranker 延迟：~50ms/query（可接受）
- 缓存热门 Query 的 Rerank 结果

---

## 5. 高级 RAG 模式

### HyDE（Hypothetical Document Embeddings）
```
Query → LLM 生成假答案 → Embedding 假答案 → 检索相似文档
```
**原理**：假答案的向量比 Query 更接近真实文档
**效果**：Recall 提升 10-20%

### Query Expansion
- LLM 生成 3-5 个同义 Query
- 分别检索 → 去重合并
- 适合模糊/简短 Query

### Multi-hop RAG
- 复杂问题拆分成多个子 Query
- 链式检索：前一步结果作为下一步上下文
- 适合"X 的老板是谁的同事？"类问题

### Corrective RAG（CRAG）
```
检索 → 评估相关性 → {相关: 直接生成 | 不相关: 补充 Web 搜索 | 模糊: 混合}
```

### Self-RAG
```
检索 → 反思是否需要检索 → 生成 → 反思是否需要修正 → 输出
```

### Agentic RAG
Agent 自主决定：
- 是否需要检索
- 用什么检索策略
- 是否需要多轮检索
- 是否调用其他工具

---

## 6. RAG 评估体系

### RAGAS 指标
| 指标 | 公式 | 范围 | 含义 |
|------|------|------|------|
| Faithfulness | 正确声明数/总声明数 | 0-1 | 是否基于 Context（无幻觉） |
| Answer Relevancy | 反向问题相似度均值 | 0-1 | 是否切题 |
| Context Recall | 可归因声明数/GT 总声明数 | 0-1 | 检索是否完整 |
| Context Precision | 有用片段数/总片段数 | 0-1 | 检索是否精准 |

### 其他评估工具
| 工具 | 特点 |
|------|------|
| TruLens | 实时追踪 + 评估 + Dashboard |
| ARES | 合成数据 + 统计评估 |
| LLM-as-Judge | GPT-4 当裁判打分 |
| Human Evaluation | 人工标注 Ground Truth |

### 评估最佳实践
1. 构建 500+ 题测试集（覆盖各场景）
2. 每次更新自动跑评估（回归测试）
3. 在线 A/B 测试 + 用户反馈
4. 定期 Bad Case 分析（每周）

---

## 7. 面试高频问题

### Q1: 设计企业级 RAG 系统，如何保证检索质量？
- 文档层：高质量解析 + 语义分块 + 元数据
- 检索层：混合检索（BM25+向量）+ Query 改写
- 重排序：Cross-Encoder Reranker
- 评估层：离线 RAGAS + 在线 A/B + 人工抽检

### Q2: RAG 中检索结果不相关怎么办？
- Query 改写（HyDE、Query Expansion）
- 检查 Embedding 模型是否适合领域
- 尝试混合检索（加入 BM25）
- 检查文档解析/分块质量

### Q3: 向量数据库选型？
- 大规模生产：Milvus（分布式）
- 中小规模：Qdrant（简单）
- 快速验证：Pinecone（零运维）

### Q4: 如何评估 RAG 系统？
- 检索：Recall@K、MRR
- 生成：Faithfulness、Relevancy
- 端到端：RAGAS 四指标
- 在线：用户反馈、A/B 测试

### Q5: RAG 中幻觉如何抑制？
- 提高检索质量（更相关的 Context）
- Prompt 约束（"仅基于给定信息回答"）
- 引用溯源（标注来源，便于验证）
- 拒答机制（无相关信息时诚实拒绝）
- 输出审核（LLM-as-Judge 检测幻觉）

### Q6: 长文档如何处理？
- 分块策略优化（语义分块 + 重叠）
- 文档摘要（先摘要后检索）
- 层级检索（先定位章节，再定位段落）
- 滑动窗口（多粒度分块）
