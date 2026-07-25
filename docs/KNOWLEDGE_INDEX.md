# GLM Learning Hub — 知识体系索引

> 本文档是 GLM Learning Hub 的完整知识索引，确保切换任何 AI 模型都能无缝衔接。

## 平台定位

帮助程序员在大模型应用领域实现技术质变，通过大厂（字节、阿里、腾讯、Google、OpenAI、Anthropic）LLM 应用工程师面试。

## 4 大核心模块

### 模块 1: RAG 系统设计与实战
- **难度**：中级 → 高级
- **预计学时**：40 小时
- **面试占比**：~40%（大厂面试必考）
- **知识文件**：[rag-knowledge.md](./rag-knowledge.md)

### 模块 2: LLM Agent 开发进阶
- **难度**：高级 → 专家
- **预计学时**：50 小时
- **面试占比**：~30%（2025 最热方向）
- **知识文件**：[agent-knowledge.md](./agent-knowledge.md)

### 模块 3: 系统设计面试专练
- **难度**：高级
- **预计学时**：30 小时
- **面试占比**：~20%（直接提分）
- **知识文件**：[system-design-knowledge.md](./system-design-knowledge.md)

### 模块 4: 项目作品集
- **难度**：中级 → 高级
- **预计学时**：60 小时
- **面试占比**：~10%（项目深挖）
- **知识文件**：[project-knowledge.md](./project-knowledge.md)

## 技术栈覆盖

| 类别 | 技术 |
|------|------|
| 推理部署 | vLLM, TGI, Triton, PagedAttention, FlashAttention, Speculative Decoding |
| 应用框架 | LangChain, LangGraph, CrewAI, AutoGen, LlamaIndex |
| 检索增强 | Milvus, Qdrant, Pinecone, BGE, Reranker, BM25, RRF |
| 微调对齐 | LoRA, QLoRA, PEFT, RLHF, DPO, GRPO |
| 评估测试 | RAGAS, lm-eval-harness, TruLens, ARES |
| 可观测性 | LangSmith, Arize Phoenix, OpenTelemetry, Grafana |
| 安全 | NeMo Guardrails, LlamaGuard, LLM Guard |
| 智谱生态 | GLM-4, GLM-5, CogAgent, AutoGLM, GLM-PC |

## 内容结构

```
docs/
├── KNOWLEDGE_INDEX.md          ← 本文件（索引）
├── rag-knowledge.md            ← RAG 完整知识体系
├── agent-knowledge.md          ← Agent 开发完整知识体系
├── system-design-knowledge.md  ← 系统设计面试完整知识
├── project-knowledge.md        ← 项目作品集完整指南
├── evaluation-guide.md         ← LLM 评估指标百科
├── interview-questions.md      ← 面试题库（含参考答案）
└── cheat-sheets.md             ← 速查表（Prompt/RAG/Agent/部署）
```

## 种子数据位置

| 文件 | 用途 |
|------|------|
| `supabase/schema.sql` | 原始表结构 |
| `supabase/seed.sql` | 原始种子数据 |
| `supabase/migration_v2.sql` | 2.0 新增表 |
| `supabase/seed_v2.sql` | 2.0 完整种子数据（课程/面试题/项目/评估指标/实验） |

## 部署信息

- **前端**：Next.js 14 + TypeScript + TailwindCSS + shadcn/ui
- **后端**：Supabase (PostgreSQL + Auth + Storage)
- **部署**：Vercel (前端) + Supabase Cloud (后端)
- **仓库**：https://github.com/jiudc/glm-learning-hub
- **线上地址**：https://glm-learning-hub-one.vercel.app/
