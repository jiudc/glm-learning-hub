# GLM Learning Hub — 大模型应用工程师进阶平台

> 帮助程序员系统化掌握 LLM 应用开发，通过大厂（字节、阿里、腾讯、Google、OpenAI）面试。

## 📋 项目概述

### 定位
面向有大厂面试需求的 LLM 应用工程师，提供系统化学习路径 + 深度面试题库 + 模拟面试 + 项目作品集。

### 目标用户
- 有 1-3 年经验，想进入大厂做 LLM 应用开发的工程师
- 需要系统化准备 LLM 应用面试的候选人
- 想从零构建完整 LLM 应用知识体系的学习者

### 核心价值主张
**10 周掌握 LLM 应用工程，通过大厂面试**

---

## 🏗️ 技术架构

### 技术栈
| 层级 | 技术 | 说明 |
|------|------|------|
| 前端 | Next.js 14+ (App Router) | React 全栈框架 |
| 语言 | TypeScript | 类型安全 |
| 样式 | TailwindCSS + shadcn/ui | 原子化 CSS + 组件库 |
| 后端 | Supabase | BaaS（PostgreSQL + Auth + Storage） |
| 部署 | Vercel | 前端托管（自动部署） |
| 代码高亮 | Shiki | 语法高亮 |

### 目录结构
```
glm-learning-hub/
├── app/                    # Next.js 页面路由
│   ├── page.tsx            # 首页
│   ├── paths/              # 学习路径
│   │   └── [slug]/         # 路径详情
│   ├── courses/            # 课程
│   │   └── [slug]/         # 课程详情
│   ├── interview/           # 面试题库
│   │   └── [id]/           # 面试题详情
│   ├── mock-interview/     # 模拟面试
│   │   └── random/         # 随机练习
│   ├── projects/           # 项目作品集
│   │   └── [slug]/         # 项目详情
│   ├── evaluation/         # 评估指标百科
│   ├── dashboard/          # 学习仪表盘
│   ├── admin/              # 管理后台
│   └── about/              # 关于页面
├── components/
│   ├── ui/                 # 基础 UI 组件
│   ├── layout/             # 布局组件（Header, Footer）
│   ├── interview/           # 面试相关组件
│   └── notes/              # 笔记相关组件
├── hooks/                  # React Hooks
│   └── use-learning-progress.ts  # 学习进度追踪
├── lib/                    # 工具库
│   ├── supabase.ts         # Supabase 客户端
│   └── utils.ts            # 通用工具
├── types/                  # TypeScript 类型
│   └── database.ts         # 数据库类型
├── supabase/               # 数据库相关
│   ├── schema.sql          # 原始表结构
│   ├── seed.sql            # 原始种子数据
│   ├── migration_v2.sql    # v2 迁移（新增表）
│   ├── seed_v2.sql         # v2 种子数据
│   └── seed_v3_final.sql   # v3 最终种子数据（29道深度面试题）
├── docs/                   # 知识文档（模型无关）
│   ├── KNOWLEDGE_INDEX.md  # 知识体系索引
│   ├── system-design/      # 系统设计文档
│   ├── interview/           # 面试题深度答案
│   ├── projects/           # 项目深度文档
│   └── evaluation/         # 评估指标实战
└── public/                 # 静态资源
```

---

## 🗄️ 数据库设计

### 核心表

| 表名 | 用途 | 关键字段 |
|------|------|----------|
| `learning_paths` | 学习路径 | id, slug, title, category, difficulty, estimated_hours |
| `courses` | 课程 | id, path_id, slug, title, content, code_examples |
| `interview_questions` | 面试题库 | id, category, question, hint, answer, difficulty, company_tag |
| `projects` | 项目作品集 | id, slug, title, content, tech_stack, difficulty |
| `evaluation_metrics` | 评估指标 | id, name, description, category, formula, tool |
| `resources` | 资源导航 | id, title, url, category, tags |
| `notes` | 学习笔记 | id, slug, title, content, tags |
| `labs` | 动手实验 | id, course_id, title, starter_code, solution_code |

### 数据库初始化顺序
1. 执行 `supabase/schema.sql` — 建原始表
2. 执行 `supabase/migration_v2.sql` — 新增 v2 表 + 添加字段
3. 执行 `supabase/seed_v3_final.sql` — 导入 29 道深度面试题

---

## 🚀 快速开始

### 环境要求
- Node.js 18+
- npm 或 pnpm
- Supabase 账号

### 本地开发
```bash
# 1. 克隆仓库
git clone git@github.com:jiudc/glm-learning-hub.git
cd glm-learning-hub

# 2. 安装依赖
npm install

# 3. 配置环境变量
cp .env.local.example .env.local
# 编辑 .env.local，填入 Supabase URL 和 Key

# 4. 启动开发服务器
npm run dev
```

### 部署
1. 推送到 GitHub → Vercel 自动部署
2. 在 Vercel 配置环境变量（Supabase URL + Key）

---

## 📊 核心功能

### 1. 面试题库（29 道深度面试题）
- **分类**：系统设计、RAG、Agent、部署、项目深挖、编码、行为
- **渐进式答案**：思考 → 提示 → 答案
- **公司标签**：字节、阿里、腾讯、Google、OpenAI
- **难度分级**：简单、中等、困难、专家

### 2. 模拟面试
- **随机练习**：从题库随机抽题，自我评分
- **压力面试**：倒计时模式（待实现）

### 3. 学习进度追踪
- localStorage 记录学习状态
- 技能雷达图可视化
- 错题本功能

### 4. 系统设计（5 个完整案例）
- 设计 ChatGPT 类对话系统
- 设计智能客服系统
- 设计代码助手（Copilot）
- 设计 AI 搜索
- 设计多模态 RAG 系统

### 5. 项目作品集（5 个梯度项目）
- 智能 PDF 问答系统
- 多代理协作写作平台
- 代码审查 Agent
- 微调实验平台
- LLM 应用监控台

---

## 📚 知识体系

### 8 大核心模块
1. **LLM 基础与架构** — Transformer、KV Cache、推理优化
2. **Prompt Engineering** — CoT、ReAct、DSPy、Tree of Thoughts
3. **RAG 系统设计** — 文档处理、检索、重排序、评估
4. **LLM Agent 开发** — ReAct、LangGraph、多代理协作
5. **微调与对齐** — LoRA/QLoRA、RLHF/DPO
6. **LLMOps 与部署** — vLLM、可观测性、安全
7. **系统设计面试** — 5 大高频场景
8. **项目作品集** — 5 个梯度项目

---

## 🔧 环境变量

```
NEXT_PUBLIC_SUPABASE_URL=https://your-project-id.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here
```

---

## 📝 开发规范

### Git 提交规范
```
feat: 新功能
fix: 修复
docs: 文档
style: 样式
refactor: 重构
test: 测试
chore: 构建/工具
```

### 文件命名
- 页面组件：`page.tsx`
- 组件：`kebab-case.tsx`
- Hook：`use-*.ts`
- 工具：`*.ts`

---

## 🗺️ 路线图

### ✅ 已完成
- [x] 项目初始化（Next.js + Supabase）
- [x] 数据库设计（8 张核心表）
- [x] 基础页面（首页、路径、面试题、项目、评估）
- [x] 面试题库（29 道深度面试题）
- [x] 模拟面试（随机练习）
- [x] 学习进度追踪
- [x] 学习仪表盘

### 🔲 待完成
- [ ] AI 模拟面试官（实时追问 + 评分）
- [ ] 个性化学习路径
- [ ] 可分享学习成果卡片
- [ ] 社区讨论功能
- [ ] 移动端 App
- [ ] 企业版（团队培训）

---

## 📄 License

MIT
