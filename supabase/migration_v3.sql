-- ============================================
-- GLM Learning Hub 3.0 — 每日科技热点表
-- ============================================

CREATE TABLE IF NOT EXISTS tech_news (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  summary TEXT,
  source_url TEXT,
  source_name TEXT,
  category TEXT, -- ai | llm | agent | rag | finetuning | deployment | safety | product
  tags TEXT[],
  published_date DATE DEFAULT CURRENT_DATE,
  is_featured BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 索引
CREATE INDEX IF NOT EXISTS idx_tech_news_date ON tech_news(published_date DESC);
CREATE INDEX IF NOT EXISTS idx_tech_news_category ON tech_news(category);
CREATE INDEX IF NOT EXISTS idx_tech_news_featured ON tech_news(is_featured);

-- RLS
ALTER TABLE tech_news ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read tech_news" ON tech_news FOR SELECT USING (true);

-- 种子数据：最新 AI 科技热点
INSERT INTO tech_news (title, summary, source_url, source_name, category, tags, is_featured, published_date) VALUES
('GPT-5 发布：推理能力大幅提升', 'OpenAI 发布 GPT-5，在数学、代码、推理等核心能力上实现重大突破，多模态能力全面升级。', 'https://openai.com', 'OpenAI', 'llm', ARRAY['GPT-5', 'OpenAI', '推理'], true, CURRENT_DATE),
('Claude 4.5 Sonnet：长上下文新纪录', 'Anthropic 发布 Claude 4.5 Sonnet，支持 1M tokens 上下文窗口，在复杂推理任务上超越 GPT-4o。', 'https://anthropic.com', 'Anthropic', 'llm', ARRAY['Claude', 'Anthropic', '长上下文'], true, CURRENT_DATE),
('GLM-5 开源：中文能力 SOTA', '智谱 AI 开源 GLM-5，中文理解与生成能力达到 SOTA，支持 128K 上下文。', 'https://zhipuai.cn', '智谱AI', 'llm', ARRAY['GLM-5', '开源', '中文'], true, CURRENT_DATE),
('LangGraph 1.0 正式发布', 'LangChain 发布 LangGraph 1.0，提供更稳定的多代理协作框架，支持 Human-in-the-loop。', 'https://langchain.com', 'LangChain', 'agent', ARRAY['LangGraph', '多代理', '开源'], true, CURRENT_DATE),
('RAGAS 评估框架升级', 'RAGAS 发布新版本，支持更多评估指标，集成 TruLens 实时监控。', 'https://ragas.io', 'RAGAS', 'rag', ARRAY['RAGAS', '评估', '开源'], false, CURRENT_DATE),
('vLLM 支持多 GPU 推理', 'vLLM 最新版本支持 Tensor Parallelism 和 Pipeline Parallelism，大幅提升推理吞吐量。', 'https://vllm.ai', 'vLLM', 'deployment', ARRAY['vLLM', '推理', 'GPU'], false, CURRENT_DATE),
('Llama 4 开源：Meta 的新一代模型', 'Meta 开源 Llama 4，采用 MoE 架构，在多项基准测试中超越 GPT-4o。', 'https://meta.com', 'Meta', 'llm', ARRAY['Llama', '开源', 'MoE'], true, CURRENT_DATE),
('AutoGen 2.0：微软多代理框架升级', '微软发布 AutoGen 2.0，支持更复杂的多代理协作模式和可视化调试。', 'https://microsoft.com', 'Microsoft', 'agent', ARRAY['AutoGen', '微软', '多代理'], false, CURRENT_DATE),
('Mistral Large 2 发布', 'Mistral AI 发布 Large 2，在代码生成和多语言能力上实现重大突破。', 'https://mistral.ai', 'Mistral', 'llm', ARRAY['Mistral', '代码生成', '多语言'], false, CURRENT_DATE),
('Gemini 2.5：Google 的多模态新标杆', 'Google 发布 Gemini 2.5，支持原生多模态理解和生成，视频理解能力大幅提升。', 'https://google.com', 'Google', 'llm', ARRAY['Gemini', 'Google', '多模态'], true, CURRENT_DATE),
('QLoRA 微调实战指南', '使用 QLoRA 在消费级 GPU 上微调 7B 模型，成本降低 90% 的同时保持 95% 的性能。', 'https://huggingface.co', 'HuggingFace', 'finetuning', ARRAY['QLoRA', '微调', 'GPU'], false, CURRENT_DATE),
('Graph RAG：微软的知识图谱 RAG', '微软开源 Graph RAG，结合知识图谱和向量检索，大幅提升多跳推理能力。', 'https://microsoft.com', 'Microsoft', 'rag', ARRAY['Graph RAG', '知识图谱', '微软'], false, CURRENT_DATE),
('LLM 安全：Prompt Injection 最新防御', '最新研究提出多层 Prompt Injection 防御框架，将攻击成功率降低到 1% 以下。', 'https://arxiv.org', 'arXiv', 'safety', ARRAY['安全', 'Prompt Injection', '防御'], false, CURRENT_DATE),
('SWE-bench 最新排行榜', '各大模型在 SWE-bench 上的最新表现，Claude 4.5 在代码修复任务上领先。', 'https://swebench.com', 'SWE-bench', 'product', ARRAY['SWE-bench', '代码', '排行榜'], false, CURRENT_DATE),
('AI Agent 商业化落地案例', '多家企业分享 AI Agent 在客服、数据分析、代码生成等场景的落地经验和 ROI。', 'https://various', 'Various', 'product', ARRAY['Agent', '商业化', '落地'], false, CURRENT_DATE);
