-- ============================================
-- GLM Learning Hub 2.0 — 纯净种子数据
-- 表已存在时执行本文件（不会重复创建表）
-- ============================================

-- 清理旧数据
DELETE FROM courses WHERE path_id IN (SELECT id FROM learning_paths WHERE slug IN ('rag-master', 'llm-agent', 'system-design-interview', 'project-portfolio'));
DELETE FROM learning_stages WHERE path_id IN (SELECT id FROM learning_paths WHERE slug IN ('rag-master', 'llm-agent', 'system-design-interview', 'project-portfolio'));
DELETE FROM learning_paths WHERE slug IN ('rag-master', 'llm-agent', 'system-design-interview', 'project-portfolio');
DELETE FROM learning_paths WHERE title IN ('GLM 基础入门', 'API 开发与集成', '模型微调实战', 'Agent 开发进阶');
DELETE FROM interview_questions;
DELETE FROM projects;
DELETE FROM evaluation_metrics;

-- 学习路径
INSERT INTO learning_paths (slug, title, description, category, difficulty, icon, estimated_hours, is_featured, sort_order) VALUES
('rag-master', 'RAG 系统设计与实战', '从 Naive RAG 到 Agentic RAG 的完整链路：文档处理、向量检索、混合搜索、重排序、评估体系。覆盖 RAGAS 指标、HyDE、Graph RAG 等 2025 年最新技术。', 'rag', 'intermediate', '🔍', 40, true, 1),
('llm-agent', 'LLM Agent 开发进阶', 'ReAct、Plan-and-Execute、LangGraph 多代理协作、Function Calling 安全、Agent 评估。涵盖智谱 AutoGLM 和 CogAgent 生态。', 'agent', 'advanced', '🤖', 50, true, 2),
('system-design-interview', '系统设计面试专练', '5 大高频 LLM 场景系统设计：ChatGPT、智能客服、代码助手、文档问答、AI 搜索。每题含架构图、API 设计、Trade-off 讨论。', 'system_design', 'advanced', '🏗️', 30, true, 3),
('project-portfolio', '项目作品集', '5 个梯度项目从易到难，每个含技术栈、架构图、代码、面试话术。证明你能独立交付完整 LLM 应用。', 'portfolio', 'intermediate', '💼', 60, true, 4);

-- 课程：RAG 基础
INSERT INTO courses (path_id, slug, title, description, content, sort_order)
SELECT p.id, 'rag-fundamentals', 'RAG 基础与架构演进', '掌握 RAG 从 Naive 到 Agentic 的完整演进路径',
'# RAG 基础与架构演进

## RAG 架构演进路线

### 1. Naive RAG
用户问题 → Embedding → 向量检索 → 拼接 Prompt → LLM 生成

### 2. Advanced RAG
用户问题 → Query 改写 → 混合检索 → 重排序 → 过滤 → LLM 生成

### 3. Agentic RAG
用户问题 → Agent 规划 → 动态检索 → 工具调用 → 反思 → 生成

### 4. Graph RAG
结合知识图谱 + 向量检索，擅长多跳推理和关系查询

## 核心组件

### 文档处理
- 解析：PDF（Nougat/Marker）、HTML、表格
- 分块：固定大小、递归分块、语义分块、文档结构分块

### 检索层
- Embedding：BGE-large-zh、text-embedding-3-large、m3e-base
- 向量数据库：Milvus、Qdrant、Pinecone
- 混合检索：BM25 + 语义检索 → RRF 融合

### 生成层
- Prompt 模板 + 引用溯源 + 拒答机制

## 面试高频问题

**Q: RAG 中检索结果不相关怎么办？**
- Query 改写（HyDE：生成假答案再检索）
- 扩大检索范围 + 重排序
- Multi-hop 检索（拆分复杂问题）', 1
FROM learning_paths p WHERE p.slug = 'rag-master';

-- 课程：RAG 评估
INSERT INTO courses (path_id, slug, title, description, content, sort_order)
SELECT p.id, 'rag-evaluation', 'RAG 评估体系与 RAGAS 实战', '掌握 RAG 系统评估的完整方法论',
'# RAG 评估体系与 RAGAS 实战

## 评估维度

### 检索评估
- Recall@K：前 K 个结果中包含正确答案的比例
- MRR（Mean Reciprocal Rank）
- MAP（Mean Average Precision）
- NDCG

### 生成评估
- Faithfulness（忠实度）：答案是否基于 Context，无幻觉
- Answer Relevancy（答案相关性）：是否切题
- Context Precision：检索精确率
- Context Recall：检索召回率

## RAGAS 指标详解

| 指标 | 公式 | 用途 |
|------|------|------|
| Faithfulness | 正确声明数/总声明数 | 检测幻觉 |
| Answer Relevancy | 反向问题相似度均值 | 检测答非所问 |
| Context Recall | 可归因声明数/总声明数 | 检索完整性 |
| Context Precision | 有用片段数/总片段数 | 检索噪声 |

## 实战代码

```python
from ragas import evaluate
from ragas.metrics import faithfulness, answer_relevancy, context_recall, context_precision
from datasets import Dataset

evaluation_data = {
    "question": ["什么是 RAG？"],
    "answer": ["RAG 是检索增强生成..."],
    "contexts": [["RAG 全称 Retrieval-Augmented Generation"]],
    "ground_truth": ["RAG 是..."]
}
dataset = Dataset.from_dict(evaluation_data)
result = evaluate(dataset=dataset, metrics=[
    faithfulness, answer_relevancy, context_recall, context_precision
])
```', 2
FROM learning_paths p WHERE p.slug = 'rag-master';

-- 课程：Agent 基础
INSERT INTO courses (path_id, slug, title, description, content, sort_order)
SELECT p.id, 'agent-fundamentals', 'LLM Agent 核心范式与 ReAct', '掌握 Agent 的核心设计模式和 ReAct 实现',
'# LLM Agent 核心范式

## Agent = LLM + 规划 + 记忆 + 工具

## 核心范式

### ReAct（推理+行动交替）
Thought → Action → Observation → Thought → ... → Final Answer

### Plan-and-Execute
Plan: [Step1, Step2, Step3] → Execute Each → Final

### Reflexion
Agent 执行后自我评估，失败时生成反思用于下次尝试

### LATS
Tree of Thought + MCTS + 自我反思

## 工具调用安全
- 输入校验、权限最小化、超时控制、错误回退、审计日志

## 面试高频问题

**Q: Agent 和普通 LLM 调用的区别？**
Agent 有规划、记忆、工具调用能力，能自主完成多步任务。

**Q: ReAct 中工具调用失败怎么处理？**
- 重试 + 指数退避
- 换工具（Plan B）
- 降级返回（部分结果 + 说明）', 1
FROM learning_paths p WHERE p.slug = 'llm-agent';

-- 课程：LangGraph 多代理
INSERT INTO courses (path_id, slug, title, description, content, sort_order)
SELECT p.id, 'langgraph-multi-agent', 'LangGraph 多代理协作实战', '用 LangGraph 构建多角色协作 Agent 系统',
'# LangGraph 多代理协作实战

## LangGraph 核心概念

- State：共享状态，所有节点读写
- Node：执行单元（Agent/Tool/Function）
- Edge：节点间的转移条件
- Graph：完整的工作流

## 多代理模式

### Supervisor 模式
Supervisor 决定谁执行，每个 Agent 独立 Scratchpad

### 协作模式（Shared Scratchpad）
所有 Agent 共享工作空间

### 层级模式
Root Supervisor → 多个 Team → 多个 Agent

## 智谱 Agent 生态

### AutoGLM
- 自主完成 50+ 步骤复杂任务
- 跨应用、跨设备操作
- 自反思 + 自改进能力

### CogAgent
- 18B 视觉语言模型
- 双编码器（1120×1120 高分辨率）
- 纯截图输入，无需 HTML
- GUI 导航 SOTA', 2
FROM learning_paths p WHERE p.slug = 'llm-agent';

-- 课程：系统设计 ChatGPT
INSERT INTO courses (path_id, slug, title, description, content, sort_order)
SELECT p.id, 'llm-system-design-chatgpt', '设计 ChatGPT 类对话系统', 'LLM 对话系统核心架构',
'# 设计 ChatGPT 类对话系统

## 需求
- 功能：文本对话、多轮记忆、流式输出、多模态
- 非功能：首字 < 1s，生成 > 30 tokens/s，99.9% 可用
- 规模：1 亿 DAU，每用户日均 10 轮

## 架构
Client → Gateway(Load Balancer + Auth) → Session Manager → LLM Service(vLLM)

## 核心模块

### 流式输出
- SSE 实现打字机效果
- 背压控制（Backpressure）
- 断线重连（sequence number 续传）

### 上下文窗口管理
- 滑动窗口：保留最近 N 轮
- 摘要压缩：旧对话生成摘要
- Token 计数：tiktoken 精确计算

### 会话存储
- Redis：热数据（活跃会话）
- PostgreSQL：冷数据（历史持久化）

### LLM 推理
- vLLM + PagedAttention
- 连续批处理（Continuous Batching）
- 模型路由（主模型 → 降级模型）

## Trade-off
| 决策 | 选择 | 原因 |
|------|------|------|
| 流式协议 | SSE | 简单、自动重连 |
| 会话存储 | Redis | 低延迟 |
| 上下文策略 | 混合 | 短对话窗口 + 长对话摘要 |', 1
FROM learning_paths p WHERE p.slug = 'system-design-interview';

-- 课程：系统设计 Copilot
INSERT INTO courses (path_id, slug, title, description, content, sort_order)
SELECT p.id, 'llm-system-design-copilot', '设计代码助手（Copilot）', 'AI 代码补全系统核心架构',
'# 设计代码助手（Copilot）

## 核心挑战
- 延迟 < 200ms
- 上下文：当前文件 + 相关文件 + 项目结构
- 接受率 > 30%
- 代码隐私不出域

## 架构
IDE Plugin → Context Builder → Retrieval Engine → Inference(Speculative Decoding) → Post Process

## 核心模块

### 上下文构建
- 当前文件光标前后
- 相关文件检索（项目级 Embedding）
- 项目结构（AST + Tree-sitter）

### 推理优化
- Speculative Decoding：小模型先猜 + 大模型验证
- KV Cache 复用：相同前缀只算一次
- 量化：INT4/FP8 减少显存

### 隐私保护
- 本地 Embedding 模型
- 代码脱敏（变量名/字符串替换）', 2
FROM learning_paths p WHERE p.slug = 'system-design-interview';

-- 课程：项目实战 RAG
INSERT INTO courses (path_id, slug, title, description, content, sort_order)
SELECT p.id, 'portfolio-rag-project', '项目实战：智能 PDF 问答系统', '端到端 RAG 项目',
'# 项目实战：智能 PDF 问答系统

## 技术栈
LangChain + GLM-4 + Milvus + RAGAS + FastAPI + Next.js

## 架构
PDF Upload → 解析 → 分块 → Embedding → Milvus → 检索 → GLM-4 生成 → 引用溯源

## 核心功能
1. PDF 解析（表格/图片/公式）
2. 语义分块（递归 + 重叠）
3. 混合检索（BM25 + 向量 + RRF）
4. 重排序（BGE-Reranker）
5. 引用溯源（标注答案来源页码）
6. 评估报告（RAGAS 四指标）

## 面试话术
"我独立完成了从文档解析到检索生成的完整链路，并用 RAGAS 量化评估了检索质量。项目中最大的挑战是表格数据的处理——我用了 Table Transformer 提取结构，使表格问答准确率提升了 40%。"', 1
FROM learning_paths p WHERE p.slug = 'project-portfolio';

-- 课程：项目实战 Agent
INSERT INTO courses (path_id, slug, title, description, content, sort_order)
SELECT p.id, 'portfolio-agent-project', '项目实战：多代理协作平台', 'LangGraph 多角色 Agent 系统',
'# 项目实战：多代理协作平台

## 技术栈
LangGraph + GLM-4 + PostgreSQL + LangGraph Server + React

## 架构
User Request → Supervisor Agent → {Researcher, Writer, Reviewer} → Shared State → Final Output

## 核心功能
1. Supervisor 调度（任务分配 + 进度追踪）
2. Researcher Agent（搜索 + 整理资料）
3. Writer Agent（基于研究写初稿）
4. Reviewer Agent（审查 + 给出修改建议）
5. Editor Agent（根据建议修改终稿）
6. 可视化：实时展示 Agent 协作过程

## 面试话术
"用 LangGraph 实现了多角色协作，每个 Agent 独立 Prompt，通过共享状态协作。项目中最大的挑战是 Agent 间的协调——我用 Supervisor 模式解决了任务分配问题。"', 2
FROM learning_paths p WHERE p.slug = 'project-portfolio';

-- ============================================
-- 面试题库
-- ============================================
INSERT INTO interview_questions (category, subcategory, question, hint, answer, difficulty, company_tag, is_featured, sort_order) VALUES
('system_design', 'rag', '设计一个企业级 RAG 系统，如何保证检索质量？', '从文档处理、检索、重排序、评估四个层面回答', '## 回答框架\n\n### 文档处理层\n- 高质量解析：PDF 用 Nougat/Marker，表格用 Table Transformer\n- 语义分块：递归分块 + 重叠，保持上下文完整\n- 元数据标注：来源、时间、章节结构\n\n### 检索层\n- 混合检索：BM25（关键词）+ 向量（语义）→ RRF 融合\n- Query 改写：HyDE 生成假答案再检索\n- Multi-hop：复杂问题拆分多次检索\n\n### 重排序层\n- Cross-Encoder Reranker（BGE-Reranker-v2-m3）\n- LLM 重排：让 LLM 判断相关性\n\n### 评估层\n- 离线：RAGAS 四指标 + 自建测试集\n- 在线：用户反馈 + A/B 测试', 'hard', ARRAY['字节', '阿里', '腾讯'], true, 1),

('system_design', 'rag', 'RAG 中检索结果不相关怎么办？', '从 Query、检索、数据三个维度排查', '## 排查清单\n\n### Query 层面\n- Query 改写（HyDE、Query Expansion）\n- 意图识别（分类 → 路由到不同检索策略）\n\n### 检索层面\n- 检查 Embedding 模型是否适合领域\n- 尝试混合检索（加入 BM25）\n- 调整 Top-K 和相似度阈值\n\n### 数据层面\n- 检查文档解析质量\n- 检查分块策略\n- 检查数据清洗', 'medium', ARRAY['美团', '京东'], false, 2),

('system_design', 'agent', '设计一个能自主完成多步骤任务的 Agent', '从规划、工具、记忆、评估四个维度回答', '## 架构设计\n\n### 规划模块\n- ReAct：推理 + 行动交替\n- Plan-and-Execute：先规划再执行\n- Tree of Thought：多路径探索\n\n### 工具模块\n- Function Calling：定义工具 Schema\n- 错误处理：重试 + 降级 + 换工具\n- 安全：输入校验 + 权限最小化 + 审计\n\n### 记忆模块\n- 短期：对话上下文（滑动窗口 + 摘要）\n- 长期：向量存储（历史经验）\n\n### 评估模块\n- Task Completion：是否完成目标\n- Trajectory Quality：路径是否最优\n- Tool Use Correctness：工具选择是否正确', 'hard', ARRAY['字节', 'OpenAI', 'Anthropic'], true, 3),

('system_design', 'agent', 'Agent 中工具调用失败如何处理？', '重试、降级、兜底三层策略', '## 三层容错策略\n\n### 1. 重试层\n- 指数退避重试（1s → 2s → 4s）\n- 最多 3 次\n\n### 2. 降级层\n- 换工具（Plan B）\n- 换模型：大模型 → 小模型\n- 部分结果：返回已完成 + 说明失败原因\n\n### 3. 兜底层\n- 转人工\n- 返回缓存结果\n- 诚实拒绝', 'medium', ARRAY['阿里', '腾讯'], false, 4),

('system_design', 'deployment', '如何设计 LLM 推理服务的高可用架构？', '多模型路由 + 降级 + 熔断', '## 高可用架构\n\n### 模型路由层\n- 智能路由：根据任务类型/复杂度选择模型\n- 成本优化：简单任务用小模型\n\n### 降级策略\n- 一级降级：主模型 → 备用模型\n- 二级降级：大模型 → 小模型\n- 三级降级：返回缓存结果\n\n### 熔断机制\n- 错误率 > 50% → 熔断 30s\n- 超时 > 10s → 快速失败', 'hard', ARRAY['字节', '阿里', 'Google'], true, 5),

('system_design', 'rag', '向量数据库选型：Milvus vs Qdrant vs Pinecone？', '从规模、运维、成本三方面对比', '## 对比\n\n| 维度 | Milvus | Qdrant | Pinecone |\n|------|--------|--------|----------|\n| 规模 | 十亿级 | 亿级 | 托管 |\n| 部署 | 自托管/K8s | 自托管/Docker | 全托管 |\n| 运维 | 复杂 | 简单 | 零运维 |\n\n### 选择建议\n- 大规模生产：Milvus\n- 中小规模：Qdrant\n- 快速验证：Pinecone', 'medium', ARRAY['字节', '腾讯', '美团'], false, 6),

('system_design', 'agent', '如何评估 Agent 的任务完成质量？', '从结果、路径、工具三个维度评估', '## 评估体系\n\n### 结果评估\n- Task Completion：是否完成目标\n- Output Quality：输出质量评分\n\n### 路径评估（Trajectory）\n- 步骤数：是否最优路径\n- 回溯次数：是否频繁修正\n\n### 工具评估\n- Tool Selection：是否选对工具\n- Tool Arguments：参数是否正确', 'hard', ARRAY['OpenAI', 'Anthropic', '字节'], true, 7),

('system_design', 'deployment', 'LLM 应用的 Prompt Injection 如何防御？', '多层防御体系', '## 多层防御\n\n### 输入层\n- 长度限制 + 特殊字符过滤\n- 分类器检测注入模式\n\n### Prompt 层\n- 明确指令边界\n- 角色固化（System Prompt 强约束）\n\n### 模型层\n- 安全微调（拒答注入）\n- 输出审核\n\n### 工具推荐\n- NeMo Guardrails\n- LlamaGuard\n- LLM Guard', 'hard', ARRAY['字节', '阿里', 'Google'], true, 8),

('system_design', 'rag', '如何设计一个支持多模态的 RAG 系统？', '文本、图片、表格、视频统一检索', '## 多模态 RAG 架构\n\n### 文档解析\n- 文本：直接提取\n- 图片：视觉描述（GPT-4V/CogAgent）\n- 表格：结构提取 + 自然语言描述\n\n### 多模态 Embedding\n- CLIP：图文统一向量空间\n- 统一索引：所有模态共享向量空间', 'expert', ARRAY['字节', 'Google', 'OpenAI'], true, 9),

('system_design', 'deployment', 'LLM 应用如何做成本优化？', '从 Prompt、缓存、模型路由三方面优化', '## 成本优化策略\n\n### Prompt 优化\n- 压缩 Prompt：去除冗余\n- System Prompt 缓存（Prompt Caching）\n\n### 缓存策略\n- 精确缓存：相同问题 → 直接返回\n- 语义缓存：相似问题 → 返回近似答案\n\n### 模型路由\n- 简单任务 → 小模型\n- 中等任务 → 中模型\n- 复杂任务 → 大模型', 'medium', ARRAY['字节', '阿里', '腾讯'], false, 10),

('system_design', 'agent', 'LangGraph 和 LangChain 的关系？', '互补关系，不是替代', '## 关系说明\n\n### LangChain\n- 定位：LLM 应用开发框架\n- 核心：Chain（线性调用链）\n- 适合：简单 Pipeline\n\n### LangGraph\n- 定位：LangChain 的图编排扩展\n- 核心：Graph（有状态、有分支的工作流）\n- 适合：复杂 Agent（多步骤、有循环、有条件分支）', 'medium', ARRAY['字节', '阿里', '腾讯'], false, 11),

('project', 'rag', '描述你做过的一个 RAG 项目', '用 STAR 法则回答', '## STAR 法则\n\n### Situation\n公司知识库有 10 万+ 文档，员工查找信息效率低。\n\n### Task\n构建智能问答系统，让员工用自然语言查询知识库。\n\n### Action\n1. 文档解析：PDF/HTML/表格统一处理\n2. 语义分块：递归分块 + 100 token 重叠\n3. 混合检索：BM25 + 向量检索 → RRF 融合\n4. 重排序：BGE-Reranker-v2-m3\n5. 生成：GLM-4 + 引用溯源\n6. 评估：RAGAS 四指标\n\n### Result\n- 检索 Recall@5 从 65% → 89%\n- 用户满意度 4.5/5', 'medium', ARRAY['字节', '阿里', '腾讯'], true, 12),

('project', 'agent', '描述你做过的一个 Agent 项目', '强调架构设计和挑战', '## 项目概述\n多代理协作写作平台，输入主题 → 自动输出高质量文章。\n\n### 架构设计\n- Supervisor Agent：任务分配 + 进度追踪\n- Researcher Agent：搜索 + 整理资料\n- Writer Agent：写初稿\n- Reviewer Agent：审查 + 建议\n- Editor Agent：修改终稿\n\n### 技术挑战\n1. Agent 间协调 → Supervisor 模式解决\n2. 输出质量控制 → Human-in-the-loop', 'hard', ARRAY['字节', 'OpenAI', 'Anthropic'], true, 13),

('coding', 'algorithm', '实现一个 LRU Cache', 'HashMap + 双向链表', '```python\nclass LRUCache:\n    def __init__(self, capacity: int):\n        self.cap = capacity\n        self.cache = {}\n        self.head = Node(0, 0)\n        self.tail = Node(0, 0)\n        self.head.next = self.tail\n        self.tail.prev = self.head\n\n    def get(self, key: int) -> int:\n        if key in self.cache:\n            node = self.cache[key]\n            self._remove(node)\n            self._add(node)\n            return node.val\n        return -1\n\n    def put(self, key: int, value: int) -> None:\n        if key in self.cache:\n            self._remove(self.cache[key])\n        node = Node(key, value)\n        self._add(node)\n        self.cache[key] = node\n        if len(self.cache) > self.cap:\n            lru = self.head.next\n            self._remove(lru)\n            del self.cache[lru.key]\n```', 'medium', ARRAY['字节', '阿里', '腾讯'], false, 14),

### 业务评估
- 线上 A/B 测试
- 用户满意度
- 任务完成率', 'hard', ARRAY['字节', '阿里', 'Google'], true, 15),

('behavioral', 'teamwork', '描述一次你解决技术难题的经历', 'STAR 法则', '## 回答模板

### Situation
项目中 RAG 检索质量不达标，Recall@5 只有 60%。

### Task
在一个月内将 Recall@5 提升到 85% 以上。

### Action
1. 分析 Bad Case
2. 尝试方案
3. 组合方案，最终达到 89%

### Result
Recall@5 达到 89%，超额完成目标。', 'easy', ARRAY['字节', '阿里', '腾讯'], false, 16),

('behavioral', 'learning', '你如何跟进最新 AI 技术？', '展示主动学习习惯', '## 回答要点

### 日常跟进
- 论文：每周精读 1-2 篇
- 博客：OpenAI/Anthropic/LangChain 官方博客

### 动手实践
- 每季度完成一个 Side Project', 'easy', ARRAY['字节', '阿里', 'OpenAI'], false, 17),

('system_design', 'deployment', 'vLLM 的核心优化技术？', 'PagedAttention + 连续批处理', '## vLLM 核心技术

### PagedAttention
- 显存利用率从 ~40% → ~95%

### 连续批处理
- GPU 利用率大幅提升

### 其他优化
- Prefix Caching
- Speculative Decoding', 'hard', ARRAY['字节', '阿里', 'Google'], true, 18),

('project', 'evaluation', '如何设计 LLM 应用的评估体系？', '离线 + 在线 + 人工三层', '## 评估体系

### 离线评估
- 构建测试集（500+ 题）
- 自动评估：RAGAS + lm-eval

### 在线评估
- A/B 测试
- 用户反馈

### 人工评估
- 定期 Bad Case 分析', 'hard', ARRAY['字节', '阿里', 'OpenAI'], true, 19),

('system_design', 'rag', 'RAG 中幻觉如何抑制？', '多管齐下', '## 幻觉抑制策略

### 检索层
- 提高检索质量

### Prompt 层
- 约束：仅基于给定信息回答
- 引用溯源
- 拒答机制

### 输出层
- LLM-as-Judge 检测', 'medium', ARRAY['字节', '阿里', '腾讯'], false, 20);

-- 评估指标百科
INSERT INTO evaluation_metrics (name, description, category, formula, tool, use_case) VALUES
('Faithfulness', '答案是否基于给定 Context，无幻觉', 'rag', '正确声明数 / 总声明数', 'RAGAS', '检测幻觉'),
('Answer Relevancy', '答案是否真正回答了问题', 'rag', '反向问题相似度均值', 'RAGAS', '检测答非所问'),
('Context Recall', '检索结果是否覆盖完整答案所需信息', 'rag', '可归因声明数 / GT 总声明数', 'RAGAS', '检索完整性'),
('Context Precision', '检索结果中有多大比例是有用的', 'rag', '有用片段数 / 总片段数', 'RAGAS', '检索噪声'),
('Recall@K', '前 K 个检索结果中包含正确答案的比例', 'rag', '相关结果是否在 Top-K 中', '自定义', '检索召回率'),
('MRR', '正确答案排名的倒数均值', 'rag', '1/rank_i 的均值', '自定义', '检索排序质量'),
('Task Completion', 'Agent 是否完成目标任务', 'agent', '完成任务数 / 总任务数', '自定义', 'Agent 评估'),
('Tool Use Correctness', '工具选择和参数是否正确', 'agent', '正确调用次数 / 总调用次数', '自定义', '工具使用评估'),
('MMLU', '多任务语言理解', 'model', '正确率', 'lm-eval-harness', '模型通用能力'),
('HumanEval', 'Python 代码生成能力', 'model', 'Pass@K', 'lm-eval-harness', '代码能力'),
('GSM8K', '小学数学应用题', 'model', '正确率', 'lm-eval-harness', '数学推理'),
('MT-Bench', '多轮对话质量', 'model', 'GPT-4 评分 1-10', 'FastChat', '对话质量'),
('Toxicity', '生成内容的有害程度', 'safety', '有害内容比例', 'Perspective API', '安全性');

-- 项目作品集
INSERT INTO projects (slug, title, description, content, tech_stack, difficulty, is_featured, sort_order) VALUES
('pdf-qa', '智能 PDF 问答系统', '端到端 RAG 项目', '# 智能 PDF 问答系统

## 技术栈
LangChain + GLM-4 + Milvus + RAGAS

## 面试话术
"我独立完成了从文档解析到检索生成的完整链路。"',
ARRAY['LangChain', 'GLM-4', 'Milvus', 'RAGAS', 'FastAPI', 'Next.js'], 'intermediate', true, 1),

('multi-agent-writer', '多代理协作写作平台', 'LangGraph 多角色 Agent', '# 多代理协作写作平台

## 技术栈
LangGraph + GLM-4 + PostgreSQL

## 面试话术
"用 LangGraph 实现了多角色协作。"',
ARRAY['LangGraph', 'GLM-4', 'PostgreSQL', 'React'], 'advanced', true, 2),

('code-reviewer', '代码审查 Agent', 'AST 分析 + LLM 理解', '# 代码审查 Agent

## 技术栈
CogAgent + Tree-sitter + GLM-4

## 面试话术
"结合静态分析和 LLM 理解，实现了跨文件的代码审查。"',
ARRAY['CogAgent', 'Tree-sitter', 'GLM-4'], 'advanced', true, 3),

('finetune-platform', '微调实验平台', 'QLoRA + lm-eval-harness', '# 微调实验平台

## 技术栈
QLoRA + lm-eval-harness + W&B

## 面试话术
"用 QLoRA 在消费级 GPU 上微调 7B 模型。"',
ARRAY['QLoRA', 'PEFT', 'lm-eval-harness', 'W&B'], 'advanced', true, 4),

('llm-monitor', 'LLM 应用监控台', '全链路追踪 + 成本分析', '# LLM 应用监控台

## 技术栈
Arize Phoenix + LangSmith + Grafana

## 面试话术
"为 LLM 应用建立了完整的可观测性。"',
ARRAY['Arize Phoenix', 'LangSmith', 'OpenTelemetry', 'Grafana'], 'intermediate', true, 5);
