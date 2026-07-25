-- ============================================
-- GLM Learning Hub 3.0 — 深度面试题（最终版）
-- 执行前提：migration_v2.sql 已执行
-- ============================================

DELETE FROM interview_questions;

-- 系统设计（5题）
INSERT INTO interview_questions (category, subcategory, question, hint, answer, difficulty, company_tag, is_featured, sort_order) VALUES
('system_design', 'architecture', '设计 ChatGPT 类对话系统', '从流式输出、上下文管理、高可用、成本控制四个层面回答', '## 标准答案

### 真实场景
在字节跳动，我们面对 1 亿 DAU、峰值 50K QPS 的对话请求。预算有限，需要在保证体验的同时控制成本。

### 1. 流式输出
- SSE 实现打字机效果
- 背压控制：客户端消费慢时降速
- 断线重连：sequence number 续传

### 2. 上下文窗口管理
- 滑动窗口：保留最近 N 轮
- 摘要压缩：旧对话生成摘要
- Token 计数：tiktoken 精确计算

### 3. 会话存储
- Redis：热数据（活跃会话），TTL 30min
- PostgreSQL：冷数据（历史持久化）

### 4. LLM 推理
- vLLM + PagedAttention（显存利用率 40%→95%）
- 连续批处理（吞吐 2-4x）
- 模型路由：简单→小模型，复杂→大模型

### 5. Trade-off
| 决策 | 选择 | 原因 |
|------|------|------|
| 流式协议 | SSE | 简单、自动重连 |
| 上下文策略 | 混合 | 短对话窗口+长对话摘要 |
| 模型部署 | 混合 | 核心自研+兜底API |

### 追问链
1. 流量增加10倍？→ 水平扩展 + 降级
2. 如何控制成本？→ 模型路由 + 缓存 + 批处理
3. 上下文溢出？→ 压缩 + 分级 + 用户提示
4. 如何保证多区域一致性？→ 就近路由 + 异步复制
5. 模型降级顺序？→ GPT-4 → GPT-4o → 自研模型 → 缓存

### 评分标准
- 优秀：完整架构+Trade-off+追问对答如流
- 良好：核心模块清晰
- 及格：能说出基本流程', 'hard', ARRAY['字节', '阿里', '腾讯'], true, 1);

INSERT INTO interview_questions (category, subcategory, question, hint, answer, difficulty, company_tag, is_featured, sort_order) VALUES
('system_design', 'architecture', '设计智能客服系统', '从意图识别、RAG+Agent混合、兜底策略回答', '## 标准答案

### 真实场景
在美团，日均 100 万咨询电话，需要在不增加人工客服的前提下将解决率从 60% 提升到 80%。

### 架构
用户 → 意图识别 → 路由 → {FAQ/RAG/Agent} → 兜底

### 核心模块
1. **意图识别**：BERT 分类（92%准确率，50ms）
2. **FAQ 检索**：语义检索 + 置信度阈值
3. **RAG Pipeline**：解析→分块→检索→生成
4. **Agent 工具**：订单查询、退款申请
5. **兜底策略**：置信度低→转人工

### 失败路径
我们最初只用 FAQ 检索，但发现 40% 的问题是 FAQ 覆盖不了的。后来加入 RAG 后解决率提升到 75%，但还是不够。最后加入 Agent 工具调用才达到 80%。

### 追问链
1. 知识库更新？→ FAQ实时，文档每日增量
2. 多语言？→ 多语言BERT + BGE-m3
3. 如何评估效果？→ 解决率 + 满意度 + 转人工率
4. 意图识别错误怎么办？→ 置信度阈值 + 人工兜底
5. 如何降低转人工率？→ 持续优化知识库 + Agent 能力

### 评分标准
- 优秀：完整架构 + 失败分析 + 追问对答
- 良好：核心模块 + 基本评估
- 及格：能说出基本流程', 'hard', ARRAY['字节', '美团', '京东'], true, 2);

INSERT INTO interview_questions (category, subcategory, question, hint, answer, difficulty, company_tag, is_featured, sort_order) VALUES
('system_design', 'architecture', '设计代码助手（Copilot）', '从低延迟、跨文件理解、隐私保护回答', '## 标准答案

### 真实场景
在 GitHub Copilot，我们需要实现 <200ms 的代码补全延迟，同时保证代码隐私不出域。

### 核心挑战
- 延迟 < 200ms
- 上下文：当前文件 + 相关文件 + 项目结构
- 隐私：代码不出域

### 推理优化
- Speculative Decoding：小模型猜+大模型验证（延迟2-3x↓）
- KV Cache 复用：相同前缀只算一次
- 分级模型：简单→1-3B，复杂→70B

### 跨文件理解
1. 项目级 Embedding 索引
2. Import 依赖分析
3. AST 调用链分析

### 追问链
1. 大型代码库？→ 分层索引 + 增量更新
2. 评估？→ 接受率 + 编辑相似度 + 延迟
3. 隐私保护？→ 本地Embedding + 代码脱敏
4. 冷启动问题？→ 预训练 + 少样本
5. 如何处理代码版权？→ 过滤 + 引用溯源

### 评分标准
- 优秀：完整架构 + 隐私方案 + 追问
- 良好：核心模块 + 基本评估
- 及格：能说出基本流程', 'hard', ARRAY['字节', '微软', 'GitHub'], true, 3);

INSERT INTO interview_questions (category, subcategory, question, hint, answer, difficulty, company_tag, is_featured, sort_order) VALUES
('system_design', 'architecture', '设计 AI 搜索', '从多源融合、摘要生成、成本控制回答', '## 标准答案

### 真实场景
在百度，我们需要将传统搜索升级为 AI 搜索，面对 100 亿索引页面，要求摘要准确率 > 95%。

### 架构
Query → Query理解 → 多源检索 → 重排序 → LLM摘要 → 输出

### 多源检索
- Web：Search API
- 知识库：Milvus 向量检索
- 实时数据：API 调用

### 融合算法
- RRF（Reciprocal Rank Fusion）
- 时效性加权

### 追问链
1. 虚假信息？→ 多源交叉验证 + 权威性加权
2. 成本优化？→ 缓存 + 分级模型
3. 如何评估摘要质量？→ 人工评估 + 自动指标
4. 实时性如何保证？→ 增量索引 + 流式更新
5. 如何处理长尾 Query？→ Query 改写 + 扩展

### 评分标准
- 优秀：完整架构 + 评估方案 + 追问
- 良好：核心模块 + 基本融合
- 及格：能说出基本流程', 'hard', ARRAY['字节', 'Google', '百度'], true, 4);

INSERT INTO interview_questions (category, subcategory, question, hint, answer, difficulty, company_tag, is_featured, sort_order) VALUES
('system_design', 'architecture', '设计多模态 RAG 系统', '从多模态解析、统一向量空间、跨模态检索回答', '## 标准答案

### 真实场景
在 OpenAI，我们需要支持用户上传图片、PDF、视频等多种格式，实现跨模态问答。

### 解析
- 文本：分块 + Embedding
- 图片：OCR + Caption → 文本
- 表格：Table Transformer → 描述
- 视频：关键帧 + ASR

### 统一向量空间
- BGE-m3：多语言 + 多模态
- 所有模态转为文本后统一 Embedding

### 追问链
1. 图表理解？→ Chart OCR + 数据提取
2. 视频处理？→ 关键帧 + 时间戳对齐
3. 跨模态检索？→ 统一向量空间 + RRF
4. 存储成本？→ 压缩 + 冷热分离
5. 如何评估跨模态效果？→ Recall@K + 人工评估

### 评分标准
- 优秀：完整架构 + 存储方案 + 追问
- 良好：核心模块 + 基本解析
- 及格：能说出基本流程', 'expert', ARRAY['字节', 'Google', 'OpenAI'], true, 5);

-- RAG 专项（5题）
INSERT INTO interview_questions (category, subcategory, question, hint, answer, difficulty, company_tag, is_featured, sort_order) VALUES
('system_design', 'rag', 'RAG 中检索结果不相关怎么办？', '从 Query、检索、数据三个维度排查', '## 排查清单

### Query 层面
- Query 改写（HyDE、Query Expansion）
- 意图识别 → 路由到不同策略

### 检索层面
- 检查 Embedding 模型是否适合领域
- 尝试混合检索（加入 BM25）
- 调整 Top-K 和相似度阈值

### 数据层面
- 检查文档解析质量
- 检查分块策略
- 检查数据清洗

### 追问链
1. HyDE 原理？→ 假答案的向量比 Query 更接近真实文档
2. 混合检索权重？→ 实验调参，通常 α=0.5-0.7
3. 如何选择 Embedding 模型？→ 领域适配 + 实验对比
4. 分块大小如何确定？→ 实验对比 256/512/1024
5. 如何评估检索质量？→ Recall@K + MRR + nDCG

### 评分标准
- 优秀：完整排查 + 实验设计 + 追问
- 良好：基本排查 + 常用方法
- 及格：能说出基本方法', 'medium', ARRAY['美团', '京东', '阿里'], false, 6);

INSERT INTO interview_questions (category, subcategory, question, hint, answer, difficulty, company_tag, is_featured, sort_order) VALUES
('system_design', 'rag', '如何评估 RAG 系统？', '从检索、生成、端到端、在线四个层面回答', '## 评估体系

| 维度 | 指标 | 工具 |
|------|------|------|
| 检索 | Recall@K、MRR | 自定义 |
| 生成 | Faithfulness、Relevancy | RAGAS |
| 端到端 | RAGAS 四指标 | RAGAS |
| 在线 | 用户反馈、A/B | 自定义 |

### RAGAS 指标
- Faithfulness：正确声明数/总声明数（检测幻觉）
- Answer Relevancy：反向问题相似度（检测答非所问）
- Context Recall：可归因声明数/GT 总声明数（检索完整性）
- Context Precision：有用片段数/总片段数（检索噪声）

### 追问链
1. 如何建立 Ground Truth？→ 人工标注 + 众包
2. 评估频率？→ 每次更新后离线评估 + 每周人工抽检
3. 指标冲突怎么办？→ 根据业务目标设定权重
4. 如何对比不同方案？→ A/B 测试 + 统计显著性
5. 评估成本太高？→ 采样评估 + 自动化

### 评分标准
- 优秀：完整体系 + 实验设计 + 追问
- 良好：基本指标 + 常用工具
- 及格：能说出基本指标', 'hard', ARRAY['字节', '阿里', '腾讯'], true, 7);

INSERT INTO interview_questions (category, subcategory, question, hint, answer, difficulty, company_tag, is_featured, sort_order) VALUES
('system_design', 'rag', 'RAG 中幻觉如何抑制？', '从检索、Prompt、引用、输出、拒答五层防御', '## 多层防御

1. **检索层**：提高检索质量（更相关的 Context）
2. **Prompt 层**：约束"仅基于给定信息回答"
3. **引用层**：标注答案来源（便于验证）
4. **输出层**：LLM-as-Judge 检测幻觉
5. **拒答层**：无相关信息时诚实拒绝

### 追问链
1. 幻觉根因？→ LLM 基于概率生成，可能编造
2. 引用溯源实现？→ 标注文档 ID + 位置
3. LLM-as-Judge 有偏见怎么办？→ 多个 Judge 投票
4. 拒答率太高怎么办？→ 优化检索 + 降低阈值
5. 如何评估幻觉抑制效果？→ 人工抽检 + 自动指标

### 评分标准
- 优秀：五层防御 + 评估方案 + 追问
- 良好：基本防御 + 常用方法
- 及格：能说出基本方法', 'medium', ARRAY['字节', '阿里', '腾讯'], false, 8);

INSERT INTO interview_questions (category, subcategory, question, hint, answer, difficulty, company_tag, is_featured, sort_order) VALUES
('system_design', 'rag', '向量数据库如何选型？', '从规模、运维、成本三方面对比', '## 对比

| 维度 | Milvus | Qdrant | Pinecone |
|------|--------|--------|----------|
| 规模 | 十亿级 | 亿级 | 托管 |
| 部署 | 自托管/K8s | Docker | 全托管 |
| 运维 | 复杂 | 简单 | 零运维 |
| 混合检索 | 支持 | 支持 | 有限 |

### 选择建议
- 大规模生产：Milvus
- 中小规模：Qdrant
- 快速验证：Pinecone

### 追问链
1. Milvus 集群？→ etcd + MinIO + Pulsar
2. Qdrant 性能？→ 单机 100K QPS
3. 如何迁移？→ 双写 + 灰度切换
4. 成本对比？→ 自建 vs 托管 TCO 分析
5. 高可用方案？→ 多副本 + 跨区部署

### 评分标准
- 优秀：对比分析 + 迁移方案 + 追问
- 良好：基本对比 + 常用选择
- 及格：能说出基本区别', 'medium', ARRAY['字节', '腾讯', '美团'], false, 9);

INSERT INTO interview_questions (category, subcategory, question, hint, answer, difficulty, company_tag, is_featured, sort_order) VALUES
('system_design', 'rag', '长文档如何处理？', '从分块策略、层级检索回答', '## 分块策略
- 固定大小：512 tokens + 50 overlap
- 递归分块：按段落→句子→词
- 语义分块：基于 Embedding 相似度
- 文档结构：按标题/章节

### 层级检索
1. 先定位章节（粗粒度）
2. 再定位段落（细粒度）
3. 返回最相关的 Top-K

### 追问链
1. 分块大小选择？→ 实验对比 256/512/1024 的 Recall@K
2. 重叠大小？→ 50-100 tokens
3. 如何评估分块质量？→ 检索召回率 + 人工抽检
4. 跨块引用怎么办？→ 引用链 + 上下文拼接
5. 表格如何处理？→ 单独分块 + 结构保留

### 评分标准
- 优秀：策略详解 + 评估方案 + 追问
- 良好：基本策略 + 常用方法
- 及格：能说出基本方法', 'medium', ARRAY['阿里', '腾讯'], false, 10);

-- Agent 专项（5题）
INSERT INTO interview_questions (category, subcategory, question, hint, answer, difficulty, company_tag, is_featured, sort_order) VALUES
('system_design', 'agent', 'ReAct 和 Plan-and-Execute 的区别？', '从流程、适合场景、灵活性、效率四方面对比', '## 对比

| | ReAct | Plan-and-Execute |
|---|---|---|
| 流程 | 思考→行动→观察（循环） | 先规划→再执行 |
| 适合 | 动态场景 | 步骤明确 |
| 灵活性 | 高 | 低 |
| 效率 | 低（每步都思考） | 高（一次规划） |

### 选择
- 复杂任务用混合（先 Plan 后 ReAct 执行）
- 简单任务用 Plan-and-Execute

### 追问链
1. 何时用 ReAct？→ 需要动态调整步骤时
2. 何时用 Plan？→ 任务步骤可预先确定时
3. 如何混合？→ 先 Plan 生成大纲，再 ReAct 执行细节
4. Plan 失败怎么办？→ 动态调整 + 回退到 ReAct
5. 如何评估路径质量？→ 步骤数 + 回溯次数 + Token 消耗

### 评分标准
- 优秀：对比分析 + 混合方案 + 追问
- 良好：基本对比 + 常用选择
- 及格：能说出基本区别', 'medium', ARRAY['字节', '阿里', '腾讯'], false, 11);

INSERT INTO interview_questions (category, subcategory, question, hint, answer, difficulty, company_tag, is_featured, sort_order) VALUES
('system_design', 'agent', 'Agent 中工具调用失败如何处理？', '从重试、降级、兜底三层策略回答', '## 三层容错策略

### 1. 重试层
- 指数退避重试（1s→2s→4s）
- 最多 3 次
- 只重试幂等操作

### 2. 降级层
- 换工具（Plan B）
- 换模型：大模型→小模型
- 部分结果：返回已完成+说明失败原因

### 3. 兜底层
- 转人工
- 返回缓存结果
- 诚实拒绝

### 追问链
1. 什么情况下不重试？→ 非幂等操作、参数错误
2. 幂等设计？→ 唯一请求ID + 服务端去重
3. 如何监控失败率？→ 日志 + 告警 + Dashboard
4. 降级顺序？→ 按成本从高到低
5. 如何评估容错效果？→ 失败率 + 恢复时间

### 评分标准
- 优秀：三层策略 + 监控方案 + 追问
- 良好：基本策略 + 常用方法
- 及格：能说出基本方法', 'hard', ARRAY['字节', '阿里', '腾讯'], true, 12);

INSERT INTO interview_questions (category, subcategory, question, hint, answer, difficulty, company_tag, is_featured, sort_order) VALUES
('system_design', 'agent', '如何评估 Agent 的任务完成质量？', '从结果、路径、工具三个维度回答', '## 评估体系

### 结果评估
- Task Completion：是否完成目标（0/1或分级）
- Output Quality：输出质量评分（LLM-as-Judge）

### 路径评估（Trajectory）
- 步骤数：vs 最优路径
- 回溯次数：是否频繁修正
- Token 消耗：效率

### 工具评估
- Tool Selection：是否选对工具
- Tool Arguments：参数是否正确

### 实践工具
- LangSmith：自动追踪 + 评估
- Arize Phoenix：轨迹可视化

### 追问链
1. LLM-as-Judge 偏见？→ 多个Judge投票 + 人工抽检
2. Ground Truth？→ 人工标注 + 众包
3. 如何评估路径质量？→ 步骤数 + 回溯次数
4. 工具选择错误怎么办？→ 重试 + 换工具
5. 如何降低评估成本？→ 采样 + 自动化

### 评分标准
- 优秀：三维度 + 工具 + 追问
- 良好：基本维度 + 常用工具
- 及格：能说出基本维度', 'hard', ARRAY['OpenAI', 'Anthropic', '字节'], true, 13);

INSERT INTO interview_questions (category, subcategory, question, hint, answer, difficulty, company_tag, is_featured, sort_order) VALUES
('system_design', 'agent', 'LangGraph 和 LangChain 的关系？', '互补关系，不是替代', '## 关系说明

### LangChain
- 定位：LLM 应用开发框架
- 核心：Chain（线性调用链）
- 适合：简单 Pipeline（一次调用→一次输出）

### LangGraph
- 定位：LangChain 的图编排扩展
- 核心：Graph（有状态、有分支的工作流）
- 适合：复杂 Agent（多步骤、有循环、有条件分支）

### 选择
- 简单 RAG：LangChain 足够
- 复杂 Agent：必须 LangGraph
- 多代理协作：LangGraph（状态机+图编排）

### 追问链
1. LangGraph 核心概念？→ State、Node、Edge、Graph
2. 何时从 LangChain 迁移？→ 需要循环或条件分支时
3. LangGraph 性能？→ 状态序列化开销
4. 如何调试？→ LangSmith 追踪
5. 支持分布式？→ 通过 Checkpoint

### 评分标准
- 优秀：关系说明 + 迁移时机 + 追问
- 良好：基本关系 + 常用选择
- 及格：能说出基本区别', 'medium', ARRAY['字节', '阿里', '腾讯'], false, 14);

INSERT INTO interview_questions (category, subcategory, question, hint, answer, difficulty, company_tag, is_featured, sort_order) VALUES
('system_design', 'agent', '多代理如何协作？', '从 Supervisor、共享状态、层级管理三种模式回答', '## 协作模式

| 模式 | 特点 | 适合 |
|------|------|------|
| Supervisor | 中心化调度 | 任务分工明确 |
| 共享状态 | 去中心化 | 协作创作 |
| 层级管理 | 混合 | 复杂项目 |

### Supervisor 模式
- Supervisor Agent 决定谁执行
- 每个 Agent 独立 Scratchpad

### 共享状态模式
- 所有 Agent 共享工作空间
- 适合：协作创作、头脑风暴

### 追问链
1. 选择依据？→ 任务复杂度 + 协调需求
2. 通信方式？→ 消息队列 / 共享内存
3. 冲突解决？→ 优先级 + 投票
4. 如何评估协作效率？→ 完成时间 + 通信成本
5. 扩展性？→ 动态增减 Agent

### 评分标准
- 优秀：模式对比 + 评估方案 + 追问
- 良好：基本模式 + 常用选择
- 及格：能说出基本模式', 'medium', ARRAY['字节', '阿里'], false, 15);

-- 部署与运维（4题）
INSERT INTO interview_questions (category, subcategory, question, hint, answer, difficulty, company_tag, is_featured, sort_order) VALUES
('system_design', 'deployment', 'vLLM 的核心优化技术？', '从 PagedAttention、连续批处理、缓存、量化回答', '## vLLM 核心技术

### 1. PagedAttention
- 问题：传统 KV Cache 显存浪费（预分配最大长度）
- 解决：类似 OS 虚拟内存的分页管理
- 效果：显存利用率 40%→95%

### 2. 连续批处理
- 传统：一批全部生成完才能接新请求
- vLLM：每个 token 生成后就可以插入新请求
- 效果：吞吐量 2-4x

### 3. Prefix Caching
- 相同 System Prompt 复用 KV Cache
- 适合：固定 System Prompt 场景

### 4. Speculative Decoding
- 小模型先猜 N 个 token → 大模型验证
- 效果：延迟降低 2-3x

### 追问链
1. PagedAttention 原理？→ 将 KV Cache 分成固定大小 Block
2. 适用场景？→ 所有 LLM 推理场景
3. 如何选择量化方案？→ 精度 vs 速度 trade-off
4. 多 GPU 如何扩展？→ Tensor Parallelism
5. 如何监控性能？→ Prometheus + Grafana

### 评分标准
- 优秀：技术详解 + 监控方案 + 追问
- 良好：基本技术 + 常用方法
- 及格：能说出基本技术', 'hard', ARRAY['字节', '阿里', 'Google'], true, 16);

INSERT INTO interview_questions (category, subcategory, question, hint, answer, difficulty, company_tag, is_featured, sort_order) VALUES
('system_design', 'deployment', 'LLM 应用如何做成本优化？', '从 Prompt、缓存、模型路由三方面优化', '## 成本优化策略

### Prompt 优化
- 压缩 Prompt：去除冗余，只保留关键信息
- 动态 Few-shot：根据问题复杂度选择示例数
- System Prompt 缓存（Prompt Caching）

### 缓存策略
- 精确缓存：相同问题→直接返回（GPT Cache）
- 语义缓存：相似问题→返回近似答案
- KV Cache：相同前缀→复用计算

### 模型路由
- 简单任务→小模型（GPT-4o-mini/GLM-4-Flash）
- 中等任务→中模型（GPT-4o/GLM-4）
- 复杂任务→大模型（GPT-4/Claude 3.5）

### 追问链
1. 缓存命中率？→ 通常 30-50%
2. 成本节省？→ 通常 40-60%
3. 如何评估缓存效果？→ 命中率 + 延迟降低
4. 模型路由错误怎么办？→ 降级 + 重试
5. 如何持续优化？→ A/B 测试 + 持续迭代

### 追问链
1. 缓存命中率？→ 通常 30-50%
2. 成本节省？→ 通常 40-60%
3. 如何评估缓存效果？→ 命中率 + 延迟降低
4. 模型路由错误怎么办？→ 降级 + 重试
5. 如何持续优化？→ A/B 测试 + 持续迭代

### 评分标准
- 优秀：三层优化 + 评估方案 + 追问
- 良好：基本优化 + 常用方法
- 及格：能说出基本方法', 'medium', ARRAY['字节', '阿里', '腾讯'], false, 17);

INSERT INTO interview_questions (category, subcategory, question, hint, answer, difficulty, company_tag, is_featured, sort_order) VALUES
('system_design', 'deployment', 'LLM 应用的 Prompt Injection 如何防御？', '多层防御体系', '## 多层防御

### 1. 输入层
- 长度限制 + 特殊字符过滤
- 分类器检测（是否包含注入模式）
- 用户输入与系统 Prompt 隔离

### 2. Prompt 层
- 明确指令边界（### USER INPUT ###）
- 角色固化（System Prompt 强约束）
- Few-shot 示例引导正确行为

### 3. 模型层
- 安全微调（拒答注入）
- 输出审核（检测泄露系统 Prompt）

### 4. 工具层
- 最小权限原则
- 参数校验
- 审计日志

### 追问链
1. 如何检测注入？→ 分类器 + 规则
2. 注入后如何处理？→ 拒绝 + 审计 + 告警
3. 分类器误判怎么办？→ 人工审核 + 白名单
4. 如何评估防御效果？→ 攻击成功率
5. 最新攻击手段？→ 持续跟踪 + 更新规则

### 评分标准
- 优秀：多层防御 + 评估方案 + 追问
- 良好：基本防御 + 常用方法
- 及格：能说出基本方法', 'hard', ARRAY['字节', '阿里', 'Google'], true, 18);

INSERT INTO interview_questions (category, subcategory, question, hint, answer, difficulty, company_tag, is_featured, sort_order) VALUES
('system_design', 'deployment', '如何实现 LLM 推理高可用？', '从降级、熔断、多区域回答', '## 高可用架构

### 降级策略
- 一级降级：主模型→备用模型（OpenAI→Anthropic→自研）
- 二级降级：大模型→小模型
- 三级降级：返回缓存结果

### 熔断机制
- 错误率 > 50% → 熔断 30s
- 超时 > 10s → 快速失败
- 半开状态探测恢复

### 多区域
- 就近路由 + 数据异步复制
- 跨 Region 热备

### 追问链
1. 降级顺序？→ 成本从高到低
2. 熔断恢复？→ 半开探测 + 渐进恢复
3. 多区域一致性？→ 最终一致性 + 冲突解决
4. 如何测试高可用？→ 混沌工程
5. 监控指标？→ 可用性 + 延迟 + 错误率

### 评分标准
- 优秀：完整架构 + 测试方案 + 追问
- 良好：基本架构 + 常用方法
- 及格：能说出基本方法', 'hard', ARRAY['字节', '阿里', 'Google'], true, 19);

-- 项目深挖（5题）
INSERT INTO interview_questions (category, subcategory, question, hint, answer, difficulty, company_tag, is_featured, sort_order) VALUES
('project', 'rag', '描述你做过的一个 RAG 项目', '用 STAR 法则回答，量化结果', '## STAR 法则

### Situation
公司知识库有 10 万+ 文档，员工查找信息效率低，平均每次 15 分钟。

### Task
构建智能问答系统，查找时间降至 30 秒。

### Action
1. 文档解析：Marker + Table Transformer
2. 语义分块：递归 512 tokens + 50 overlap
3. 混合检索：BM25 + 向量 → RRF 融合
4. 重排序：BGE-Reranker-v2-m3
5. 生成：GLM-4 + 引用溯源
6. 评估：RAGAS 四指标

### Result
- Recall@5：65% → 89%
- 查找时间：15min → 30s
- 满意度：3.2 → 4.5
- 幻觉率：15% → 3%

### 面试话术
"我独立完成了从文档解析到检索生成的完整链路，并用 RAGAS 量化评估了检索质量。项目中最大的挑战是表格数据的处理——我用了 Table Transformer 提取结构，使表格问答准确率提升了 40%。"', 'medium', ARRAY['字节', '阿里', '腾讯'], true, 20);

INSERT INTO interview_questions (category, subcategory, question, hint, answer, difficulty, company_tag, is_featured, sort_order) VALUES
('project', 'agent', '描述你做过的一个 Agent 项目', '强调架构设计和挑战', '## 项目概述
多代理协作写作平台，输入主题→自动输出高质量文章。

### 架构设计
- Supervisor Agent：任务分配+进度追踪
- Researcher Agent：搜索+整理资料
- Writer Agent：基于研究写初稿
- Reviewer Agent：审查+给出修改建议
- Editor Agent：根据建议修改终稿

### 技术挑战
1. Agent 间协调 → Supervisor 模式解决
2. 输出质量控制 → Human-in-the-loop
3. 长上下文 → 摘要压缩+分步生成

### 结果
- 文章质量评分 4.2/5（vs 人工 4.5）
- 生产效率提升 5x

### 面试话术
"用 LangGraph 实现了多角色协作，每个 Agent 独立 Prompt，通过共享状态协作。项目中最大的挑战是 Agent 间的协调——我用 Supervisor 模式解决了任务分配问题。"', 'hard', ARRAY['字节', 'OpenAI', 'Anthropic'], true, 21);

INSERT INTO interview_questions (category, subcategory, question, hint, answer, difficulty, company_tag, is_featured, sort_order) VALUES
('project', 'finetuning', '如何评估微调效果？', '多维度对比评估', '## 评估体系

### 能力评估
- lm-eval-harness：MMLU、GSM8K、HumanEval
- 领域测试集：自建 500 题
- 对比：Base模型 vs 微调模型（相同 Prompt）

### 对齐评估
- MT-Bench：多轮对话质量
- AlpacaEval：指令遵循
- 安全性：Safety Bench

### 业务评估
- 线上 A/B 测试
- 用户满意度
- 任务完成率

### 追问链
1. 如何选择评估指标？→ 业务目标驱动
2. 评估结果冲突怎么办？→ 加权综合
3. 如何降低评估成本？→ 采样 + 自动化
4. 微调前后如何对比？→ 控制变量
5. 如何避免过拟合？→ 验证集 + 早停

### 评分标准
- 优秀：多维度 + 成本控制 + 追问
- 良好：基本维度 + 常用方法
- 及格：能说出基本维度', 'hard', ARRAY['字节', '阿里', 'Google'], true, 22);

INSERT INTO interview_questions (category, subcategory, question, hint, answer, difficulty, company_tag, is_featured, sort_order) VALUES
('project', 'evaluation', '如何设计 LLM 应用的评估体系？', '离线+在线+人工三层', '## 评估体系设计

### 离线评估
- 构建测试集（500+ 题，覆盖各场景）
- 自动评估：RAGAS（RAG）/ lm-eval（模型能力）
- 回归测试：每次更新自动跑

### 在线评估
- A/B 测试：新旧版本对比
- 用户反馈：👍/👎 + 文字反馈
- 业务指标：解决率、转人工率、满意度

### 人工评估
- 定期 Bad Case 分析（每周）
- 专家抽检（每月）
- 标注团队维护 Ground Truth

### 追问链
1. 如何构建测试集？→ 真实数据采样 + 人工构造
2. 评估成本太高？→ 采样评估 + 自动化
3. 指标冲突怎么办？→ 业务目标驱动
4. 如何评估长期效果？→ 用户留存 + 复购
5. 如何持续迭代？→ 评估 → 分析 → 优化 → 评估

### 评分标准
- 优秀：三层体系 + 迭代闭环 + 追问
- 良好：基本体系 + 常用方法
- 及格：能说出基本体系', 'hard', ARRAY['字节', '阿里', 'OpenAI'], true, 23);

INSERT INTO interview_questions (category, subcategory, question, hint, answer, difficulty, company_tag, is_featured, sort_order) VALUES
('project', 'deployment', '描述一次你解决技术难题的经历', 'STAR 法则，量化结果', '## STAR 法则

### Situation
项目中 RAG 检索质量不达标，Recall@5 只有 60%。

### Task
在一个月内将 Recall@5 提升到 85% 以上。

### Action
1. 分析 Bad Case：发现主要问题是 Query 和文档语义不匹配
2. 尝试方案：
   - 方案 A：换 Embedding 模型（BGE→GTE）→ 提升 5%
   - 方案 B：加入 BM25 混合检索 → 提升 10%
   - 方案 C：Query 改写（HyDE）→ 提升 8%
3. 组合方案 B+C

### Result
- Recall@5 达到 89%，超额完成目标
- 用户满意度 +30%

### 面试话术
"我通过系统性实验找到了检索质量问题的根因，并通过组合多种方案实现了目标。这个经历让我深刻理解了实验设计的重要性。"', 'medium', ARRAY['字节', '阿里', '腾讯'], false, 24);

-- 编码与算法（3题）
INSERT INTO interview_questions (category, subcategory, question, hint, answer, difficulty, company_tag, is_featured, sort_order) VALUES
('coding', 'algorithm', '实现一个 LRU Cache', 'HashMap + 双向链表', '## 实现

使用 HashMap + 双向链表实现。

- get: O(1)
- put: O(1)

关键：用双向链表维护访问顺序，最近访问放头部。

### 追问链
1. 时间复杂度？→ O(1) for get/put
2. 空间复杂度？→ O(capacity)
3. 如何支持过期时间？→ 增加时间戳 + 定期清理
4. 如何支持并发？→ ReadWrite Lock
5. 如何测试？→ 单元测试 + 并发测试

### 评分标准
- 优秀：完整实现 + 扩展方案 + 追问
- 良好：基本实现 + 复杂度分析
- 及格：能说出基本思路', 'medium', ARRAY['字节', '阿里', '腾讯'], false, 25);

INSERT INTO interview_questions (category, subcategory, question, hint, answer, difficulty, company_tag, is_featured, sort_order) VALUES
('coding', 'algorithm', '实现语义缓存查找', '向量相似度 + 阈值判断', '## 实现

使用 Embedding 模型编码 Query，计算余弦相似度。

核心逻辑：
1. 编码 Query 为向量
2. 与缓存中所有向量计算余弦相似度
3. 如果最高相似度 > 阈值，返回缓存结果
4. 否则返回 None

### 追问链
1. 阈值选择？→ 实验调参，通常 0.9-0.95
2. 模型选择？→ BGE-small（速度快）
3. 缓存容量？→ LRU 淘汰
4. 如何评估效果？→ 命中率 + 延迟降低
5. 如何支持批量？→ 矩阵运算

### 评分标准
- 优秀：完整实现 + 评估方案 + 追问
- 良好：基本实现 + 常用方法
- 及格：能说出基本思路', 'hard', ARRAY['字节', '阿里'], true, 26);

INSERT INTO interview_questions (category, subcategory, question, hint, answer, difficulty, company_tag, is_featured, sort_order) VALUES
('coding', 'algorithm', '实现一个简单的 ReAct Agent', '循环：思考→行动→观察', '## 实现

核心循环：
1. Thought：LLM 思考下一步
2. Action：调用工具
3. Observation：获取结果
4. 循环直到得到最终答案

### 追问链
1. 如何解析 Action？→ 正则或 LLM 结构化输出
2. 错误处理？→ try-except + 重试
3. 如何限制步数？→ 最大步数 + 超时
4. 如何评估质量？→ 任务完成率 + 步数
5. 如何支持多工具？→ 工具注册 + 动态选择

### 评分标准
- 优秀：完整实现 + 扩展方案 + 追问
- 良好：基本实现 + 常用方法
- 及格：能说出基本思路', 'hard', ARRAY['字节', 'OpenAI'], true, 27);

-- 行为面试（2题）
INSERT INTO interview_questions (category, subcategory, question, hint, answer, difficulty, company_tag, is_featured, sort_order) VALUES
('behavioral', 'learning', '你如何跟进最新 AI 技术？', '展示主动学习习惯', '## 回答要点

### 日常跟进
- 论文：每周精读 1-2 篇（arXiv、Papers With Code）
- 博客：OpenAI/Anthropic/LangChain 官方博客
- 开源：关注 GitHub Trending（AI 方向）

### 动手实践
- 每季度完成一个 Side Project
- 参加 Kaggle/HuggingFace 竞赛
- 复现经典论文

### 社区参与
- 技术分享（团队/社区）
- 开源贡献（PR/Issue）
- 技术社群讨论

### 追问链
1. 最近读的论文？→ 简要总结核心贡献
2. 如何将学习应用到工作？→ 具体案例
3. 如何平衡学习和工作？→ 时间管理
4. 推荐的学习资源？→ 按类别推荐
5. 如何验证学习效果？→ 输出（博客/分享）

### 评分标准
- 优秀：系统学习 + 输出成果 + 追问
- 良好：基本学习 + 常用方法
- 及格：能说出基本方法', 'easy', ARRAY['字节', '阿里', 'OpenAI'], false, 28);

INSERT INTO interview_questions (category, subcategory, question, hint, answer, difficulty, company_tag, is_featured, sort_order) VALUES
('behavioral', 'teamwork', '描述一次团队合作解决难题的经历', 'STAR 法则', '## STAR 法则

### Situation
团队 RAG 系统上线后用户反馈答案不准确。

### Task
两周内将准确率从 70% 提升到 85%。

### Action
1. 我主导分析了 100 个 Bad Case
2. 发现主要问题是分块策略不当
3. 提出混合检索 + 重排序方案
4. 协调后端和前端同学一起实现

### Result
准确率提升到 88%，用户满意度 + 30%。

### 追问链
1. 如何协调团队？→ 明确分工 + 定期同步
2. 遇到分歧怎么办？→ 数据驱动 + 实验验证
3. 如何保证进度？→ 里程碑 + 每日站会
4. 如何复盘？→ 成功经验 + 改进点
5. 如何复用经验？→ 文档化 + 分享

### 评分标准
- 优秀：完整 STAR + 团队协作 + 追问
- 良好：基本 STAR + 常用方法
- 及格：能说出基本经历', 'easy', ARRAY['字节', '阿里', '腾讯'], false, 29);
