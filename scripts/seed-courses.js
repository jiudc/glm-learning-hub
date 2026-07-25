const { createClient } = require("@supabase/supabase-js");

const supabase = createClient(
  "https://lolcueqdzehrmxniducb.supabase.co",
  "sb_publishable_3qZPvRyF-mBduatuApAuPA_D8sL3UfX"
);

const courses = {
  "rag-fundamentals": `# RAG 系统设计与架构演进

## 课程目标

通过本课程，你将：
- 理解 RAG 的核心原理和架构演进路线
- 掌握文档处理、分块、检索、生成的完整链路
- 能够独立设计和优化企业级 RAG 系统
- 通过大厂 RAG 相关面试题

## 第一章：RAG 基础概念

### 1.1 什么是 RAG？

RAG（Retrieval-Augmented Generation）通过检索外部知识增强 LLM 生成能力，解决三大问题：

**问题 1：幻觉（Hallucination）**
- LLM 基于概率生成，可能编造不存在的事实
- RAG 通过提供真实 Context 抑制幻觉

**问题 2：知识时效性**
- LLM 训练数据有截止日期
- RAG 可实时检索最新信息

**问题 3：私有数据**
- LLM 无法访问企业私有数据
- RAG 将私有知识库纳入检索范围

### 1.2 RAG 核心公式

\`\`\`
Answer = LLM(Context + Question)
Context = Retrieve(Question, KnowledgeBase)
\`\`\`

### 1.3 RAG 架构演进路线

| 阶段 | 架构 | 特点 | 问题 |
|------|------|------|------|
| Naive RAG | 问题→检索→拼接→生成 | 简单 | 检索质量差 |
| Advanced RAG | Query改写→混合检索→重排序→生成 | 精度提升 | 复杂度高 |
| Agentic RAG | Agent规划→动态检索→工具调用→反思 | 自适应 | 延迟高 |
| Graph RAG | 知识图谱+向量检索 | 多跳推理 | 构建成本高 |
| Modular RAG | 模块化组件按需组合 | 灵活 | 设计复杂 |

## 第二章：文档处理层

### 2.1 文档解析

**PDF 解析**
- PyMuPDF：基础文本提取
- Marker：支持表格、公式、布局
- Nougat：学术 PDF（LaTeX）
- Unstructured：多格式统一解析

**HTML 解析**
- BeautifulSoup：基础解析
- trafiluta：自动正文提取
- Readability：新闻文章提取

**表格处理**
- Table Transformer（TATR）：结构识别 + 单元格检测
- Camelot：PDF 表格提取
- Tabula：表格区域检测

### 2.2 分块策略

**固定大小分块**
\`\`\`python
# 参数
chunk_size = 512  # tokens
chunk_overlap = 50  # tokens

# 实现
from langchain.text_splitter import RecursiveCharacterTextSplitter
splitter = RecursiveCharacterTextSplitter(
    chunk_size=chunk_size,
    chunk_overlap=chunk_overlap,
    length_function=len
)
\`\`\`

**递归分块**
- 按段落→句子→词层级分割
- 保持语义完整性
- 适合结构化文档

**语义分块**
\`\`\`python
# 基于 Embedding 相似度
1. 将文档转为句子列表
2. 计算相邻句子 Embedding 相似度
3. 相似度 < 阈值 → 分块边界
\`\`\`

**文档结构分块**
- 按标题/章节层级分割
- 保留文档层级信息
- 适合技术文档、论文

### 2.3 分块最佳实践

| 场景 | 推荐策略 | 参数 |
|------|----------|------|
| 通用 | 递归分块 | 512 tokens, overlap 50 |
| 对话记录 | 语义分块 | 基于相似度阈值 |
| 代码 | 语法分块 | 按函数/类 |
| 表格 | 独立分块 | 不拆散表格 |
| 长文档 | 层级分块 | 章节+段落 |

## 第三章：检索引擎

### 3.1 Embedding 模型选型

| 模型 | 维度 | 语言 | 速度 | 精度 | 适用 |
|------|------|------|------|------|------|
| BGE-large-zh-v1.5 | 1024 | 中文 | 中 | 高 | 中文通用 |
| BGE-m3 | 1024 | 多语言 | 中 | 高 | 多模态 |
| text-embedding-3-large | 3072 | 多语言 | 慢 | 最高 | 英文 |
| m3e-base | 768 | 中文 | 快 | 中 | 轻量 |
| GTE-large-zh | 1024 | 中文 | 中 | 高 | 阿里 |
| Cohere embed-v3 | 1024 | 多语言 | 快 | 高 | 托管 |

### 3.2 向量数据库对比

| 维度 | Milvus | Qdrant | Pinecone | Weaviate |
|------|--------|--------|----------|----------|
| 规模 | 十亿级 | 亿级 | 托管 | 亿级 |
| 部署 | 自托管/K8s | Docker | 全托管 | 自托管 |
| 混合检索 | 支持 | 支持 | 有限 | 支持 |
| 成本 | 硬件 | 适中 | 按量 | 硬件 |
| 选择 | 大规模 | 中小规模 | 快速验证 | 语义搜索 |

### 3.3 混合检索

**为什么需要混合检索？**
- 向量检索：擅长语义匹配（"汽车"≈"轿车"）
- BM25：擅长关键词匹配（"GLM-4"精确匹配）

**RRF（Reciprocal Rank Fusion）**
\`\`\`python
def rrf(rankings, k=60):
    scores = {}
    for ranking in rankings:
        for rank, doc_id in enumerate(ranking):
            if doc_id not in scores:
                scores[doc_id] = 0
            scores[doc_id] += 1 / (k + rank + 1)
    return sorted(scores.items(), key=lambda x: -x[1])
\`\`\`

### 3.4 重排序（Reranker）

**为什么需要重排序？**
- 向量检索是 bi-encoder（独立编码），损失交互信息
- 重排序用 cross-encoder（联合编码），精度更高
- 2-stage 架构：检索召回（快）→ 重排序（准）

**Reranker 选型**
| 模型 | 语言 | 速度 | 精度 |
|------|------|------|------|
| BGE-Reranker-v2-m3 | 多语言 | 快 | 高 |
| BGE-Reranker-v2-gemma | 英文 | 中 | 很高 |
| Cohere Rerank 3.5 | 多语言 | 快 | SOTA |
| Jina Reranker v2 | 多语言 | 中 | 很高 |

## 第四章：生成层

### 4.1 Prompt 模板

\`\`\`
System: 你是一个专业的问答助手。仅基于以下上下文回答问题。
如果上下文中没有相关信息，请明确说明"根据提供的信息无法回答"。

Context:
{context}

Question:
{question}

Answer:
\`\`\`

### 4.2 引用溯源

**实现方式**
1. 检索时记录文档 ID + 位置
2. 生成时标注引用来源 [1][2]
3. 返回结果时附带引用信息

### 4.3 拒答机制

\`\`\`python
if confidence < threshold:
    return "根据提供的信息无法回答这个问题。"
\`\`\`

## 第五章：评估体系

### 5.1 RAGAS 指标

| 指标 | 公式 | 用途 |
|------|------|------|
| Faithfulness | 正确声明数/总声明数 | 检测幻觉 |
| Answer Relevancy | 反向问题相似度均值 | 检测答非所问 |
| Context Recall | 可归因声明数/GT 总声明数 | 检索完整性 |
| Context Precision | 有用片段数/总片段数 | 检索噪声 |

### 5.2 lm-evaluation-harness

\`\`\`bash
# 安装
pip install lm-eval

# 评估
lm_eval --model hf \\
    --model_args pretrained=THUDM/glm-4-9b-chat \\
    tasks mmlu,gsm8k,humaneval \\
    device cuda:0 \\
    batch_size 8
\`\`\`

### 5.3 评估最佳实践

1. **离线评估**：构建测试集，批量评估
2. **在线评估**：用户反馈 + A/B 测试
3. **人工评估**：定期 Bad Case 分析
4. **自动评估**：LLM-as-Judge + 规则

## 第六章：高级 RAG 模式

### 6.1 HyDE（Hypothetical Document Embeddings）

\`\`\`
Query → LLM 生成假答案 → Embedding 假答案 → 检索相似文档
\`\`\`

**原理**：假答案的向量比 Query 更接近真实文档

### 6.2 Query Expansion

\`\`\`python
# LLM 生成多个同义 Query
original = "RAG 如何工作？"
expanded = [
    "RAG 的工作原理是什么？",
    "检索增强生成是如何实现的？",
    "RAG 的技术细节有哪些？"
]
\`\`\`

### 6.3 Multi-hop RAG

\`\`\`
复杂问题 → 拆分子问题 → 链式检索 → 综合答案
\`\`\`

### 6.4 Agentic RAG

\`\`\`
Agent 自主决定：
- 是否需要检索？
- 用什么检索策略？
- 是否需要多轮检索？
- 是否调用其他工具？
\`\`\`

## 第七章：生产部署

### 7.1 架构设计

\`\`\`
用户 → API Gateway → RAG Service → {解析, 检索, 生成}
                    ↓
                向量数据库 + 文档存储
\`\`\`

### 7.2 性能优化
- 缓存热门 Query
- 异步索引更新
- 批量推理
- GPU 加速

### 7.3 监控告警
- 检索延迟 P50/P95/P99
- 生成质量评分
- 用户满意度
- 成本追踪

## 课后作业

1. 实现一个完整的 RAG Pipeline
2. 对比不同分块策略的 Recall@K
3. 用 RAGAS 评估你的 RAG 系统
4. 实现 HyDE + 混合检索 + 重排序`,

  // ... more courses would follow
};

async function main() {
  for (const [slug, content] of Object.entries(courses)) {
    const { error } = await supabase
      .from("courses")
      .update({ content })
      .eq("slug", slug);

    if (error) {
      console.log(`❌ ${slug}: ${error.message}`);
    } else {
      console.log(`✅ ${slug}: ${content.length} 字符`);
    }
  }
}

main().catch(console.error);
