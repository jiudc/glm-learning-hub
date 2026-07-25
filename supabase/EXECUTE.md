# 数据库迁移指南

> 请在 Supabase SQL Editor (https://supabase.com/dashboard/project/lolcueqdzehrmxniducb/sql/new) 中依次执行以下文件。

## 执行顺序

### 1. 已执行（无需再执行）
- ✅ `schema.sql` — 原始表结构
- ✅ `migration_v2.sql` — v2 新增表
- ✅ `seed_v3_final.sql` — 29 道深度面试题

### 2. 待执行（请依次执行）

#### 第一步：创建科技热点表
执行 `migration_v3.sql`

#### 第二步：导入深度课程内容
执行 `seed_courses_deep.sql`

#### 第三步：导入剩余课程
执行 `seed_courses_remaining.sql`

## 验证

执行完成后，运行以下命令验证：
```bash
cd /Users/charles/WebProjects/glm-learning-hub
node -e "
const { createClient } = require('@supabase/supabase-js');
const supabase = createClient(
  'https://lolcueqdzehrmxniducb.supabase.co',
  'sb_publishable_3qZPvRyF-mBduatuApAuPA_D8sL3UfX'
);

async function check() {
  const tables = ['learning_paths', 'courses', 'interview_questions', 'projects', 'evaluation_metrics', 'tech_news'];
  for (const t of tables) {
    const { count } = await supabase.from(t).select('*', { count: 'exact', head: true });
    console.log(\`\${t}: \${count} 条\`);
  }
  
  // 检查课程内容深度
  const { data: courses } = await supabase.from('courses').select('slug, content').limit(5);
  if (courses) {
    courses.forEach(c => console.log(\`\${c.slug}: \${c.content?.length || 0} 字符\`));
  }
}
check().catch(console.error);
"
```
