-- ============================================
-- GLM Learning Hub 3.0 — 深度面试题种子数据
-- 执行前提：migration_v2.sql 已执行
-- ============================================

-- 清理旧面试题
DELETE FROM interview_questions;

-- 深度面试题（29道）
INSERT INTO interview_questions (category, subcategory, question, hint, answer, difficulty, company_tag, is_featured, sort_order) VALUES

-- 系统设计（5题）
('system_design', 'architecture', '设计 ChatGPT 类对话系统',
 '从流式输出、上下文管理、高可用、成本控制四个层面回答',
 '## 标准答案\n\n### 1. 流式输出\n- SSE 实现打字机效果\n- 背压控制：客户端消费慢时降速\n- 断线重连：sequence number 续传\n\n### 2. 上下文窗口管理\n- 滑动窗口：保留最近 N 轮\n- 摘要压缩：旧对话生成摘要\n- Token 计数：tiktoken 精确计算\n\n### 3. 会话存储\n- Redis：热数据（活跃会话），TTL 30min\n- PostgreSQL：冷数据（历史持久化）\n\n### 4. LLM 推理\n- vLLM + PagedAttention（显存利用率 40%→95%）\n- 连续批处理（吞吐 2-4x）\n- 模型路由：简单→小模型，复杂→大模型\n\n### 5. Trade-off\n| 决策 | 选择 | 原因 |\n|------|------|------|\n| 流式协议 | SSE | 简单、自动重连 |\n| 上下文策略 | 混合 | 短对话窗口+长对话摘要 |\n| 模型部署 | 混合 | 核心自研+兜底API |\n\n### 追问\n1. 流量增加10倍？→ 水平扩展 + 降级\n2. 如何控制成本？→ 模型路由 + 缓存 + 批处理\n3. 上下文溢出？→ 压缩 + 分级 + 用户提示\n\n### 评分标准\n- 优秀：完整架构+Trade-off+追问对答如流\n- 良好：核心模块清晰\n- 及格：能说出基本流程',
 'hard', ARRAY['字节', '阿里', '腾讯'], true, 1),

('system_design', 'architecture', '设计智能客服系统',
 '从意图识别、RAG+Agent混合、兜底策略回答',
 '## 标准答案\n\n### 架构\n用户 → 意图识别 → 路由 → {FAQ/RAG/Agent} → 兜底\n\n### 核心模块\n1. **意图识别**：BERT 分类（92%准确率，50ms）\n2. **FAQ 检索**：语义检索 + 置信度阈值\n3. **RAG Pipeline**：解析→分块→检索→生成\n4. **Agent 工具**：订单查询、退款申请\n5. **兜底策略**：置信度低→转人工\n\n### 评估指标\n- 解决率 > 70%\n- 转人工率 < 30%\n- 满意度 > 4/5\n\n### 追问\n1. 知识库更新？→ FAQ实时，文档每日增量\n2. 多语言？→ 多语言BERT + BGE-m3',
 'hard', ARRAY['字节', '美团', '京东'], true, 2),

('system_design', 'architecture', '设计代码助手（Copilot）',
 '从低延迟、跨文件理解、隐私保护回答',
 '## 标准答案\n\n### 核心挑战\n- 延迟 < 200ms\n- 上下文：当前文件 + 相关文件 + 项目结构\n- 隐私：代码不出域\n\n### 推理优化\n- Speculative Decoding：小模型猜+大模型验证（延迟2-3x↓）\n- KV Cache 复用：相同前缀只算一次\n- 分级模型：简单→1-3B，复杂→70B\n\n### 跨文件理解\n1. 项目级 Embedding 索引\n2. Import 依赖分析\n3. AST 调用链分析\n\n### 追问\n1. 大型代码库？→ 分层索引 + 增量更新\n2. 评估？→ 接受率 + 编辑相似度 + 延迟',
 'hard', ARRAY['字节', '微软', 'GitHub'], true, 3),

('system_design', 'architecture', '设计 AI 搜索',
 '从多源融合、摘要生成、成本控制回答',
 '## 标准答案\n\n### 架构\nQuery → Query理解 → 多源检索 → 重排序 → LLM摘要 → 输出\n\n### 多源检索\n- Web：Search API\n- 知识库：Milvus 向量检索\n- 实时数据：API 调用\n\n### 融合算法\n- RRF（Reciprocal Rank Fusion）\n- 时效性加权\n\n### 追问\n1. 虚假信息？→ 多源交叉验证 + 权威性加权\n2. 成本优化？→ 缓存 + 分级模型',
 'hard', ARRAY['字节', 'Google', '百度'], true, 4),

('system_design', 'architecture', '设计多模态 RAG 系统',
 '从多模态解析、统一向量空间、跨模态检索回答',
 '## 标准答案\n\n### 解析\n- 文本：分块 + Embedding\n- 图片：OCR + Caption → 文本\n- 表格：Table Transformer → 描述\n- 视频：关键帧 + ASR\n\n### 统一向量空间\n- BGE-m3：多语言 + 多模态\n- 所有模态转为文本后统一 Embedding\n\n### 追问\n1. 图表理解？→ Chart OCR + 数据提取\n2. 视频处理？→ 关键帧 + 时间戳对齐',
 'expert', ARRAY['字节', 'Google', 'OpenAI'], true, 5),

-- RAG 专项（5题）
('system_design', 'rag', 'RAG 中检索结果不相关怎么办？',
 '从 Query、检索、数据三个维度排查',
 '## 排查清单\n\n### Query 层面\n- Query 改写（HyDE、Query Expansion）\n- 意图识别 → 路由到不同策略\n\n### 检索层面\n- 检查 Embedding 模型是否适合领域\n- 尝试混合检索（加入 BM25）\n- 调整 Top-K 和相似度阈值\n\n### 数据层面\n- 检查文档解析质量\n- 检查分块策略\n- 检查数据清洗\n\n### 追问\n1. HyDE 原理？→ 假答案的向量比 Query 更接近真实文档\n2. 混合检索权重？→ 实验调参，通常 α=0.5-0.7',
 'medium', ARRAY['美团', '京东', '阿里'], false, 6),

('system_design', 'rag', '如何评估 RAG 系统？',
 '从检索、生成、端到端、在线四个层面回答',
 '## 评估体系\n\n| 维度 | 指标 | 工具 |\n|------|------|------|\n| 检索 | Recall@K、MRR | 自定义 |\n| 生成 | Faithfulness、Relevancy | RAGAS |\n| 端到端 | RAGAS 四指标 | RAGAS |\n| 在线 | 用户反馈、A/B | 自定义 |\n\n### RAGAS 指标\n- Faithfulness：正确声明数/总声明数（检测幻觉）\n- Answer Relevancy：反向问题相似度（检测答非所问）\n- Context Recall：可归因声明数/GT 总声明数（检索完整性）\n- Context Precision：有用片段数/总片段数（检索噪声）\n\n### 追问\n1. 如何建立 Ground Truth？→ 人工标注 + 众包\n2. 评估频率？→ 每次更新后离线评估 + 每周人工抽检',
 'hard', ARRAY['字节', '阿里', '腾讯'], true, 7),

('system_design', 'rag', 'RAG 中幻觉如何抑制？',
 '从检索、Prompt、引用、输出、拒答五层防御',
 '## 多层防御\n\n1. **检索层**：提高检索质量（更相关的 Context）\n2. **Prompt 层**：约束"仅基于给定信息回答"\n3. **引用层**：标注答案来源（便于验证）\n4. **输出层**：LLM-as-Judge 检测幻觉\n5. **拒答层**：无相关信息时诚实拒绝\n\n### 追问\n1. 幻觉根因？→ LLM 基于概率生成，可能编造\n2. 引用溯源实现？→ 标注文档 ID + 位置',
 'medium', ARRAY['字节', '阿里', '腾讯'], false, 8),

('system_design', 'rag', '向量数据库如何选型？',
 '从规模、运维、成本三方面对比',
 '## 对比\n\n| 维度 | Milvus | Qdrant | Pinecone |\n|------|--------|--------|----------|\n| 规模 | 十亿级 | 亿级 | 托管 |\n| 部署 | 自托管/K8s | Docker | 全托管 |\n| 运维 | 复杂 | 简单 | 零运维 |\n| 混合检索 | 支持 | 支持 | 有限 |\n\n### 选择建议\n- 大规模生产：Milvus\n- 中小规模：Qdrant\n- 快速验证：Pinecone\n\n### 追问\n1. Milvus 集群？→ etcd + MinIO + Pulsar\n2. Qdrant 性能？→ 单机 100K QPS',
 'medium', ARRAY['字节', '腾讯', '美团'], false, 9),

('system_design', 'rag', '长文档如何处理？',
 '从分块策略、层级检索回答',
 '## 分块策略\n- 固定大小：512 tokens + 50 overlap\n- 递归分块：按段落→句子→词\n- 语义分块：基于 Embedding 相似度\n- 文档结构：按标题/章节\n\n### 层级检索\n1. 先定位章节（粗粒度）\n2. 再定位段落（细粒度）\n3. 返回最相关的 Top-K\n\n### 追问\n1. 分块大小选择？→ 实验对比 256/512/1024 的 Recall@K\n2. 重叠大小？→ 50-100 tokens',
 'medium', ARRAY['阿里', '腾讯'], false, 10),

-- Agent 专项（5题）
('system_design', 'agent', 'ReAct 和 Plan-and-Execute 的区别？',
 '从流程、适合场景、灵活性、效率四方面对比',
 '## 对比\n\n| | ReAct | Plan-and-Execute |\n|---|---|---|\n| 流程 | 思考→行动→观察（循环） | 先规划→再执行 |\n| 适合 | 动态场景 | 步骤明确 |\n| 灵活性 | 高 | 低 |\n| 效率 | 低（每步都思考） | 高（一次规划） |\n\n### 选择\n- 复杂任务用混合（先 Plan 后 ReAct 执行）\n- 简单任务用 Plan-and-Execute\n\n### 追问\n1. 何时用 ReAct？→ 需要动态调整步骤时\n2. 何时用 Plan？→ 任务步骤可预先确定时',
 'medium', ARRAY['字节', '阿里', '腾讯'], false, 11),

('system_design', 'agent', 'Agent 中工具调用失败如何处理？',
 '从重试、降级、兜底三层策略回答',
 '## 三层容错策略\n\n### 1. 重试层\n- 指数退避重试（1s→2s→4s）\n- 最多 3 次\n- 只重试幂等操作\n\n### 2. 降级层\n- 换工具（Plan B）\n- 换模型：大模型→小模型\n- 部分结果：返回已完成+说明失败原因\n\n### 3. 兜底层\n- 转人工\n- 返回缓存结果\n- 诚实拒绝\n\n### 追问\n1. 什么情况下不重试？→ 非幂等操作、参数错误\n2. 幂等设计？→ 唯一请求ID + 服务端去重',
 'hard', ARRAY['字节', '阿里', '腾讯'], true, 12),

('system_design', 'agent', '如何评估 Agent 的任务完成质量？',
 '从结果、路径、工具三个维度回答',
 '## 评估体系\n\n### 结果评估\n- Task Completion：是否完成目标（0/1或分级）\n- Output Quality：输出质量评分（LLM-as-Judge）\n\n### 路径评估（Trajectory）\n- 步骤数：vs 最优路径\n- 回溯次数：是否频繁修正\n- Token 消耗：效率\n\n### 工具评估\n- Tool Selection：是否选对工具\n- Tool Arguments：参数是否正确\n\n### 实践工具\n- LangSmith：自动追踪 + 评估\n- Arize Phoenix：轨迹可视化\n\n### 追问\n1. LLM-as-Judge 偏见？→ 多个Judge投票 + 人工抽检\n2. Ground Truth？→ 人工标注 + 众包',
 'hard', ARRAY['OpenAI', 'Anthropic', '字节'], true, 13),

('system_design', 'agent', 'LangGraph 和 LangChain 的关系？',
 '互补关系，不是替代',
 '## 关系说明\n\n### LangChain\n- 定位：LLM 应用开发框架\n- 核心：Chain（线性调用链）\n- 适合：简单 Pipeline（一次调用→一次输出）\n\n### LangGraph\n- 定位：LangChain 的图编排扩展\n- 核心：Graph（有状态、有分支的工作流）\n- 适合：复杂 Agent（多步骤、有循环、有条件分支）\n\n### 选择\n- 简单 RAG：LangChain 足够\n- 复杂 Agent：必须 LangGraph\n- 多代理协作：LangGraph（状态机+图编排）\n\n### 追问\n1. LangGraph 核心概念？→ State、Node、Edge、Graph\n2. 何时从 LangChain 迁移？→ 需要循环或条件分支时',
 'medium', ARRAY['字节', '阿里', '腾讯'], false, 14),

('system_design', 'agent', '多代理如何协作？',
 '从 Supervisor、共享状态、层级管理三种模式回答',
 '## 协作模式\n\n| 模式 | 特点 | 适合 |\n|------|------|------|\n| Supervisor | 中心化调度 | 任务分工明确 |\n| 共享状态 | 去中心化 | 协作创作 |\n| 层级管理 | 混合 | 复杂项目 |\n\n### Supervisor 模式\n- Supervisor Agent 决定谁执行\n- 每个 Agent 独立 Scratchpad\n\n### 共享状态模式\n- 所有 Agent 共享工作空间\n- 适合：协作创作、头脑风暴\n\n### 追问\n1. 选择依据？→ 任务复杂度 + 协调需求\n2. 通信方式？→ 消息队列 / 共享内存',
 'medium', ARRAY['字节', '阿里'], false, 15),

-- 部署与运维（4题）
('system_design', 'deployment', 'vLLM 的核心优化技术？',
 '从 PagedAttention、连续批处理、缓存、量化回答',
 '## vLLM 核心技术\n\n### 1. PagedAttention\n- 问题：传统 KV Cache 显存浪费（预分配最大长度）\n- 解决：类似 OS 虚拟内存的分页管理\n- 效果：显存利用率 40%→95%\n\n### 2. 连续批处理\n- 传统：一批全部生成完才能接新请求\n- vLLM：每个 token 生成后就可以插入新请求\n- 效果：吞吐量 2-4x\n\n### 3. Prefix Caching\n- 相同 System Prompt 复用 KV Cache\n- 适合：固定 System Prompt 场景\n\n### 4. Speculative Decoding\n- 小模型先猜 N 个 token → 大模型验证\n- 效果：延迟降低 2-3x\n\n### 追问\n1. PagedAttention 原理？→ 将 KV Cache 分成固定大小 Block\n2. 适用场景？→ 所有 LLM 推理场景',
 'hard', ARRAY['字节', '阿里', 'Google'], true, 16),

('system_design', 'deployment', 'LLM 应用如何做成本优化？',
 '从 Prompt、缓存、模型路由三方面优化',
 '## 成本优化策略\n\n### Prompt 优化\n- 压缩 Prompt：去除冗余，只保留关键信息\n- 动态 Few-shot：根据问题复杂度选择示例数\n- System Prompt 缓存（Prompt Caching）\n\n### 缓存策略\n- 精确缓存：相同问题→直接返回（GPT Cache）\n- 语义缓存：相似问题→返回近似答案\n- KV Cache：相同前缀→复用计算\n\n### 模型路由\n- 简单任务→小模型（GPT-4o-mini/GLM-4-Flash）\n- 中等任务→中模型（GPT-4o/GLM-4）\n- 复杂任务→大模型（GPT-4/Claude 3.5）\n\n### 监控\n- Token 用量 Dashboard\n- 单次调用成本追踪\n- 异常消耗告警\n\n### 追问\n1. 缓存命中率？→ 通常 30-50%\n2. 成本节省？→ 通常 40-60%',
 'medium', ARRAY['字节', '阿里', '腾讯'], false, 17),

('system_design', 'deployment', 'LLM 应用的 Prompt Injection 如何防御？',
 '多层防御体系',
 '## 多层防御\n\n### 1. 输入层\n- 长度限制 + 特殊字符过滤\n- 分类器检测（是否包含注入模式）\n- 用户输入与系统 Prompt 隔离\n\n### 2. Prompt 层\n- 明确指令边界（### USER INPUT ###）\n- 角色固化（System Prompt 强约束）\n- Few-shot 示例引导正确行为\n\n### 3. 模型层\n- 安全微调（拒答注入）\n- 输出审核（检测泄露系统 Prompt）\n\n### 4. 工具层\n- 最小权限原则\n- 参数校验\n- 审计日志\n\n### 工具推荐\n- NeMo Guardrails（开源）\n- LlamaGuard（安全分类）\n- LLM Guard（多维度安全）\n\n### 追问\n1. 如何检测注入？→ 分类器 + 规则\n2. 注入后如何处理？→ 拒绝 + 审计 + 告警',
 'hard', ARRAY['字节', '阿里', 'Google'], true, 18),

('system_design', 'deployment', '如何实现 LLM 推理高可用？',
 '从降级、熔断、多区域回答',
 '## 高可用架构\n\n### 降级策略\n- 一级降级：主模型→备用模型（OpenAI→Anthropic→自研）\n- 二级降级：大模型→小模型\n- 三级降级：返回缓存结果\n\n### 熔断机制\n- 错误率 > 50% → 熔断 30s\n- 超时 > 10s → 快速失败\n- 半开状态探测恢复\n\n### 多区域\n- 就近路由 + 数据异步复制\n- 跨 Region 热备\n\n### 追问\n1. 降级顺序？→ 成本从高到低\n2. 熔断恢复？→ 半开探测 + 渐进恢复',
 'hard', ARRAY['字节', '阿里', 'Google'], true, 19),

-- 项目深挖（5题）
('project', 'rag', '描述你做过的一个 RAG 项目',
 '用 STAR 法则回答，量化结果',
 '## STAR 法则\n\n### Situation\n公司知识库有 10 万+ 文档，员工查找信息效率低，平均每次 15 分钟。\n\n### Task\n构建智能问答系统，查找时间降至 30 秒。\n\n### Action\n1. 文档解析：Marker + Table Transformer\n2. 语义分块：递归 512 tokens + 50 overlap\n3. 混合检索：BM25 + 向量 → RRF 融合\n4. 重排序：BGE-Reranker-v2-m3\n5. 生成：GLM-4 + 引用溯源\n6. 评估：RAGAS 四指标\n\n### Result\n- Recall@5：65% → 89%\n- 查找时间：15min → 30s\n- 满意度：3.2 → 4.5\n- 幻觉率：15% → 3%',
 'medium', ARRAY['字节', '阿里', '腾讯'], true, 20),

('project', 'agent', '描述你做过的一个 Agent 项目',
 '强调架构设计和挑战',
 '## 项目概述\n多代理协作写作平台，输入主题→自动输出高质量文章。\n\n### 架构设计\n- Supervisor Agent：任务分配+进度追踪\n- Researcher Agent：搜索+整理资料\n- Writer Agent：基于研究写初稿\n- Reviewer Agent：审查+给出修改建议\n- Editor Agent：根据建议修改终稿\n\n### 技术挑战\n1. Agent 间协调 → Supervisor 模式解决\n2. 输出质量控制 → Human-in-the-loop\n3. 长上下文 → 摘要压缩+分步生成\n\n### 结果\n- 文章质量评分 4.2/5（vs 人工 4.5）\n- 生产效率提升 5x\n\n### 面试话术\n"用 LangGraph 实现了多角色协作，每个 Agent 独立 Prompt，通过共享状态协作。"',
 'hard', ARRAY['字节', 'OpenAI', 'Anthropic'], true, 21),

('project', 'finetuning', '如何评估微调效果？',
 '多维度对比评估',
 '## 评估体系\n\n### 能力评估\n- lm-eval-harness：MMLU、GSM8K、HumanEval\n- 领域测试集：自建 500 题\n- 对比：Base模型 vs 微调模型（相同 Prompt）\n\n### 对齐评估\n- MT-Bench：多轮对话质量\n- AlpacaEval：指令遵循\n- 安全性：Safety Bench\n\n### 业务评估\n- 线上 A/B 测试\n- 用户满意度\n- 任务完成率\n\n### 实验记录\n- 每次实验记录超参、数据量、评估结果\n- 对比不同 LoRA rank、学习率、数据集的效果',
 'hard', ARRAY['字节', '阿里', 'Google'], true, 22),

('project', 'evaluation', '如何设计 LLM 应用的评估体系？',
 '离线+在线+人工三层',
 '## 评估体系设计\n\n### 离线评估\n- 构建测试集（500+ 题，覆盖各场景）\n- 自动评估：RAGAS（RAG）/ lm-eval（模型能力）\n- 回归测试：每次更新自动跑\n\n### 在线评估\n- A/B 测试：新旧版本对比\n- 用户反馈：👍/👎 + 文字反馈\n- 业务指标：解决率、转人工率、满意度\n\n### 人工评估\n- 定期 Bad Case 分析（每周）\n- 专家抽检（每月）\n- 标注团队维护 Ground Truth\n\n### 工具链\n- 追踪：LangSmith + Arize Phoenix\n- 评估：RAGAS + lm-eval-harness\n- 监控：Grafana + 自定义 Dashboard',
 'hard', ARRAY['字节', '阿里', 'OpenAI'], true, 23),

('project', 'deployment', '描述一次你解决技术难题的经历',
 'STAR 法则，量化结果',
 '## STAR 法则\n\n### Situation\n项目中 RAG 检索质量不达标，Recall@5 只有 60%。\n\n### Task\n在一个月内将 Recall@5 提升到 85% 以上。\n\n### Action\n1. 分析 Bad Case：发现主要问题是 Query 和文档语义不匹配\n2. 尝试方案：\n   - 方案 A：换 Embedding 模型（BGE→GTE）→ 提升 5%\n   - 方案 B：加入 BM25 混合检索 → 提升 10%\n   - 方案 C：Query 改写（HyDE）→ 提升 8%\n3. 组合方案 B+C\n\n### Result\n- Recall@5 达到 89%，超额完成目标\n- 用户满意度 +30%',
 'medium', ARRAY['字节', '阿里', '腾讯'], false, 24),

-- 编码与算法（3题）
('coding', 'algorithm', '实现一个 LRU Cache',
 'HashMap + 双向链表',
 '## 实现\n\n使用 HashMap + 双向链表实现。\n\n- get: O(1)\n- put: O(1)\n\n关键：用双向链表维护访问顺序，最近访问放头部。\n\n```python\nclass LRUCache:\n    def __init__(self, capacity: int):\n        self.cap = capacity\n        self.cache = {}\n        self.head = Node(0, 0)\n        self.tail = Node(0, 0)\n        self.head.next = self.tail\n        self.tail.prev = self.head\n\n    def get(self, key: int) -> int:\n        if key in self.cache:\n            node = self.cache[key]\n            self._remove(node)\n            self._add(node)\n            return node.val\n        return -1\n```\n\n### 追问\n1. 时间复杂度？→ O(1) for get/put\n2. 空间复杂度？→ O(capacity)',
 'medium', ARRAY['字节', '阿里', '腾讯'], false, 25),

('coding', 'algorithm', '实现语义缓存查找',
 '向量相似度 + 阈值判断',

-- 编码与算法（3题）
INSERT INTO interview_questions (category, subcategory, question, hint, answer, difficulty, company_tag, is_featured, sort_order) VALUES
('coding', 'algorithm', '实现一个 LRU Cache', 'HashMap + 双向链表', '## 实现

使用 HashMap + 双向链表实现。

- get: O(1)
- put: O(1)

关键：用双向链表维护访问顺序，最近访问放头部。', 'medium', ARRAY['字节', '阿里', '腾讯'], false, 25),

('coding', 'algorithm', '实现语义缓存查找', '向量相似度 + 阈值判断', '## 实现

使用 Embedding 模型编码 Query，计算余弦相似度。

```python
import numpy as np
from sentence_transformers import SentenceTransformer

class SemanticCache:
    def __init__(self, model="BAAI/bge-small-zh", threshold=0.92):
        self.model = SentenceTransformer(model)
        self.threshold = threshold
        self.cache = {}
        self.embeddings = []
        self.queries = []

    def get(self, query: str):
        if not self.cache:
            return None
        q_emb = self.model.encode(query)
        embs = np.array(self.embeddings)
        sims = np.dot(embs, q_emb) / (np.linalg.norm(embs, axis=1) * np.linalg.norm(q_emb))
        best_idx = np.argmax(sims)
        if sims[best_idx] >= self.threshold:
            return self.cache[self.queries[best_idx]]
        return None
```

### 追问
1. 阈值选择？→ 实验调参，通常 0.9-0.95
2. 模型选择？→ BGE-small（速度快）', 'hard', ARRAY['字节', '阿里'], true, 26),

('coding', 'algorithm', '实现一个简单的 ReAct Agent', '循环：思考→行动→观察', '## 实现

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

### 追问
1. 如何解析 Action？→ 正则或 LLM 结构化输出
2. 错误处理？→ try-except + 重试', 'hard', ARRAY['字节', 'OpenAI'], true, 27),

-- 行为面试（2题）
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

### 最近学习
- 正在研究 Graph RAG（微软开源）
- 实验 LangGraph 多代理协作
- 关注 GLM-5 技术报告', 'easy', ARRAY['字节', '阿里', 'OpenAI'], false, 28),

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
准确率提升到 88%，用户满意度 +30%。', 'easy', ARRAY['字节', '阿里', '腾讯'], false, 29);
