# GLM Learning Hub — 智谱AI学习知识库

智谱AI GLM 系列开源模型的个人学习知识库网站。包含学习路径、资源导航、学习笔记和进度追踪。

## 技术栈

| 层级 | 技术 |
|------|------|
| 前端 | Next.js 14+ (App Router) + TypeScript + TailwindCSS + shadcn/ui |
| 后端 | Supabase (PostgreSQL + Auth + Storage) |
| 部署 | Vercel (前端) + Supabase Cloud (后端) |

## 快速开始

### 1. 克隆项目

```bash
git clone https://github.com/your-username/glm-learning-hub.git
cd glm-learning-hub
npm install
```

### 2. 配置 Supabase

1. 前往 [Supabase](https://supabase.com) 创建免费项目
2. 在 **SQL Editor** 中依次执行：
   - `supabase/schema.sql` — 建表 + RLS 策略
   - `supabase/seed.sql` — 种子数据（可选）
3. 在 **Settings → API** 获取 URL 和 anon key

### 3. 配置环境变量

```bash
cp .env.local.example .env.local
```

编辑 `.env.local`：

```
NEXT_PUBLIC_SUPABASE_URL=https://your-project-id.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here
```

### 4. 启动开发服务器

```bash
npm run dev
```

打开 [http://localhost:3000](http://localhost:3000) 查看效果。

### 5. 部署到 Vercel

1. 推送到 GitHub
2. 在 [Vercel](https://vercel.com/new) 导入项目
3. 添加环境变量（同上）
4. 点击 Deploy

## 项目结构

```
glm-learning-hub/
├── app/                    # Next.js 页面
│   ├── page.tsx            # 首页
│   ├── paths/              # 学习路径
│   ├── resources/          # 资源导航
│   ├── notes/              # 学习笔记
│   └── about/              # 关于
├── components/
│   ├── ui/                 # shadcn/ui 组件
│   ├── layout/             # 布局组件
│   └── theme-provider.tsx  # 主题提供者
├── lib/
│   ├── supabase.ts         # Supabase 客户端
│   └── utils.ts            # 工具函数
├── types/
│   └── database.ts         # 数据库类型
├── supabase/
│   ├── schema.sql          # 数据库 Schema
│   └── seed.sql            # 种子数据
└── .env.local.example      # 环境变量模板
```

## 页面路由

| 路由 | 描述 |
|------|------|
| `/` | 首页 — 概览、功能介绍、最新动态 |
| `/paths` | 学习路径 — 系统化学习路线 + 进度追踪 |
| `/resources` | 资源导航 — 分类资源链接 |
| `/notes` | 学习笔记 — 笔记列表 |
| `/notes/[slug]` | 笔记详情 — MDX 渲染 |
| `/about` | 关于 — 技术栈、推荐资源 |

## License

MIT
