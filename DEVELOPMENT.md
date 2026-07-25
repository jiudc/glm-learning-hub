# 开发指南

> 本文档帮助开发者快速上手项目。

---

## 1. 项目结构

```
glm-learning-hub/
├── app/                    # Next.js 页面
│   ├── page.tsx            # 首页
│   ├── layout.tsx          # 根布局
│   ├── globals.css         # 全局样式
│   ├── paths/              # 学习路径
│   ├── courses/            # 课程
│   ├── interview/           # 面试题库
│   ├── mock-interview/     # 模拟面试
│   ├── projects/           # 项目
│   ├── evaluation/         # 评估百科
│   ├── dashboard/          # 仪表盘
│   ├── admin/              # 管理
│   └── about/              # 关于
├── components/
│   ├── ui/                 # 基础组件
│   ├── layout/             # 布局组件
│   ├── interview/           # 面试组件
│   └── notes/              # 笔记组件
├── hooks/
│   └── use-learning-progress.ts
├── lib/
│   ├── supabase.ts
│   └── utils.ts
├── types/
│   └── database.ts
├── supabase/
│   ├── schema.sql
│   ├── migration_v2.sql
│   └── seed_v3_final.sql
└── docs/
    ├── KNOWLEDGE_INDEX.md
    ├── system-design/
    ├── interview/
    ├── projects/
    └── evaluation/
```

---

## 2. 开发流程

### 2.1 新功能开发
1. 在 `REQUIREMENTS.md` 中定义需求
2. 创建页面/组件
3. 本地验证
4. 提交 PR
5. 部署验证

### 2.2 数据库变更
1. 创建新的 migration SQL 文件
2. 在 Supabase 执行
3. 更新 `types/database.ts`
4. 更新相关页面

### 2.3 内容更新
1. 在 `docs/` 目录下编辑文档
2. 如需更新数据库，创建新的 seed 文件

---

## 3. 关键文件说明

### 3.1 数据库客户端 (`lib/supabase.ts`)
```typescript
export const supabase = createClient(url, key);
```
所有数据库操作通过此客户端。

### 3.2 学习进度 Hook (`hooks/use-learning-progress.ts`)
```typescript
const { progress, updateStatus, markWrong, getStats } = useLearningProgress();
```
用于追踪用户学习进度，数据存储在 localStorage。

### 3.3 渐进式答案组件 (`components/interview/progressive-answer.tsx`)
三阶段展示：思考 → 提示 → 答案。

---

## 4. 常见问题

### 4.1 页面显示 404
- 检查路由是否正确
- 检查 Vercel 部署状态

### 4.2 数据为空
- 检查 Supabase 连接
- 检查种子数据是否执行

### 4.3 构建失败
- 检查 TypeScript 类型
- 检查 CSS 语法

---

## 5. 部署

### 5.1 自动部署
推送到 `main` 分支 → Vercel 自动部署

### 5.2 手动部署
```bash
npx vercel --prod
```

---

## 6. 验证

部署后，逐项检查 `VERIFICATION.md` 中的清单。
