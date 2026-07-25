-- ============================================
-- GLM Learning Hub — Database Schema
-- Run this SQL in Supabase SQL Editor
-- ============================================

-- 1. 学习路径表
CREATE TABLE IF NOT EXISTS learning_paths (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  icon TEXT,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 2. 学习阶段表
CREATE TABLE IF NOT EXISTS learning_stages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  path_id UUID REFERENCES learning_paths(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  sort_order INT DEFAULT 0,
  status TEXT DEFAULT 'not_started' CHECK (status IN ('not_started', 'in_progress', 'completed')),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 3. 资源导航表
CREATE TABLE IF NOT EXISTS resources (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  url TEXT NOT NULL,
  description TEXT,
  category TEXT CHECK (category IN ('docs', 'github', 'tutorial', 'video', 'paper')),
  tags TEXT[],
  is_featured BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 4. 学习笔记表
CREATE TABLE IF NOT EXISTS notes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  slug TEXT UNIQUE NOT NULL,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  excerpt TEXT,
  tags TEXT[],
  category TEXT,
  is_published BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 5. 笔记-阶段关联表
CREATE TABLE IF NOT EXISTS note_stages (
  note_id UUID REFERENCES notes(id) ON DELETE CASCADE,
  stage_id UUID REFERENCES learning_stages(id) ON DELETE CASCADE,
  PRIMARY KEY (note_id, stage_id)
);

-- ============================================
-- 创建索引
-- ============================================
CREATE INDEX IF NOT EXISTS idx_stages_path_id ON learning_stages(path_id);
CREATE INDEX IF NOT EXISTS idx_resources_category ON resources(category);
CREATE INDEX IF NOT EXISTS idx_notes_slug ON notes(slug);
CREATE INDEX IF NOT EXISTS idx_notes_published ON notes(is_published);

-- ============================================
-- 开启 Row Level Security (RLS)
-- ============================================
ALTER TABLE learning_paths ENABLE ROW LEVEL SECURITY;
ALTER TABLE learning_stages ENABLE ROW LEVEL SECURITY;
ALTER TABLE resources ENABLE ROW LEVEL SECURITY;
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE note_stages ENABLE ROW LEVEL SECURITY;

-- ============================================
-- RLS 策略：所有人可读（公开站点）
-- 如果需要私有，改为仅 authenticated 用户可访问
-- ============================================
CREATE POLICY "Public read access for paths" ON learning_paths FOR SELECT USING (true);
CREATE POLICY "Public read access for stages" ON learning_stages FOR SELECT USING (true);
CREATE POLICY "Public read access for resources" ON resources FOR SELECT USING (true);
CREATE POLICY "Public read access for published notes" ON notes FOR SELECT USING (is_published = true);
CREATE POLICY "Public read access for note_stages" ON note_stages FOR SELECT USING (true);

-- ============================================
-- 可选：仅认证用户可写（管理后台用）
-- ============================================
-- CREATE POLICY "Authenticated write" ON learning_paths FOR ALL USING (auth.role() = 'authenticated');
