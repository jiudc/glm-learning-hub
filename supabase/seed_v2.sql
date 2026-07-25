-- ============================================
-- GLM Learning Hub 2.0 — 种子数据 v2
-- 执行 migration_v2.sql 后再执行本文件
-- ============================================

-- ============================================
-- 学习路径（4 大核心模块）
-- ============================================
DELETE FROM learning_stages WHERE path_id IN (SELECT id FROM learning_paths WHERE slug IN ('rag-master', 'llm-agent', 'system-design-interview', 'project-portfolio'));
DELETE FROM learning_paths WHERE slug IN ('rag-master', 'llm-agent', 'system-design-interview', 'project-portfolio');

INSERT INTO learning_paths (slug, title, description, category, difficulty, icon, estimated_hours, is_featured, sort_order) VALUES
('rag-master', 'RAG 系统设计与实战', '从 Naive RAG 到 Agentic RAG 的完整链路：文档处理、向量检索、混合搜索、重排序、评估体系。覆盖 RAGAS 指标、HyDE、Graph RAG 等 2025 年最新技术。', 'rag', 'intermediate', '🔍', 40, true, 1),
('llm-agent', 'LLM Agent 开发进阶', 'ReAct、Plan-and-Execute、LangGraph 多代理协作、Function Calling 安全、Agent 评估。涵盖智谱 AutoGLM 和 CogAgent 生态。', 'agent', 'advanced', '🤖', 50, true, 2),
('system-design-interview', '系统设计面试专练', '5 大高频 LLM 场景系统设计：ChatGPT、智能客服、代码助手、文档问答、AI 搜索。每题含架构图、API 设计、Trade-off 讨论。', 'system_design', 'advanced', '🏗️', 30, true, 3),
('project-portfolio', '项目作品集', '5 个梯度项目从易到难，每个含技术栈、架构图、代码、面试话术。证明你能独立交付完整 LLM 应用。', 'portfolio', 'intermediate', '💼', 60, true, 4);

-- ============================================
-- RAG 模块课程
-- ============================================
INSERT INTO courses (path_id, slug, title, description, content, sort_order)
SELECT p.id, 'rag-fundamentals', 'RAG 基础与架构演进', '掌握 RAG 从 Naive 到 Agentic 的完整演进路径',
E'# RAG 基础与架构演进\n\n## RAG 架构演进路线\n\n### 1. Naive RAG\n用户问题 → Embedding → 向量检索 → 拼接 Prompt → LLM 生成\n\n### 2. Advanced RAG\n用户问题 → Query 改写 → 混合检索 → 重排序 → 过滤 → LLM 生成\n\n### 3. Agentic RAG\n用户问题 → Agent 规划 → 动态检索 → 工具调用 → 反思 → 生成\n\n### 4. Graph RAG\n结合知识图谱 + 向量检索，擅长多跳推理和关系查询\n\n## 核心组件\n\n### 文档处理\n- 解析：PDF（Nougat/Marker）、HTML、表格\n- 分块：固定大小、递归分块、语义分块、文档结构分块\n\n### 检索层\n- Embedding：BGE-large-zh、text-embedding-3-large、m3e-base\n- 向量数据库：Milvus、Qdrant、Pinecone\n- 混合检索：BM25 + 语义检索 → RRF 融合\n\n### 生成层\n- Prompt 模板：Context + Question → Answer\n- 引用溯源 + 拒答机制\n\n## 面试高频问题\n\n**Q: RAG 中检索结果不相关怎么办？**\n- Query 改写（HyDE：生成假答案再检索）\n- 扩大检索范围 + 重排序\n- Multi-hop 检索（拆分复杂问题）\n\n**Q: 如何评估 RAG 系统？**\n- 检索指标：Recall@K、MRR\n- 生成指标：Faithfulness、Answer Relevancy\n- 端到端：RAGAS 框架',
1
FROM learning_paths p WHERE p.slug = 'rag-master';

INSERT INTO courses (path_id, slug, title, description, content, sort_order)
SELECT p.id, 'rag-evaluation', 'RAG 评估体系与 RAGAS 实战', '掌握 RAG 系统评估的完整方法论',
E'# RAG 评估体系与 RAGAS 实战\n\n## 评估维度\n\n### 检索评估\n- Recall@K：前 K 个结果中包含正确答案的比例\n- MRR（Mean Reciprocal Rank）\n- MAP（Mean Average Precision）\n- NDCG\n\n### 生成评估\n- Faithfulness（忠实度）：答案是否基于 Context，无幻觉\n- Answer Relevancy（答案相关性）：是否切题\n- Context Precision：检索精确率\n- Context Recall：检索召回率\n\n## RAGAS 指标详解\n\n| 指标 | 公式 | 用途 |\n|------|------|------|\n| Faithfulness | 正确声明数/总声明数 | 检测幻觉 |\n| Answer Relevancy | 反向问题相似度均值 | 检测答非所问 |\n| Context Recall | 可归因声明数/总声明数 | 检索完整性 |\n| Context Precision | 有用片段数/总片段数 | 检索噪声 |\n\n## 实战代码\n\n```python\nfrom ragas import evaluate\nfrom ragas.metrics import faithfulness, answer_relevancy, context_recall, context_precision\nfrom datasets import Dataset\n\nevaluation_data = {\n    \"question\": ["什么是 RAG？"],\n    "answer": ["RAG 是检索增强生成..."],\n    "contexts": [["RAG 全称 Retrieval-Augmented Generation"]],\n    "ground_truth": ["RAG 是..."]\n}\ndataset = Dataset.from_dict(evaluation_data)\nresult = evaluate(dataset=dataset, metrics=[\n    faithfulness, answer_relevancy, context_recall, context_precision\n])\n```',
2
FROM learning_paths p WHERE p.slug = 'rag-master';

-- ============================================
-- Agent 模块课程
-- ============================================
INSERT INTO courses (path_id, slug, title, description, content, sort_order)
SELECT p.id, 'agent-fundamentals', 'LLM Agent 核心范式与 ReAct', '掌握 Agent 的核心设计模式和 ReAct 实现',
E'# LLM Agent 核心范式\n\n## Agent = LLM + 规划 + 记忆 + 工具\n\n## 核心范式\n\n### ReAct（推理+行动交替）\nThought → Action → Observation → Thought → ... → Final Answer\n\n### Plan-and-Execute\nPlan: [Step1, Step2, Step3] → Execute Each → Final\n\n### Reflexion\nAgent 执行后自我评估，失败时生成反思用于下次尝试\n\n### LATS\nTree of Thought + MCTS + 自我反思\n\n## 工具调用安全\n- 输入校验、权限最小化、超时控制、错误回退、审计日志\n\n## 面试高频问题\n\n**Q: Agent 和普通 LLM 调用的区别？**\nAgent 有规划、记忆、工具调用能力，能自主完成多步任务。\n\n**Q: ReAct 中工具调用失败怎么处理？**\n- 重试 + 指数退避\n- 换工具（Plan B）\n- 降级返回（部分结果 + 说明）',
1
FROM learning_paths p WHERE p.slug = 'llm-agent';

INSERT INTO courses (path_id, slug, title, description, content, sort_order)
SELECT p.id, 'langgraph-multi-agent', 'LangGraph 多代理协作实战', '用 LangGraph 构建多角色协作 Agent 系统',
E'# LangGraph 多代理协作实战\n\n## LangGraph 核心概念\n\n- State：共享状态，所有节点读写\n- Node：执行单元（Agent/Tool/Function）\n- Edge：节点间的转移条件\n- Graph：完整的工作流\n\n## 多代理模式\n\n### Supervisor 模式\nSupervisor 决定谁执行，每个 Agent 独立 Scratchpad\n\n### 协作模式（Shared Scratchpad）\n所有 Agent 共享工作空间\n\n### 层级模式\nRoot Supervisor → 多个 Team → 多个 Agent\n\n## 智谱 Agent 生态\n\n### AutoGLM\n- 自主完成 50+ 步骤复杂任务\n- 跨应用、跨设备操作\n- 自反思 + 自改进能力\n\n### CogAgent\n- 18B 视觉语言模型\n- 双编码器（1120×1120 高分辨率）\n- 纯截图输入，无需 HTML\n- GUI 导航 SOTA\n\n## 面试高频问题\n\n**Q: LangGraph 和 LangChain 的关系？**\nLangGraph 是 LangChain 的图编排扩展，适合有状态、有分支的复杂 Agent。\n\n**Q: 多代理如何协作？**\n- Supervisor 调度（中心化）\n- 共享状态（去中心化）\n- 层级管理（混合）',
2
FROM learning_paths p WHERE p.slug = 'llm-agent';

-- ============================================
-- 系统设计面试课程
-- ============================================
INSERT INTO courses (path_id, slug, title, description, content, sort_order)
SELECT p.id, 'llm-system-design-chatgpt', '设计 ChatGPT 类对话系统', 'LLM 对话系统核心架构',
E'# 设计 ChatGPT 类对话系统\n\n## 需求\n- 功能：文本对话、多轮记忆、流式输出、多模态\n- 非功能：首字 < 1s，生成 > 30 tokens/s，99.9% 可用，100K 并发\n- 规模：1 亿 DAU，每用户日均 10 轮\n\n## 架构\nClient → Gateway(Load Balancer + Auth) → Session Manager → LLM Service(vLLM)\n\n## 核心模块\n\n### 流式输出\n- SSE 实现打字机效果\n- 背压控制（Backpressure）\n- 断线重连（sequence number 续传）\n\n### 上下文窗口管理\n- 滑动窗口：保留最近 N 轮\n- 摘要压缩：旧对话生成摘要\n- Token 计数：tiktoken 精确计算\n- 溢出策略：FIFO / 重要性排序\n\n### 会话存储\n- Redis：热数据（活跃会话）\n- PostgreSQL：冷数据（历史持久化）\n- 30 天过期清理\n\n### LLM 推理\n- vLLM + PagedAttention\n- 连续批处理（Continuous Batching）\n- 模型路由（主模型 → 降级模型）\n\n### 安全合规\n- 输入审核 + 输出审核\n- Prompt Injection 防御\n\n## Trade-off\n| 决策 | 选择 | 原因 |\n|------|------|------|\n| 流式协议 | SSE | 更简单，自动重连 |\n| 会话存储 | Redis | 低延迟 |\n| 上下文策略 | 混合 | 短对话窗口 + 长对话摘要 |\n| 模型部署 | 混合 | 核心自研 + 兜底 API |',
1
FROM learning_paths p WHERE p.slug = 'system-design-interview';

INSERT INTO courses (path_id, slug, title, description, content, sort_order)
SELECT p.id, 'llm-system-design-copilot', '设计代码助手（Copilot）', 'AI 代码补全系统核心架构',
E'# 设计代码助手（Copilot）\n\n## 核心挑战\n- 延迟 < 200ms\n- 上下文：当前文件 + 相关文件 + 项目结构\n- 接受率 > 30%\n- 代码隐私不出域\n\n## 架构\nIDE Plugin → Context Builder → Retrieval Engine → Inference(vLLM + Speculative Decoding) → Post Process\n\n## 核心模块\n\n### 上下文构建\n- 当前文件光标前后\n- 相关文件检索（项目级 Embedding）\n- 项目结构（AST + Tree-sitter）\n- Import 依赖分析\n\n### 推理优化\n- Speculative Decoding：小模型先猜 + 大模型验证\n- KV Cache 复用：相同前缀只算一次\n- 量化：INT4/FP8 减少显存\n\n### 隐私保护\n- 本地 Embedding 模型\n- 代码脱敏（变量名/字符串替换）\n- 私有部署选项\n\n### 评估\n- 接受率（Acceptance Rate）\n- 编辑相似度（Edit Similarity）\n- 延迟分布（P50/P95/P99）\n\n## Trade-off\n| 决策 | 选择 | 原因 |\n|------|------|------|\n| 推理加速 | Speculative Decoding | 延迟降低 2-3x |\n| 上下文 | 混合检索 | 精确 + 语义互补 |\n| 部署 | 混合 | 公有云弹性 + 私有云安全 |',
2
FROM learning_paths p WHERE p.slug = 'system-design-interview';

-- ============================================
-- 项目作品集课程
-- ============================================
INSERT INTO courses (path_id, slug, title, description, content, sort_order)
SELECT p.id, 'portfolio-rag-project', '项目实战：智能 PDF 问答系统', '端到端 RAG 项目',
E'# 项目实战：智能 PDF 问答系统\n\n## 技术栈\n- LangChain + GLM-4 + Milvus + RAGAS\n- Next.js 前端 + FastAPI 后端\n\n## 架构\nPDF Upload → 解析 → 分块 → Embedding → Milvus → 检索 → GLM-4 生成 → 引用溯源\n\n## 核心功能\n1. PDF 解析（表格/图片/公式）\n2. 语义分块（递归 + 重叠）\n3. 混合检索（BM25 + 向量 + RRF）\n4. 重排序（BGE-Reranker）\n5. 引用溯源（标注答案来源页码）\n6. 评估报告（RAGAS 四指标）\n\n## 面试话术\n"我独立完成了从文档解析到检索生成的完整链路，并用 RAGAS 量化评估了检索质量。项目中最大的挑战是表格数据的处理，我用了 Table Transformer 提取结构，使表格问答准确率提升了 40%。"',
1
FROM learning_paths p WHERE p.slug = 'project-portfolio';

INSERT INTO courses (path_id, slug, title, description, content, sort_order)
SELECT p.id, 'portfolio-agent-project', '项目实战：多代理协作平台', 'LangGraph 多角色 Agent 系统',
E'# 项目实战：多代理协作平台\n\n## 技术栈\n- LangGraph + GLM-4 + PostgreSQL\n- React 前端 + LangGraph Server\n\n## 架构\nUser Request → Supervisor Agent → {Researcher, Writer, Reviewer} → Shared State → Final Output\n\n## 核心功能\n1. Supervisor 调度（任务分配 + 进度追踪）\n2. Researcher Agent（搜索 + 整理资料）\n3. Writer Agent（基于研究写初稿）\n4. Reviewer Agent（审查 + 给出修改建议）\n5. Editor Agent（根据建议修改终稿）\n6. 可视化：实时展示 Agent 协作过程\n\n## 面试话术\n"用 LangGraph 实现了多角色协作，每个 Agent 独立 Prompt，通过共享状态协作。项目中最大的挑战是 Agent 间的协调——我用 Supervisor 模式解决了任务分配问题，并用 Human-in-the-loop 保证了输出质量。"',
2
FROM learning_paths p WHERE p.slug = 'project-portfolio';

-- ============================================
-- 面试题库
-- ============================================
INSERT INTO interview_questions (category, subcategory, question, hint, answer, difficulty, company_tag, is_featured, sort_order) VALUES
('system_design', 'rag', '设计一个企业级 RAG 系统，如何保证检索质量？', '从文档处理、检索、重排序、评估四个层面回答',
'## 回答框架\n\n### 1. 文档处理层\n- 高质量解析：PDF 用 Nougat/Marker，表格用 Table Transformer\n- 语义分块：递归分块 + 重叠，保持上下文完整\n- 元数据标注：来源、时间、章节结构\n\n### 2. 检索层\n- 混合检索：BM25（关键词）+ 向量（语义）→ RRF 融合\n- Query 改写：HyDE 生成假答案再检索\n- Multi-hop：复杂问题拆分多次检索\n\n### 3. 重排序层\n- Cross-Encoder Reranker（BGE-Reranker-v2-m3）\n- LLM 重排：让 LLM 判断相关性\n\n### 4. 评估层\n- 离线：RAGAS 四指标 + 自建测试集\n- 在线：用户反馈 + A/B 测试\n- 人工：定期 Bad Case 分析\n\n### Trade-off\n- 检索质量 vs 延迟：重排序增加延迟但提升质量\n- 分块大小：太大噪声多，太小缺上下文', 'hard', ARRAY['字节', '阿里', '腾讯'], true, 1),

('system_design', 'rag', 'RAG 中检索结果不相关怎么办？', '从 Query、检索、数据三个维度排查',
'## 排查清单\n\n### Query 层面\n- Query 改写（HyDE、Query Expansion）\n- 意图识别（分类 → 路由到不同检索策略）\n\n### 检索层面\n- 检查 Embedding 模型是否适合领域\n- 尝试混合检索（加入 BM25）\n- 调整 Top-K 和相似度阈值\n\n### 数据层面\n- 检查文档解析质量（表格/图片是否正确提取）\n- 检查分块策略（是否切断了上下文）\n- 检查数据清洗（噪声/重复/过期数据）', 'medium', ARRAY['美团', '京东'], false, 2),

('system_design', 'agent', '设计一个能自主完成多步骤任务的 Agent', '从规划、工具、记忆、评估四个维度回答',
'## 架构设计\n\n### 规划模块\n- ReAct：推理 + 行动交替\n- Plan-and-Execute：先规划再执行\n- Tree of Thought：多路径探索\n\n### 工具模块\n- Function Calling：定义工具 Schema\n- 错误处理：重试 + 降级 + 换工具\n- 安全：输入校验 + 权限最小化 + 审计\n\n### 记忆模块\n- 短期：对话上下文（滑动窗口 + 摘要）\n- 长期：向量存储（历史经验）\n- 工作记忆：当前任务状态\n\n### 评估模块\n- Task Completion：是否完成目标\n- Trajectory Quality：路径是否最优\n- Tool Use Correctness：工具选择是否正确', 'hard', ARRAY['字节', 'OpenAI', 'Anthropic'], true, 3),

('system_design', 'agent', 'Agent 中工具调用失败如何处理？', '重试、降级、兜底三层策略',
'## 三层容错策略\n\n### 1. 重试层\n- 指数退避重试（1s → 2s → 4s）\n- 最多 3 次\n- 只重试幂等操作\n\n### 2. 降级层\n- 换工具（Plan B）：主工具失败 → 备用工具\n- 换模型：大模型 → 小模型（更快响应）\n- 部分结果：返回已完成的 + 说明失败原因\n\n### 3. 兜底层\n- 转人工：Agent 无法处理 → 人工接管\n- 缓存：返回历史相似结果\n- 诚实拒绝：明确告知无法完成', 'medium', ARRAY['阿里', '腾讯'], false, 4),

('system_design', 'deployment', '如何设计 LLM 推理服务的高可用架构？', '多模型路由 + 降级 + 熔断',
'## 高可用架构\n\n### 模型路由层\n- 智能路由：根据任务类型/复杂度选择模型\n- 成本优化：简单任务用小模型，复杂任务用大模型\n\n### 降级策略\n- 一级降级：主模型 → 备用模型（OpenAI → Anthropic → 自研）\n- 二级降级：大模型 → 小模型\n- 三级降级：返回缓存结果\n\n### 熔断机制\n- 错误率 > 50% → 熔断 30s\n- 超时 > 10s → 快速失败\n- 半开状态探测恢复\n\n### 监控告警\n- 延迟 P50/P95/P99\n- 错误率、Token 消耗、成本\n- GPU 利用率、队列深度', 'hard', ARRAY['字节', '阿里', 'Google'], true, 5),

('system_design', 'rag', '向量数据库选型：Milvus vs Qdrant vs Pinecone？', '从规模、运维、成本三方面对比',
'## 对比\n\n| 维度 | Milvus | Qdrant | Pinecone |\n|------|--------|--------|----------|\n| 规模 | 十亿级 | 亿级 | 托管 |\n| 部署 | 自托管/K8s | 自托管/Docker | 全托管 |\n| 运维 | 复杂 | 简单 | 零运维 |\n| 成本 | 硬件成本 | 适中 | 按量付费 |\n| 混合检索 | 支持 | 支持 | 有限 |\n\n### 选择建议\n- 大规模生产：Milvus（分布式、高性能）\n- 中小规模：Qdrant（简单、灵活）\n- 快速验证：Pinecone（零运维）', 'medium', ARRAY['字节', '腾讯', '美团'], false, 6),

('system_design', 'agent', '如何评估 Agent 的任务完成质量？', '从结果、路径、工具三个维度评估',
'## 评估体系\n\n### 结果评估\n- Task Completion：是否完成目标（二分类或分级）\n- Output Quality：输出质量评分（LLM-as-Judge）\n\n### 路径评估（Trajectory）\n- 步骤数：是否最优路径\n- 回溯次数：是否频繁修正\n- 效率：Token 消耗 vs 任务复杂度\n\n### 工具评估\n- Tool Selection：是否选对工具\n- Tool Arguments：参数是否正确\n- Tool Efficiency：工具调用次数\n\n### 实践工具\n- LangSmith：自动追踪 + 评估\n- Arize Phoenix：轨迹可视化\n- 自定义：规则 + LLM Judge 混合', 'hard', ARRAY['OpenAI', 'Anthropic', '字节'], true, 7),

('system_design', 'deployment', 'LLM 应用的 Prompt Injection 如何防御？', '多层防御体系',
'## 多层防御\n\n### 1. 输入层\n- 长度限制 + 特殊字符过滤\n- 分类器检测（是否包含注入模式）\n- 用户输入与系统 Prompt 隔离\n\n### 2. Prompt 层\n- 明确指令边界（### USER INPUT ###）\n- 角色固化（System Prompt 强约束）\n- Few-shot 示例引导正确行为\n\n### 3. 模型层\n- 安全微调（拒答注入）\n- 输出审核（检测泄露系统 Prompt）\n\n### 4. 工具层\n- 最小权限原则\n- 参数校验\n- 审计日志\n\n### 工具推荐\n- NeMo Guardrails（开源）\n- LlamaGuard（安全分类）\n- LLM Guard（多维度安全）', 'hard', ARRAY['字节', '阿里', 'Google'], true, 8),

('system_design', 'rag', '如何设计一个支持多模态的 RAG 系统？', '文本、图片、表格、视频统一检索',
'## 多模态 RAG 架构\n\n### 文档解析\n- 文本：直接提取\n- 图片：视觉描述（GPT-4V/CogAgent）\n- 表格：结构提取 + 自然语言描述\n- 视频：关键帧提取 + 音频转文字\n\n### 多模态 Embedding\n- CLIP：图文统一向量空间\n- 统一索引：所有模态共享向量空间\n- 分离索引：按模态分别检索后融合\n\n### 检索策略\n- 文本查询 → 文本 + 图片检索\n- 图片查询 → 以图搜图\n- 混合查询 → 多模态融合\n\n### 生成层\n- 多模态 Prompt：文本 + 图片拼接\n- 引用溯源：标注来源（文字段落/图片页码/表格位置）', 'expert', ARRAY['字节', 'Google', 'OpenAI'], true, 9),

('system_design', 'deployment', 'LLM 应用如何做成本优化？', '从 Prompt、缓存、模型路由三方面优化',
'## 成本优化策略\n\n### Prompt 优化\n- 压缩 Prompt：去除冗余，只保留关键信息\n- 动态 Few-shot：根据问题复杂度选择示例数\n- System Prompt 缓存（Prompt Caching）\n\n### 缓存策略\n- 精确缓存：相同问题 → 直接返回（GPT Cache）\n- 语义缓存：相似问题 → 返回近似答案\n- KV Cache：相同前缀 → 复用计算\n\n### 模型路由\n- 简单任务 → 小模型（GPT-4o-mini / GLM-4-Flash）\n- 中等任务 → 中模型（GPT-4o / GLM-4）\n- 复杂任务 → 大模型（GPT-4 / Claude 3.5）\n\n### 监控\n- Token 用量 Dashboard\n- 单次调用成本追踪\n- 异常消耗告警', 'medium', ARRAY['字节', '阿里', '腾讯'], false, 10),

('system_design', 'agent', 'LangGraph 和 LangChain 的关系？', '互补关系，不是替代',
'## 关系说明\n\n### LangChain\n- 定位：LLM 应用开发框架\n- 核心：Chain（线性调用链）\n- 适合：简单 Pipeline（一次调用 → 一次输出）\n\n### LangGraph\n- 定位：LangChain 的图编排扩展\n- 核心：Graph（有状态、有分支的工作流）\n- 适合：复杂 Agent（多步骤、有循环、有条件分支）\n\n### 选择\n- 简单 RAG：LangChain 足够\n- 复杂 Agent：必须 LangGraph\n- 多代理协作：LangGraph（状态机 + 图编排）', 'medium', ARRAY['字节', '阿里', '腾讯'], false, 11),

('project', 'rag', '描述你做过的一个 RAG 项目', '用 STAR 法则回答',
'## STAR 法则回答\n\n### Situation（背景）\n公司知识库有 10 万+ 文档，员工查找信息效率低。\n\n### Task（任务）\n构建智能问答系统，让员工用自然语言查询知识库。\n\n### Action（行动）\n1. 文档解析：PDF/HTML/表格统一处理\n2. 语义分块：递归分块 + 100 token 重叠\n3. 混合检索：BM25 + 向量检索 → RRF 融合\n4. 重排序：BGE-Reranker-v2-m3\n5. 生成：GLM-4 + 引用溯源\n6. 评估：RAGAS 四指标\n\n### Result（结果）\n- 检索 Recall@5 从 65% → 89%\n- 用户满意度 4.5/5\n- 平均查找时间从 15min → 30s', 'medium', ARRAY['字节', '阿里', '腾讯'], true, 12),

('project', 'agent', '描述你做过的一个 Agent 项目', '强调架构设计和挑战',
'## 回答框架\n\n### 项目概述\n多代理协作写作平台，输入主题 → 自动输出高质量文章。\n\n### 架构设计\n- Supervisor Agent：任务分配 + 进度追踪\n- Researcher Agent：搜索 + 整理资料\n- Writer Agent：写初稿\n- Reviewer Agent：审查 + 建议\n- Editor Agent：修改终稿\n\n### 技术挑战\n1. Agent 间协调 → Supervisor 模式解决\n2. 输出质量控制 → Human-in-the-loop\n3. 长上下文 → 摘要压缩 + 分步生成\n\n### 成果\n- 文章质量评分 4.2/5（vs 人工 4.5）\n- 生产效率提升 5x', 'hard', ARRAY['字节', 'OpenAI', 'Anthropic'], true, 13),

('coding', 'algorithm', '实现一个 LRU Cache', 'HashMap + 双向链表',
'```python\nclass LRUCache:\n    def __init__(self, capacity: int):\n        self.cap = capacity\n        self.cache = {}\n        self.head = Node(0, 0)\n        self.tail = Node(0, 0)\n        self.head.next = self.tail\n        self.tail.prev = self.head\n\n    def get(self, key: int) -> int:\n        if key in self.cache:\n            node = self.cache[key]\n            self._remove(node)\n            self._add(node)\n            return node.val\n        return -1\n\n    def put(self, key: int, value: int) -> None:\n        if key in self.cache:\n            self._remove(self.cache[key])\n        node = Node(key, value)\n        self._add(node)\n        self.cache[key] = node\n        if len(self.cache) > self.cap:\n            lru = self.head.next\n            self._remove(lru)\n            del self.cache[lru.key]\n```', 'medium', ARRAY['字节', '阿里', '腾讯'], false, 14),

('coding', 'algorithm', '实现语义缓存查找', '向量相似度 + 阈值判断',
'```python\nimport numpy as np\nfrom sentence_transformers import SentenceTransformer\n\nclass SemanticCache:\n    def __init__(self, model="BAAI/bge-small-zh", threshold=0.92):\n        self.model = SentenceTransformer(model)\n        self.threshold = threshold\n        self.cache = {}  # query -> response\n        self.embeddings = []\n        self.queries = []\n\n    def get(self, query: str):\n        if not self.cache:\n            return None\n        q_emb = self.model.encode(query)\n        embs = np.array(self.embeddings)\n        sims = np.dot(embs, q_emb) / (np.linalg.norm(embs, axis=1) * np.linalg.norm(q_emb))\n        best_idx = np.argmax(sims)\n        if sims[best_idx] >= self.threshold:\n            return self.cache[self.queries[best_idx]]\n        return None\n\n    def put(self, query: str, response: str):\n        self.cache[query] = response\n        self.embeddings.append(self.model.encode(query).tolist())\n        self.queries.append(query)\n```', 'hard', ARRAY['字节', '阿里'], true, 15),

('project', 'finetuning', '如何评估微调效果？', '多维度对比评估',
'## 评估体系\n\n### 能力评估\n- lm-eval-harness：MMLU、GSM8K、HumanEval、BBH\n- 领域测试集：自建 500 题\n- 对比：Base模型 vs 微调模型（相同 Prompt）\n\n### 对齐评估\n- MT-Bench：多轮对话质量\n- AlpacaEval：指令遵循\n- 安全性：Safety Bench\n\n### 业务评估\n- 线上 A/B 测试\n- 用户满意度\n- 任务完成率\n\n### 实验记录\n- 每次实验记录超参、数据量、评估结果\n- 对比不同 LoRA rank、学习率、数据集的效果', 'hard', ARRAY['字节', '阿里', 'Google'], true, 16),

('behavioral', 'teamwork', '描述一次你解决技术难题的经历', 'STAR 法则',
'## 回答模板\n\n### Situation\n项目中 RAG 检索质量不达标，Recall@5 只有 60%。\n\n### Task\n在一个月内将 Recall@5 提升到 85% 以上。\n\n### Action\n1. 分析 Bad Case：发现主要问题是 Query 和文档语义不匹配\n2. 尝试方案：\n   - 方案 A：换 Embedding 模型（BGE → GTE）→ 提升 5%\n   - 方案 B：加入 BM25 混合检索 → 提升 10%\n   - 方案 C：Query 改写（HyDE）→ 提升 8%\n3. 组合方案 B + C，最终达到 89%\n\n### Result\nRecall@5 达到 89%，超额完成目标。', 'easy', ARRAY['字节', '阿里', '腾讯'], false, 17),

('behavioral', 'learning', '你如何跟进最新 AI 技术？', '展示主动学习习惯',
'## 回答要点\n\n### 日常跟进\n- 论文：每周精读 1-2 篇（arXiv、Papers With Code）\n- 博客：OpenAI/Anthropic/LangChain 官方博客\n- 开源：关注 GitHub Trending（AI 方向）\n\n### 动手实践\n- 每季度完成一个 Side Project\n- 参加 Kaggle/HuggingFace 竞赛\n- 复现经典论文\n\n### 社区参与\n- 技术分享（团队/社区）\n- 开源贡献（PR/Issue）\n- 技术社群讨论\n\n### 最近学习\n- 正在研究 Graph RAG（微软开源）\n- 实验 LangGraph 多代理协作\n- 关注 GLM-5 技术报告', 'easy', ARRAY['字节', '阿里', 'OpenAI'], false, 18),

('system_design', 'deployment', 'vLLM 的核心优化技术？', 'PagedAttention + 连续批处理',
'## vLLM 核心技术\n\n### PagedAttention\n- 问题：传统 KV Cache 显存浪费（预分配最大长度，实际只用一部分）\n- 解决：类似 OS 虚拟内存的分页管理\n  - KV Cache 分成固定大小 Block（16 tokens）\n  - 按需分配，不连续存储\n  - 显存利用率从 ~40% → ~95%\n\n### 连续批处理（Continuous Batching）\n- 传统：一批全部生成完才能接新请求\n- vLLM：每个 token 生成后就可以插入新请求\n- GPU 利用率大幅提升\n\n### 其他优化\n- Prefix Caching：相同 System Prompt 复用 KV Cache\n- Speculative Decoding：小模型猜 + 大模型验证\n- 量化：FP8/INT4/GPTQ/AWQ\n- 分布式：Tensor Parallelism + Pipeline Parallelism\n\n### 性能\n- 吞吐量提升 2-4x vs HuggingFace Pipeline\n- 支持 200+ 模型架构', 'hard', ARRAY['字节', '阿里', 'Google'], true, 19),

('project', 'evaluation', '如何设计 LLM 应用的评估体系？', '离线 + 在线 + 人工三层',
'## 评估体系设计\n\n### 离线评估\n- 构建测试集（500+ 题，覆盖各场景）\n- 自动评估：RAGAS（RAG）/ lm-eval（模型能力）\n- 回归测试：每次更新自动跑\n\n### 在线评估\n- A/B 测试：新旧版本对比\n- 用户反馈：👍/👎 + 文字反馈\n- 业务指标：解决率、转人工率、满意度\n\n### 人工评估\n- 定期 Bad Case 分析（每周）\n- 专家抽检（每月）\n- 标注团队维护 Ground Truth\n\n### 工具链\n- 追踪：LangSmith + Arize Phoenix\n- 评估：RAGAS + lm-eval-harness\n- 监控：Grafana + 自定义 Dashboard\n\n### 关键指标\n| 层级 | 指标 |\n|------|------|\n| 检索 | Recall@K、MRR |\n| 生成 | Faithfulness、Relevancy |\n| 端到端 | 任务完成率 |\n| 业务 | 满意度、成本 |', 'hard', ARRAY['字节', '阿里', 'OpenAI'], true, 20);

-- ============================================
-- 评估指标百科
-- ============================================
INSERT INTO evaluation_metrics (name, description, category, formula, tool, use_case) VALUES
('Faithfulness', '答案是否基于给定 Context，无幻觉', 'rag', '正确声明数 / 总声明数', 'RAGAS', '检测 RAG 答案是否编造信息'),
('Answer Relevancy', '答案是否真正回答了问题', 'rag', '反向生成问题与原始问题相似度均值', 'RAGAS', '检测答非所问'),
('Context Recall', '检索结果是否覆盖完整答案所需信息', 'rag', '可归因声明数 / Ground Truth 总声明数', 'RAGAS', '评估检索完整性'),
('Context Precision', '检索结果中有多大比例是有用的', 'rag', '有用片段数 / 总片段数', 'RAGAS', '评估检索噪声'),
('Recall@K', '前 K 个检索结果中包含正确答案的比例', 'rag', '相关结果是否在 Top-K 中', '自定义', '检索召回率'),
('MRR', '正确答案排名的倒数均值', 'rag', '1/rank_i 的均值', '自定义', '检索排序质量'),
('Task Completion', 'Agent 是否完成目标任务', 'agent', '完成任务数 / 总任务数', '自定义', 'Agent 端到端评估'),
('Tool Use Correctness', '工具选择和参数是否正确', 'agent', '正确调用次数 / 总调用次数', '自定义', 'Agent 工具使用评估'),
('Trajectory Efficiency', 'Agent 路径是否最优', 'agent', '最优步数 / 实际步数', '自定义', 'Agent 路径优化评估'),
('MMLU', '多任务语言理解（57 个科目）', 'model', '正确率', 'lm-eval-harness', '模型通用能力评估'),
('HumanEval', 'Python 代码生成能力', 'model', 'Pass@K', 'lm-eval-harness', '模型代码能力评估'),
('GSM8K', '小学数学应用题', 'model', '正确率', 'lm-eval-harness', '模型数学推理评估'),
('MT-Bench', '多轮对话质量', 'model', 'GPT-4 评分 1-10', 'FastChat', '对话质量评估'),
('Toxicity', '生成内容的有害程度', 'safety', '有害内容比例', 'Perspective API + LlamaGuard', '安全性评估'),
('Prompt Injection', '系统 Prompt 泄露程度', 'safety', '泄露率', '自定义', '安全防护评估');

-- ============================================
-- 项目作品集
-- ============================================
INSERT INTO projects (slug, title, description, content, tech_stack, difficulty, is_featured, sort_order) VALUES
('pdf-qa', '智能 PDF 问答系统', '端到端 RAG 项目：上传 PDF → 语义问答 + 引用溯源 + RAGAS 评估报告',
'# 智能 PDF 问答系统\n\n## 技术栈\nLangChain + GLM-4 + Milvus + RAGAS + FastAPI + Next.js\n\n## 架构\n```\nPDF Upload → 解析(Nougat) → 分块(递归) → Embedding(BGE) → Milvus\n                                                                    ↓\nUser Query → Query改写(HyDE) → 混合检索(BM25+向量) → 重排序 → GLM-4 → 答案+引用\n```\n\n## 核心功能\n1. PDF 解析：文字 + 表格(Table Transformer) + 图片(OCR)\n2. 语义分块：递归分块 512 tokens + 100 overlap\n3. 混合检索：BM25 + 向量检索 → RRF 融合\n4. 重排序：BGE-Reranker-v2-m3\n5. 引用溯源：标注答案来源页码\n6. 评估报告：RAGAS 四指标自动计算\n\n## 项目结构\n```\n/pdf-qa\n  /backend\n    main.py          # FastAPI 服务\n    rag_chain.py     # RAG Pipeline\n    evaluation.py    # RAGAS 评估\n  /frontend\n    pages/           # Next.js 页面\n    components/      # React 组件\n```\n\n## 面试话术\n"我独立完成了从文档解析到检索生成的完整链路，并用 RAGAS 量化评估了检索质量。项目中最大的挑战是表格数据的处理——我用了 Table Transformer 提取结构，使表格问答准确率提升了 40%。通过混合检索 + 重排序，Recall@5 从 65% 提升到 89%。"',
ARRAY['LangChain', 'GLM-4', 'Milvus', 'RAGAS', 'FastAPI', 'Next.js'], 'intermediate', true, 1),

('multi-agent-writer', '多代理协作写作平台', 'LangGraph 多角色 Agent：研究员+写手+审稿人协作产出文章',
'# 多代理协作写作平台\n\n## 技术栈\nLangGraph + GLM-4 + PostgreSQL + LangGraph Server + React\n\n## 架构\n```\nUser Request → Supervisor Agent\n              ├→ Researcher Agent (搜索+整理)\n              ├→ Writer Agent (写初稿)\n              ├→ Reviewer Agent (审查+建议)\n              └→ Editor Agent (修改终稿)\n```\n\n## 核心功能\n1. Supervisor 调度：任务分配 + 进度追踪\n2. Researcher：搜索资料 + 整理大纲\n3. Writer：根据研究写初稿\n4. Reviewer：审查质量 + 给出修改建议\n5. Editor：根据建议修改终稿\n6. 可视化：实时展示 Agent 协作过程\n\n## LangGraph 实现\n```python\nfrom langgraph.graph import StateGraph, END\n\nclass WritingState(TypedDict):\n    topic: str\n    research: str\n    draft: str\n    review: str\n    final: str\n\ngraph = StateGraph(WritingState)\ngraph.add_node("researcher", researcher_node)\ngraph.add_node("writer", writer_node)\ngraph.add_node("reviewer", reviewer_node)\ngraph.add_node("editor", editor_node)\ngraph.add_edge("researcher", "writer")\ngraph.add_edge("writer", "reviewer")\ngraph.add_edge("reviewer", "editor")\ngraph.add_edge("editor", END)\n\napp = graph.compile()\nresult = app.invoke({"topic": "LLM Agent 最新进展"})\n```\n\n## 面试话术\n"用 LangGraph 实现了多角色协作，每个 Agent 独立 Prompt，通过共享状态协作。项目中最大的挑战是 Agent 间的协调——我用 Supervisor 模式解决了任务分配问题，并用 Human-in-the-loop 保证了输出质量。"',
ARRAY['LangGraph', 'GLM-4', 'PostgreSQL', 'React', 'LangGraph Server'], 'advanced', true, 2),

('code-reviewer', '代码审查 Agent', 'AST 分析 + LLM 理解，跨文件代码审查 + 自动修复建议',
'# 代码审查 Agent\n\n## 技术栈\nCogAgent + Tree-sitter + Function Calling + GLM-4\n\n## 核心功能\n1. AST 解析：Tree-sitter 分析代码结构\n2. 跨文件理解：Import 依赖 + 调用链分析\n3. LLM 审查：安全/性能/可读性/最佳实践\n4. 修复建议：具体到行号的修改方案\n5. 自动修复：简单问题自动生成 PR\n\n## 面试话术\n"结合静态分析和 LLM 理解，实现了跨文件的代码审查 Agent。关键创新是用 AST 提供结构化上下文，避免纯 LLM 审查的遗漏问题。"',
ARRAY['CogAgent', 'Tree-sitter', 'GLM-4', 'Function Calling'], 'advanced', true, 3),

('finetune-platform', '微调实验平台', 'QLoRA 微调 + lm-eval-harness 自动评估，参数高效微调实验',
'# 微调实验平台\n\n## 技术栈\nQLoRA (PEFT) + lm-eval-harness + Weights & Biases + GLM-4-9B\n\n## 核心功能\n1. 数据管理：数据集上传 + 清洗 + 格式化\n2. 微调实验：QLoRA 参数配置 + 训练\n3. 自动评估：lm-eval-harness 跑分\n4. 对比分析：Base vs 微调后多维度对比\n5. 实验追踪：W&B 记录每次实验\n\n## 面试话术\n"用 QLoRA 在消费级 GPU（24GB）上微调 7B 模型，用 lm-eval-harness 量化对比微调前后效果。通过实验发现，在领域数据上微调 7B 模型可以接近通用 70B 模型的效果。"',
ARRAY['QLoRA', 'PEFT', 'lm-eval-harness', 'W&B', 'GLM-4-9B'], 'advanced', true, 4),

('llm-monitor', 'LLM 应用监控台', '全链路追踪 + Token 成本分析 + 延迟监控',
'# LLM 应用监控台\n\n## 技术栈\nArize Phoenix + LangSmith + OpenTelemetry + Grafana\n\n## 核心功能\n1. 全链路追踪：每次 LLM 调用的完整链路\n2. Token 成本：按用户/按功能/按时间统计\n3. 延迟分析：P50/P95/P99 + 趋势\n4. 质量监控：幻觉率 + 相关性 + 用户反馈\n5. 告警：异常消耗 + 质量下降自动告警\n\n## 面试话术\n"为 LLM 应用建立了完整的可观测性，能追踪每次调用的完整链路和成本。通过监控发现 20% 的请求消耗了 80% 的成本，优化后成本降低 60%。"',
ARRAY['Arize Phoenix', 'LangSmith', 'OpenTelemetry', 'Grafana'], 'intermediate', true, 5);

-- ============================================
-- 动手实验
-- ============================================
INSERT INTO labs (course_id, title, description, difficulty, estimated_minutes, starter_code, solution_code, environment, sort_order)
SELECT
  c.id,
  '构建你的第一个 RAG Pipeline',
  '用 LangChain + 向量数据库构建完整 RAG 问答系统',
  'easy',
  60,
  '# starter_code.py\nfrom langchain.document_loaders import TextLoader\nfrom langchain.text_splitter import RecursiveCharacterTextSplitter\nfrom langchain.embeddings import HuggingFaceEmbeddings\nfrom langchain.vectorstores import Chroma\nfrom langchain.chains import RetrievalQA\nfrom langchain.llms import OpenAI\n\n# 1. 加载文档\nloader = TextLoader("data.txt")\ndocuments = loader.load()\n\n# 2. 分块\ntext_splitter = RecursiveCharacterTextSplitter(\n    chunk_size=512,\n    chunk_overlap=50\n)\nchunks = text_splitter.split_documents(documents)\n\n# 3. TODO: 初始化 Embedding 模型\n# embeddings = HuggingFaceEmbeddings(model_name="...")\n\n# 4. TODO: 构建向量存储\n# vectorstore = Chroma.from_documents(chunks, embeddings)\n\n# 5. TODO: 构建 RAG Chain\n# qa_chain = RetrievalQA.from_chain_type(...)\n\n# 6. 查询\nresult = qa_chain.run("什么是 RAG？")\nprint(result)',
  '# solution_code.py\nfrom langchain.document_loaders import TextLoader\nfrom langchain.text_splitter import RecursiveCharacterTextSplitter\nfrom langchain.embeddings import HuggingFaceEmbeddings\nfrom langchain.vectorstores import Chroma\nfrom langchain.chains import RetrievalQA\nfrom langchain.llms import OpenAI\n\nloader = TextLoader("data.txt")\ndocuments = loader.load()\n\ntext_splitter = RecursiveCharacterTextSplitter(\n    chunk_size=512, chunk_overlap=50\n)\nchunks = text_splitter.split_documents(documents)\n\nembeddings = HuggingFaceEmbeddings(\n    model_name="BAAI/bge-small-zh-v1.5"\n)\nvectorstore = Chroma.from_documents(chunks, embeddings)\n\nqa_chain = RetrievalQA.from_chain_type(\n    llm=OpenAI(),\n    chain_type="stuff",\n    retriever=vectorstore.as_retriever(search_kwargs={"k": 3})\n)\n\nresult = qa_chain.run("什么是 RAG？")\nprint(result)',
  '{"packages": ["langchain", "chromadb", "sentence-transformers"], "env": {"OPENAI_API_KEY": "sk-..."}, "gpu": false}'::jsonb,
  1
FROM courses c WHERE c.slug = 'rag-fundamentals';
