-- ============================================
-- GLM Learning Hub 3.0 — 深度面试题种子数据
-- 执行前提：migration_v2.sql 已执行
-- ============================================

-- 清理旧面试题
DELETE FROM interview_questions;

-- 系统设计（5题）
INSERT INTO interview_questions (category, subcategory, question, hint, answer, difficulty, company_tag, is_featured, sort_order) VALUES
('system_design', 'architecture', '设计 ChatGPT 类对话系统', '从流式输出、上下文管理、高可用、成本控制四个层面回答', '## 标准答案\n\n### 1. 流式输出\n- SSE 实现打字机效果\n- 背压控制：客户端消费慢时降速\n- 断线重连：sequence number 续传\n\n### 2. 上下文窗口管理\n- 滑动窗口：保留最近 N 轮\n- 摘要压缩：旧对话生成摘要\n- Token 计数：tiktoken 精确计算\n\n### 3. 会话存储\n- Redis：热数据（活跃会话），TTL 30min\n- PostgreSQL：冷数据（历史持久化）\n\n### 4. LLM 推理\n- vLLM + PagedAttention（显存利用率 40%→95%）\n- 连续批处理（吞吐 2-4x）\n- 模型路由：简单→小模型，复杂→大模型\n\n### 5. Trade-off\n| 决策 | 选择 | 原因 |\n|------|------|------|\n| 流式协议 | SSE | 简单、自动重连 |\n| 上下文策略 | 混合 | 短对话窗口+长对话摘要 |\n| 模型部署 | 混合 | 核心自研+兜底API |\n\n### 追问\n1. 流量增加10倍？→ 水平扩展 + 降级\n2. 如何控制成本？→ 模型路由 + 缓存 + 批处理\n3. 上下文溢出？→ 压缩 + 分级 + 用户提示\n\n### 评分标准\n- 优秀：完整架构+Trade-off+追问对答如流\n- 良好：核心模块清晰\n- 及格：能说出基本流程', 'hard', ARRAY['字节', '阿里', '腾讯'], true, 1),
26),

('coding', 'algorithm', '实现一个简单的 ReAct Agent', '循环：思考→行动→观察', '## 实现

核心循环：
1. Thought：LLM 思考下一步
2. Action：调用工具
3. Observation：获取结果
4. 循环直到得到最终答案

### 追问
1. 如何解析 Action？→ 正则或 LLM 结构化输出
2. 错误处理？→ try-except + 重试', 'hard', ARRAY['字节', 'OpenAI'], true, 27),

-- 行为面试（2题）
('behavioral', 'learning', '你如何跟进最新 AI 技术？', '展示主动学习习惯', '## 回答要点

### 日常跟进
- 论文：每周精读 1-2 篇（arXiv、Papers With Code）
- 博客：OpenAI/Anthropic/LangChain 官方博客
- 开源：关注 GitHub Trending（AI 方向）

### 动手实践
- 每季度完成一个 Side Project
- 参加 Kaggle/HuggingFace 竞赛
- 复现经典论文

### 社区参与
- 技术分享（团队/社区）
- 开源贡献（PR/Issue）
- 技术社群讨论

### 最近学习
- 正在研究 Graph RAG（微软开源）
- 实验 LangGraph 多代理协作
- 关注 GLM-5 技术报告', 'easy', ARRAY['字节', '阿里', 'OpenAI'], false, 28),

('behavioral', 'teamwork', '描述一次团队合作解决难题的经历', 'STAR 法则', '## STAR 法则

### Situation
团队 RAG 系统上线后用户反馈答案不准确。

### Task
两周内将准确率从 70% 提升到 85%。

### Action
1. 我主导分析了 100 个 Bad Case
2. 发现主要问题是分块策略不当
3. 提出混合检索 + 重排序方案
4. 协调后端和前端同学一起实现

### Result
准确率提升到 88%，用户满意度 + 30%。', 'easy', ARRAY['字节', '阿里', '腾讯'], false, 29);
