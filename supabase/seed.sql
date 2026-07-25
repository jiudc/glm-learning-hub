-- ============================================
-- GLM Learning Hub — 种子数据
-- 首次部署后在 Supabase SQL Editor 执行
-- ============================================

-- 插入学习路径
INSERT INTO learning_paths (title, description, icon, sort_order) VALUES
('GLM 基础入门', '从零开始了解 GLM 系列模型，掌握核心概念和基础用法', '🌱', 1),
('API 开发与集成', '学习如何通过 API 调用 GLM 模型，集成到应用中', '🔌', 2),
('模型微调实战', '掌握 GLM 模型的微调技术，适配特定场景', '🎯', 3),
('Agent 开发进阶', '基于 AutoGLM 和 CogAgent 开发智能 Agent', '🤖', 4);

-- 插入学习阶段（GLM 基础入门）
INSERT INTO learning_stages (path_id, title, description, sort_order, status)
SELECT
  p.id,
  stage.title,
  stage.desc,
  stage.ord,
  stage.status
FROM learning_paths p
CROSS JOIN LATERAL (VALUES
  ('了解智谱AI与GLM系列', '公司背景、GLM家族概览、开源生态', 1, 'completed'),
  ('GLM 模型架构原理', '自回归空白填充、预训练目标、模型结构', 2, 'in_progress'),
  ('环境搭建与快速开始', '安装依赖、获取API Key、第一个请求', 3, 'not_started'),
  ('GLM-4 vs GLM-5 对比', '版本演进、能力差异、选择指南', 4, 'not_started')
) AS stage(title, desc, ord, status)
WHERE p.title = 'GLM 基础入门';

-- 插入学习阶段（API 开发）
INSERT INTO learning_stages (path_id, title, description, sort_order, status)
SELECT
  p.id,
  stage.title,
  stage.desc,
  stage.ord,
  stage.status
FROM learning_paths p
CROSS JOIN LATERAL (VALUES
  ('Bigmodel 平台使用', '注册、获取API Key、控制台操作', 1, 'not_started'),
  ('REST API 调用', 'OpenAI 兼容接口、参数说明、最佳实践', 2, 'not_started'),
  ('流式输出 SSE', '实现打字机效果的流式响应', 3, 'not_started'),
  ('多模态 API', '图像理解、视觉问答接口调用', 4, 'not_started')
) AS stage(title, desc, ord, status)
WHERE p.title = 'API 开发与集成';

-- 插入学习阶段（模型微调）
INSERT INTO learning_stages (path_id, title, description, sort_order, status)
SELECT
  p.id,
  stage.title,
  stage.desc,
  stage.ord,
  stage.status
FROM learning_paths p
CROSS JOIN LATERAL (VALUES
  ('微调基础概念', 'SFT、RLHF、DPO 等微调方法概述', 1, 'not_started'),
  ('准备训练数据', '数据格式、数据清洗、数据集构建', 2, 'not_started'),
  ('使用官方工具微调', '智谱微调平台操作、参数配置', 3, 'not_started'),
  ('评估与部署', '模型评估指标、部署推理服务', 4, 'not_started')
) AS stage(title, desc, ord, status)
WHERE p.title = '模型微调实战';

-- 插入学习阶段（Agent 开发）
INSERT INTO learning_stages (path_id, title, description, sort_order, status)
SELECT
  p.id,
  stage.title,
  stage.desc,
  stage.ord,
  stage.status
FROM learning_paths p
CROSS JOIN LATERAL (VALUES
  ('Agent 基础概念', 'Agent 架构、规划、记忆、工具调用', 1, 'not_started'),
  ('AutoGLM 使用', 'AutoGLM 产品体验与 API 调用', 2, 'not_started'),
  ('CogAgent 开发', 'GUI Agent 开发、屏幕理解与操作', 3, 'not_started'),
  ('自定义 Agent 构建', '基于 GLM 构建自己的 Agent 应用', 4, 'not_started')
) AS stage(title, desc, ord, status)
WHERE p.title = 'Agent 开发进阶';

-- 插入资源导航
INSERT INTO resources (title, url, description, category, tags, is_featured) VALUES
('智谱AI官网', 'https://zhipuai.cn', '智谱AI官方网站', 'docs', ARRAY['官方', '产品'], true),
('THUDM GitHub', 'https://github.com/THUDM', '智谱AI研究团队开源代码仓库', 'github', ARRAY['开源', 'GitHub'], true),
('智谱学习中心', 'https://learn.zhenguiren.cn/courses', '官方学习课程与文档', 'tutorial', ARRAY['官方', '课程'], true),
('Bigmodel 开放平台', 'https://bigmodel.cn', 'GLM模型API服务与开发者平台', 'docs', ARRAY['API', '开发'], true),
('GLM-4 GitHub', 'https://github.com/THUDM/GLM-4', 'GLM-4 模型开源仓库', 'github', ARRAY['GLM-4', '开源'], true),
('CogAgent GitHub', 'https://github.com/THUDM/CogAgent', 'CogAgent GUI Agent 开源仓库', 'github', ARRAY['Agent', 'GUI'], true),
('AutoGLM 官网', 'https://autoglm.zhipuai.cn', 'AutoGLM 自主Agent产品', 'docs', ARRAY['Agent', '产品'], true),
('z.ai', 'https://z.ai', '智谱AI在线体验平台', 'docs', ARRAY['体验', '产品'], true),
('HuggingFace THUDM', 'https://huggingface.co/THUDM', 'HuggingFace 上的模型权重', 'github', ARRAY['模型', '权重'], true),
('智谱清言 App', 'https://chatglm.cn', '智谱AI对话产品', 'docs', ARRAY['产品', '对话'], true);

-- 插入示例笔记
INSERT INTO notes (slug, title, content, excerpt, tags, category, is_published) VALUES
('glm-intro', 'GLM 模型简介', '# GLM 模型简介

GLM (General Language Model) 是智谱AI开发的大语言模型系列。

## 核心特点

- **自回归空白填充**：不同于 GPT 的自回归或 BERT 的双向编码
- **多模态能力**：支持文本、图像等多种输入
- **开源友好**：大部分模型权重开源，支持商用

## 模型家族

| 模型 | 类型 | 特点 |
|------|------|------|
| GLM-4 | 文本 | 强大的文本理解与生成 |
| GLM-5 | 文本 | 旗舰推理模型 |
| GLM-5V | 多模态 | 视觉理解能力 |
| CogAgent | Agent | GUI Agent 基座 |

## 下一步

- 阅读官方文档
- 尝试 API 调用
- 了解微调方法', 'GLM 系列模型概述，了解核心特点和模型家族', ARRAY['GLM', '入门', '概述'], '基础', true),
('api-quickstart', 'API 快速开始', '# API 快速开始

## 获取 API Key

1. 访问 Bigmodel 平台
2. 注册账号
3. 创建 API Key

## 第一个请求

```python
from openai import OpenAI

client = OpenAI(
    api_key="your-api-key",
    base_url="https://open.bigmodel.cn/api/paas/v4/"
)

response = client.chat.completions.create(
    model="glm-4",
    messages=[
        {"role": "user", "content": "你好，请介绍一下你自己"}
    ]
)

print(response.choices[0].message.content)
```

## 注意事项

- 注意 API 调用频率限制
- 妥善保管 API Key
- 使用流式输出提升用户体验', '通过 Bigmodel 平台快速上手 GLM API 调用', ARRAY['API', '快速开始', 'Python'], 'API', true),
('agent-concept', 'Agent 核心概念', '# Agent 核心概念

## 什么是 Agent？

Agent 是能够自主规划、推理和执行任务的 AI 系统。

## Agent 核心组件

- **规划（Planning）**：任务分解、步骤排序
- **记忆（Memory）**：短期记忆、长期记忆
- **工具（Tools）**：外部 API、代码执行
- **行动（Action）**：执行具体操作

## 智谱 Agent 生态

- **AutoGLM**：自主 Agent，自动完成任务
- **CogAgent**：GUI Agent，理解并操作界面
- **GLM-5-Turbo**：专为 Agent 优化的模型

## 学习路径

1. 理解基础概念
2. 体验 AutoGLM 产品
3. 学习工具调用（Function Calling）
4. 构建自定义 Agent', '了解 Agent 核心概念和智谱 Agent 生态', ARRAY['Agent', '概念', 'AutoGLM'], 'Agent', true);
