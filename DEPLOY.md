# 部署指南

## 前置准备

- 一个 [GitHub](https://github.com) 账号
- 一个 [Supabase](https://supabase.com) 账号（免费计划即可）
- 一个 [Vercel](https://vercel.com) 账号（免费 Hobby 计划）

---

## Step 1: 创建 Supabase 数据库

1. 访问 [supabase.com](https://supabase.com) → **New Project**
2. 设置项目名称和密码，选择就近区域
3. 等待项目创建完成（约 1-2 分钟）
4. 左侧菜单 → **SQL Editor** → **New Query**
5. 复制 `supabase/schema.sql` 的内容，粘贴执行 → 建表完成
6. 再新建一个 Query，复制 `supabase/seed.sql` 的内容执行 → 种子数据导入
7. 左侧菜单 → **Settings** → **API**，记录下：
   - `Project URL` → `NEXT_PUBLIC_SUPABASE_URL`
   - `anon public` key → `NEXT_PUBLIC_SUPABASE_ANON_KEY`

---

## Step 2: 配置环境变量

```bash
# 复制模板
cp .env.local.example .env.local

# 编辑 .env.local，填入真实的 Supabase 值
```

---

## Step 3: 推送到 GitHub

```bash
# 在 GitHub 上创建一个新仓库（不要勾选 README/LICENSE）
# https://github.com/new → 命名为 glm-learning-hub

# 添加远程仓库并推送
git remote add origin https://github.com/YOUR_USERNAME/glm-learning-hub.git
git branch -M main
git push -u origin main
```

---

## Step 4: 部署到 Vercel

1. 访问 [vercel.com/new](https://vercel.com/new)
2. 选择 **Import Git Repository**，找到你的 GitHub 仓库
3. 框架自动识别为 Next.js，无需修改构建设置
4. 展开 **Environment Variables** 部分，添加：

   | Key | Value |
   |-----|-------|
   | `NEXT_PUBLIC_SUPABASE_URL` | 你的 Supabase Project URL |
   | `NEXT_PUBLIC_SUPABASE_ANON_KEY` | 你的 Supabase anon key |

5. 点击 **Deploy**
6. 等待部署完成（约 1-2 分钟）

---

## Step 5: 验证部署

部署成功后，访问 `https://your-project.vercel.app`，确认：

- [ ] 首页正常加载，显示统计卡片
- [ ] 学习路径页面显示数据
- [ ] 资源导航页面显示分类资源
- [ ] 笔记列表显示已发布的笔记
- [ ] 管理后台 `/admin` 可以创建新笔记
- [ ] 暗色模式切换正常
- [ ] 移动端响应式布局正常

---

## 可选：自定义域名

1. Vercel Dashboard → 项目 → **Settings** → **Domains**
2. 添加你的域名
3. 按提示配置 DNS 记录

---

## 日常使用

### 添加笔记
访问 `/admin`，填写表单创建笔记，勾选"发布"后立即在笔记列表页可见。

### 修改学习阶段状态
直接在 Supabase Dashboard → **Table Editor** → `learning_stages` 表中修改 `status` 字段。

### 添加资源
在 Supabase Dashboard → **Table Editor** → `resources` 表中插入新行。

### 本地开发
```bash
npm run dev
# 访问 http://localhost:3000
```
