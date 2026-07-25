-- ============================================
-- 剩余深度课程（8-14）
-- ============================================

-- 7. 设计代码助手
UPDATE courses SET content = E'# 设计代码助手（Copilot）

## 核心挑战
- 延迟 < 200ms
- 上下文：当前文件 + 相关文件 + 项目结构
- 隐私：代码不出域

## 推理优化
- Speculative Decoding：小模型猜+大模型验证（延迟2-3x↓）
- KV Cache 复用：相同前缀只算一次
- 分级模型：简单→1-3B，复杂→70B

## 跨文件理解
1. 项目级 Embedding 索引
2. Import 依赖分析
3. AST 调用链分析

## 隐私保护
- 本地部署 Embedding 模型
- 代码脱敏（变量名/字符串替换）
- 私有向量数据库

## 追问
1. 大型代码库？→ 分层索引 + 增量更新
2. 评估？→ 接受率 + 编辑相似度 + 延迟
3. 隐私保护？→ 本地Embedding + 代码脱敏
4. 冷启动问题？→ 预训练 + 少样本
5. 如何处理代码版权？→ 过滤 + 引用溯源

## 评分标准
- 优秀：完整架构 + 隐私方案 + 追问
- 良好：核心模块 + 基本评估
- 及格：能说出基本流程' WHERE slug = 'llm-system-design-copilot';

-- 8. 项目实战：智能 PDF 问答系统
UPDATE courses SET content = E'# 项目实战：智能 PDF 问答系统

## 项目背景
公司知识库有 10 万+ PDF 文档，员工查找信息效率低，平均每次查找耗时 15 分钟。

## 技术栈
LangChain + GLM-4 + Milvus + RAGAS + FastAPI + Next.js

## 架构
PDF Upload → 解析(Nougat) → 分块(递归) → Embedding(BGE) → Milvus → 检索 → GLM-4 → 答案+引用

## 核心功能
1. PDF 解析：文字 + 表格(Table Transformer) + 图片(OCR)
2. 语义分块：递归分块 512 tokens + 100 overlap
3. 混合检索：BM25 + 向量检索 → RRF 融合
4. 重排序：BGE-Reranker-v2-m3
5. 引用溯源：标注答案来源页码
6. 评估报告：RAGAS 四指标自动计算

## 项目结构
```
/pdf-qa
  /backend
    main.py          # FastAPI 服务
    rag_chain.py     # RAG Pipeline
    evaluation.py    # RAGAS 评估
  /frontend
    pages/           # Next.js 页面
    components/      # React 组件
```

## 核心代码

### 文档解析
```python
from marker import convert_pdf

def parse_pdf(file_path: str) -> list[Document]:
    result = convert_pdf(file_path)
    chunks = []
    for page in result.pages:
        for block in page.text_blocks:
            chunks.append(Document(
                content=block.text,
                metadata={"page": page.number, "type": "text"}
            ))
    return chunks
```

### RAG Pipeline
```python
from langchain.vectorstores import Milvus
from langchain.embeddings import HuggingFaceEmbeddings

class RAGPipeline:
    def __init__(self):
        self.embeddings = HuggingFaceEmbeddings(
            model_name="BAAI/bge-large-zh-v1.5"
        )
        self.vectorstore = Milvus(
            embedding_function=self.embeddings,
            connection_args={"host": "localhost", "port": "19530"}
        )

    def query(self, question: str) -> dict:
        docs = self.vectorstore.similarity_search(question, k=10)
        reranked = self.rerank(docs, question)
        answer = self.generate_answer(question, reranked[:5])
        return {"answer": answer, "citations": [d.metadata for d in reranked[:3]]}
```

### RAGAS 评估
```python
from ragas import evaluate
from ragas.metrics import faithfulness, answer_relevancy, context_recall, context_precision

def evaluate_rag(test_set: list[dict]):
    dataset = Dataset.from_dict({
        "question": [item["question"] for item in test_set],
        "answer": [item["answer"] for item in test_set],
        "contexts": [item["contexts"] for item in test_set],
        "ground_truth": [item["ground_truth"] for item in test_set]
    })
    return evaluate(dataset=dataset, metrics=[
        faithfulness, answer_relevancy, context_recall, context_precision
    ])
```

## 量化结果
| 指标 | 优化前 | 优化后 | 提升 |
|------|--------|--------|------|
| Recall@5 | 65% | 89% | +37% |
| 答案准确率 | 70% | 88% | +26% |
| 平均查找时间 | 15min | 30s | -97% |
| 用户满意度 | 3.2/5 | 4.5/5 | +41% |
| 幻觉率 | 15% | 3% | -80% |

## 踩坑记录
1. 表格解析失败 → 使用 Table Transformer 提取结构
2. 长文档检索噪音大 → 加入文档结构元数据过滤
3. 幻觉问题 → 加入拒答机制 + 引用溯源

## 面试话术
"我独立完成了从文档解析到检索生成的完整链路，并用 RAGAS 量化评估了检索质量。项目中最大的挑战是表格数据的处理——我用了 Table Transformer 提取结构，使表格问答准确率提升了 40%。"' WHERE slug = 'portfolio-rag-project';

-- 9. 项目实战：多代理协作平台
UPDATE courses SET content = E'# 项目实战：多代理协作写作平台

## 项目背景
输入主题 → 自动输出高质量文章。

## 技术栈
LangGraph + GLM-4 + PostgreSQL + LangGraph Server + React

## 架构
User Request → Supervisor Agent → {Researcher, Writer, Reviewer} → Shared State → Final Output

## 核心功能
1. Supervisor 调度（任务分配 + 进度追踪）
2. Researcher Agent（搜索 + 整理资料）
3. Writer Agent（基于研究写初稿）
4. Reviewer Agent（审查 + 给出修改建议）
5. Editor Agent（根据建议修改终稿）
6. 可视化：实时展示 Agent 协作过程

## 核心代码

```python
class WritingState(TypedDict):
    topic: str
    research: str
    draft: str
    review: str
    final: str

def researcher(state):
    return {"research": research_agent(state["topic"])}

def writer(state):
    return {"draft": writing_agent(state["topic"], state["research"])}

def reviewer(state):
    return {"review": review_agent(state["draft"])}

def editor(state):
    return {"final": editing_agent(state["draft"], state["review"])}

graph = StateGraph(WritingState)
graph.add_node("researcher", researcher)
graph.add_node("writer", writer)
graph.add_node("reviewer", reviewer)
graph.add_node("editor", editor)
graph.add_edge("researcher", "writer")
graph.add_edge("writer", "reviewer")
graph.add_edge("reviewer", "editor")
graph.add_edge("editor", END)

app = graph.compile()
result = app.invoke({"topic": "LLM Agent 最新进展"})
```

## 量化结果
- 文章质量评分 4.2/5（vs 人工 4.5）
- 生产效率提升 5x

## 面试话术
"用 LangGraph 实现了多角色协作，每个 Agent 独立 Prompt，通过共享状态协作。项目中最大的挑战是 Agent 间的协调——我用 Supervisor 模式解决了任务分配问题。"' WHERE slug = 'portfolio-agent-project';
