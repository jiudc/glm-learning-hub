-- GLM Learning Hub 2.0 — Final Seed Data
-- Uses dollar quoting to avoid escaping issues

DELETE FROM courses WHERE path_id IN (SELECT id FROM learning_paths WHERE slug IN ('rag-master', 'llm-agent', 'system-design-interview', 'project-portfolio'));
DELETE FROM learning_stages WHERE path_id IN (SELECT id FROM learning_paths WHERE slug IN ('rag-master', 'llm-agent', 'system-design-interview', 'project-portfolio'));
DELETE FROM learning_paths WHERE slug IN ('rag-master', 'llm-agent', 'system-design-interview', 'project-portfolio');
DELETE FROM interview_questions;
DELETE FROM projects;
DELETE FROM evaluation_metrics;

INSERT INTO learning_paths (slug, title, description, category, difficulty, icon, estimated_hours, is_featured, sort_order) VALUES
('rag-master', 'RAG 系统设计与实战', '从 Naive RAG 到 Agentic RAG 的完整链路', 'rag', 'intermediate', '🔍', 40, true, 1),
('llm-agent', 'LLM Agent 开发进阶', 'ReAct、LangGraph 多代理协作、Function Calling 安全', 'agent', 'advanced', '🤖', 50, true, 2),
('system-design-interview', '系统设计面试专练', '5 大高频 LLM 场景系统设计', 'system_design', 'advanced', '🏗️', 30, true, 3),
('project-portfolio', '项目作品集', '5 个梯度项目从易到难', 'portfolio', 'intermediate', '💼', 60, true, 4);

INSERT INTO courses (path_id, slug, title, description, content, sort_order)
SELECT p.id, 'rag-fundamentals', 'RAG 基础与架构演进', '掌握 RAG 从 Naive 到 Agentic 的完整演进路径', $$# RAG 基础与架构演进

## 核心内容

这是一门关于 RAG 基础与架构演进 的完整课程。

## 学习目标

- 掌握核心概念
- 能够独立设计和实现
- 通过大厂面试$$, 1
FROM learning_paths p WHERE p.slug = 'rag-master';

INSERT INTO courses (path_id, slug, title, description, content, sort_order)
SELECT p.id, 'rag-evaluation', 'RAG 评估体系与 RAGAS 实战', '掌握 RAG 系统评估的完整方法论', $$# RAG 评估体系与 RAGAS 实战

## 核心内容

这是一门关于 RAG 评估体系与 RAGAS 实战 的完整课程。

## 学习目标

- 掌握核心概念
- 能够独立设计和实现
- 通过大厂面试$$, 2
FROM learning_paths p WHERE p.slug = 'rag-master';

INSERT INTO courses (path_id, slug, title, description, content, sort_order)
SELECT p.id, 'agent-fundamentals', 'LLM Agent 核心范式与 ReAct', '掌握 Agent 的核心设计模式', $$# LLM Agent 核心范式与 ReAct

## 核心内容

这是一门关于 LLM Agent 核心范式与 ReAct 的完整课程。

## 学习目标

- 掌握核心概念
- 能够独立设计和实现
- 通过大厂面试$$, 1
FROM learning_paths p WHERE p.slug = 'llm-agent';

INSERT INTO courses (path_id, slug, title, description, content, sort_order)
SELECT p.id, 'langgraph-multi-agent', 'LangGraph 多代理协作实战', '用 LangGraph 构建多角色协作 Agent', $$# LangGraph 多代理协作实战

## 核心内容

这是一门关于 LangGraph 多代理协作实战 的完整课程。

## 学习目标

- 掌握核心概念
- 能够独立设计和实现
- 通过大厂面试$$, 2
FROM learning_paths p WHERE p.slug = 'llm-agent';

INSERT INTO courses (path_id, slug, title, description, content, sort_order)
SELECT p.id, 'llm-system-design-chatgpt', '设计 ChatGPT 类对话系统', 'LLM 对话系统核心架构', $$# 设计 ChatGPT 类对话系统

## 核心内容

这是一门关于 设计 ChatGPT 类对话系统 的完整课程。

## 学习目标

- 掌握核心概念
- 能够独立设计和实现
- 通过大厂面试$$, 1
FROM learning_paths p WHERE p.slug = 'system-design-interview';

INSERT INTO courses (path_id, slug, title, description, content, sort_order)
SELECT p.id, 'llm-system-design-copilot', '设计代码助手（Copilot）', 'AI 代码补全系统核心架构', $$# 设计代码助手（Copilot）

## 核心内容

这是一门关于 设计代码助手（Copilot） 的完整课程。

## 学习目标

- 掌握核心概念
- 能够独立设计和实现
- 通过大厂面试$$, 2
FROM learning_paths p WHERE p.slug = 'system-design-interview';

INSERT INTO courses (path_id, slug, title, description, content, sort_order)
SELECT p.id, 'portfolio-rag-project', '项目实战：智能 PDF 问答系统', '端到端 RAG 项目', $$# 项目实战：智能 PDF 问答系统

## 核心内容

这是一门关于 项目实战：智能 PDF 问答系统 的完整课程。

## 学习目标

- 掌握核心概念
- 能够独立设计和实现
- 通过大厂面试$$, 1
FROM learning_paths p WHERE p.slug = 'project-portfolio';

INSERT INTO courses (path_id, slug, title, description, content, sort_order)
SELECT p.id, 'portfolio-agent-project', '项目实战：多代理协作平台', 'LangGraph 多角色 Agent', $$# 项目实战：多代理协作平台

## 核心内容

这是一门关于 项目实战：多代理协作平台 的完整课程。

## 学习目标

- 掌握核心概念
- 能够独立设计和实现
- 通过大厂面试$$, 2
FROM learning_paths p WHERE p.slug = 'project-portfolio';

-- 面试题库
INSERT INTO interview_questions (category, subcategory, question, hint, answer, difficulty, company_tag, is_featured, sort_order) VALUES
('system_design', 'rag', '设计一个企业级 RAG 系统，如何保证检索质量？', '从文档处理、检索、重排序、评估四个层面回答', '## 回答框架

### 文档处理层
- 高质量解析：PDF 用 Nougat/Marker
- 语义分块：递归分块 + 重叠

### 检索层
- 混合检索：BM25 + 向量 → RRF 融合
- Query 改写：HyDE

### 重排序层
- Cross-Encoder Reranker

### 评估层
- 离线：RAGAS 四指标
- 在线：A/B 测试', 'hard', ARRAY['字节', '阿里', '腾讯'], true, 1),
('system_design', 'rag', 'RAG 中检索结果不相关怎么办？', '从 Query、检索、数据三个维度排查', '## 排查清单

### Query 层面
- Query 改写（HyDE、Query Expansion）

### 检索层面
- 检查 Embedding 模型
- 尝试混合检索

### 数据层面
- 检查文档解析质量
- 检查分块策略', 'medium', ARRAY['美团', '京东'], false, 2),
('system_design', 'agent', '设计一个能自主完成多步骤任务的 Agent', '从规划、工具、记忆、评估四个维度回答', '## 架构设计

### 规划模块
- ReAct：推理 + 行动交替
- Plan-and-Execute：先规划再执行

### 工具模块
- Function Calling
- 错误处理：重试 + 降级

### 记忆模块
- 短期：对话上下文
- 长期：向量存储

### 评估模块
- Task Completion
- Trajectory Quality', 'hard', ARRAY['字节', 'OpenAI', 'Anthropic'], true, 3),
('system_design', 'agent', 'Agent 中工具调用失败如何处理？', '重试、降级、兜底三层策略', '## 三层容错策略

### 1. 重试层
- 指数退避重试（1s → 2s → 4s）

### 2. 降级层
- 换工具（Plan B）
- 换模型：大模型 → 小模型

### 3. 兜底层
- 转人工
- 返回缓存结果', 'medium', ARRAY['阿里', '腾讯'], false, 4),
('system_design', 'deployment', '如何设计 LLM 推理服务的高可用架构？', '多模型路由 + 降级 + 熔断', '## 高可用架构

### 模型路由层
- 智能路由：根据任务类型选择模型

### 降级策略
- 一级降级：主模型 → 备用模型
- 二级降级：大模型 → 小模型

### 熔断机制
- 错误率 > 50% → 熔断 30s', 'hard', ARRAY['字节', '阿里', 'Google'], true, 5),
('system_design', 'rag', '向量数据库选型：Milvus vs Qdrant vs Pinecone？', '从规模、运维、成本三方面对比', '## 对比

| 维度 | Milvus | Qdrant | Pinecone |
|------|--------|--------|----------|
| 规模 | 十亿级 | 亿级 | 托管 |
| 运维 | 复杂 | 简单 | 零运维 |

### 选择建议
- 大规模：Milvus
- 中小规模：Qdrant
- 快速验证：Pinecone', 'medium', ARRAY['字节', '腾讯', '美团'], false, 6),
('system_design', 'agent', '如何评估 Agent 的任务完成质量？', '从结果、路径、工具三个维度评估', '## 评估体系

### 结果评估
- Task Completion
- Output Quality

### 路径评估
- 步骤数
- 回溯次数

### 工具评估
- Tool Selection 正确率', 'hard', ARRAY['OpenAI', 'Anthropic', '字节'], true, 7),
('system_design', 'deployment', 'LLM 应用的 Prompt Injection 如何防御？', '多层防御体系', '## 多层防御

### 输入层
- 长度限制 + 特殊字符过滤

### Prompt 层
- 明确指令边界
- 角色固化

### 模型层
- 安全微调

### 工具推荐
- NeMo Guardrails
- LlamaGuard', 'hard', ARRAY['字节', '阿里', 'Google'], true, 8),
('system_design', 'deployment', 'LLM 应用如何做成本优化？', '从 Prompt、缓存、模型路由三方面优化', '## 成本优化

### Prompt 优化
- 压缩 Prompt
- System Prompt 缓存

### 缓存策略
- 精确缓存
- 语义缓存

### 模型路由
- 简单任务 → 小模型
- 复杂任务 → 大模型', 'medium', ARRAY['字节', '阿里', '腾讯'], false, 9),
('system_design', 'agent', 'LangGraph 和 LangChain 的关系？', '互补关系，不是替代', '## 关系说明

### LangChain
- 核心：Chain（线性调用链）
- 适合：简单 Pipeline

### LangGraph
- 核心：Graph（有状态、有分支）
- 适合：复杂 Agent', 'medium', ARRAY['字节', '阿里', '腾讯'], false, 10),
('project', 'rag', '描述你做过的一个 RAG 项目', '用 STAR 法则回答', '## STAR 法则

### Situation
公司知识库有 10 万+ 文档，员工查找效率低。

### Task
构建智能问答系统。

### Action
1. 文档解析
2. 语义分块
3. 混合检索
4. 重排序
5. 生成 + 引用
6. RAGAS 评估

### Result
Recall@5 从 65% → 89%', 'medium', ARRAY['字节', '阿里', '腾讯'], true, 11),
('project', 'agent', '描述你做过的一个 Agent 项目', '强调架构设计和挑战', '## 项目概述
多代理协作写作平台。

### 架构
- Supervisor Agent
- Researcher Agent
- Writer Agent
- Reviewer Agent

### 挑战
1. Agent 间协调 → Supervisor 模式
2. 质量控制 → Human-in-the-loop', 'hard', ARRAY['字节', 'OpenAI', 'Anthropic'], true, 12),
('coding', 'algorithm', '实现一个 LRU Cache', 'HashMap + 双向链表', '## 代码

使用 HashMap + 双向链表实现。

- get: O(1)
- put: O(1)

关键：用双向链表维护访问顺序，最近访问放头部。', 'medium', ARRAY['字节', '阿里', '腾讯'], false, 13),
('project', 'finetuning', '如何评估微调效果？', '多维度对比评估', '## 评估体系

### 能力评估
- lm-eval-harness：MMLU、GSM8K、HumanEval

### 对齐评估
- MT-Bench
- AlpacaEval

### 业务评估
- 线上 A/B 测试', 'hard', ARRAY['字节', '阿里', 'Google'], true, 14),
('behavioral', 'teamwork', '描述一次你解决技术难题的经历', 'STAR 法则', '## 回答模板

### Situation
RAG 检索质量不达标。

### Task
一个月内 Recall@5 提升到 85%。

### Action
分析 Bad Case → 尝试方案 → 组合优化

### Result
Recall@5 达到 89%。', 'easy', ARRAY['字节', '阿里', '腾讯'], false, 15),
('behavioral', 'learning', '你如何跟进最新 AI 技术？', '展示主动学习习惯', '## 回答要点

### 日常跟进
- 论文：每周 1-2 篇
- 博客：OpenAI/Anthropic 官方

### 动手实践
- 每季度一个 Side Project', 'easy', ARRAY['字节', '阿里', 'OpenAI'], false, 16),
('system_design', 'deployment', 'vLLM 的核心优化技术？', 'PagedAttention + 连续批处理', '## vLLM 核心技术

### PagedAttention
- 显存利用率 40% → 95%

### 连续批处理
- GPU 利用率大幅提升

### 其他
- Prefix Caching
- Speculative Decoding', 'hard', ARRAY['字节', '阿里', 'Google'], true, 17),
('project', 'evaluation', '如何设计 LLM 应用的评估体系？', '离线 + 在线 + 人工三层', '## 评估体系

### 离线
- 测试集 500+ 题
- RAGAS + lm-eval

### 在线
- A/B 测试
- 用户反馈

### 人工
- Bad Case 分析', 'hard', ARRAY['字节', '阿里', 'OpenAI'], true, 18),
('system_design', 'rag', 'RAG 中幻觉如何抑制？', '多管齐下', '## 幻觉抑制

### 检索层
- 提高检索质量

### Prompt 层
- 约束：仅基于给定信息
- 引用溯源
- 拒答机制

### 输出层
- LLM-as-Judge', 'medium', ARRAY['字节', '阿里', '腾讯'], false, 19);

-- 评估指标百科
INSERT INTO evaluation_metrics (name, description, category, formula, tool, use_case) VALUES
('Faithfulness', '答案是否基于 Context，无幻觉', 'rag', '正确声明数 / 总声明数', 'RAGAS', '检测幻觉'),
('Answer Relevancy', '答案是否真正回答了问题', 'rag', '反向问题相似度均值', 'RAGAS', '检测答非所问'),
('Context Recall', '检索是否完整', 'rag', '可归因声明数 / GT 总声明数', 'RAGAS', '检索完整性'),
('Context Precision', '检索是否精准', 'rag', '有用片段数 / 总片段数', 'RAGAS', '检索噪声'),
('Recall@K', 'Top-K 中包含正确答案的比例', 'rag', '相关结果是否在 Top-K 中', '自定义', '检索召回率'),
('MRR', '正确答案排名倒数均值', 'rag', '1/rank_i 均值', '自定义', '排序质量'),
('Task Completion', 'Agent 是否完成目标', 'agent', '完成任务数 / 总任务数', '自定义', 'Agent 评估'),
('Tool Use Correctness', '工具选择是否正确', 'agent', '正确调用次数 / 总调用次数', '自定义', '工具评估'),
('MMLU', '多任务语言理解 57 科目', 'model', '正确率', 'lm-eval-harness', '通用能力'),
('HumanEval', 'Python 代码生成', 'model', 'Pass@K', 'lm-eval-harness', '代码能力'),
('GSM8K', '小学数学应用题', 'model', '正确率', 'lm-eval-harness', '数学推理'),
('MT-Bench', '多轮对话质量', 'model', 'GPT-4 评分 1-10', 'FastChat', '对话质量'),
('Toxicity', '有害内容比例', 'safety', '有害内容比例', 'Perspective API', '安全性');

-- 项目作品集
INSERT INTO projects (slug, title, description, content, tech_stack, difficulty, is_featured, sort_order) VALUES
('pdf-qa', '智能 PDF 问答系统', '端到端 RAG 项目', '# 智能 PDF 问答系统

## 技术栈
LangChain + GLM-4 + Milvus + RAGAS

## 面试话术
"我独立完成了从文档解析到检索生成的完整链路。"', ARRAY['LangChain', 'GLM-4', 'Milvus', 'RAGAS'], 'intermediate', true, 1),
('multi-agent-writer', '多代理协作写作平台', 'LangGraph 多角色 Agent', '# 多代理协作写作平台

## 技术栈
LangGraph + GLM-4 + PostgreSQL

## 面试话术
"用 LangGraph 实现了多角色协作。"', ARRAY['LangGraph', 'GLM-4', 'PostgreSQL'], 'advanced', true, 2),
('code-reviewer', '代码审查 Agent', 'AST + LLM 跨文件审查', '# 代码审查 Agent

## 技术栈
CogAgent + Tree-sitter + GLM-4

## 面试话术
"结合静态分析和 LLM 理解。"', ARRAY['CogAgent', 'Tree-sitter', 'GLM-4'], 'advanced', true, 3),
('finetune-platform', '微调实验平台', 'QLoRA + lm-eval', '# 微调实验平台

## 技术栈
QLoRA + lm-eval-harness + W&B

## 面试话术
"用 QLoRA 在消费级 GPU 上微调 7B 模型。"', ARRAY['QLoRA', 'PEFT', 'lm-eval-harness'], 'advanced', true, 4),
('llm-monitor', 'LLM 应用监控台', '全链路追踪 + 成本', '# LLM 应用监控台

## 技术栈
Arize Phoenix + LangSmith + Grafana

## 面试话术
"为 LLM 应用建立了完整的可观测性。"', ARRAY['Arize Phoenix', 'LangSmith', 'Grafana'], 'intermediate', true, 5);
