# 项目深度：智能 PDF 问答系统

## 1. 项目背景 & 目标

### 背景
公司知识库有 10 万+ PDF 文档，员工查找信息效率低，平均每次查找耗时 15 分钟。

### 目标
- 构建智能问答系统，员工用自然语言查询知识库
- 查找时间从 15 分钟降至 30 秒
- 答案准确率 > 85%

## 2. 技术架构图

```
┌─────────────────────────────────────────────────────────────┐
│                        前端                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                  │
│  │ 上传     │  │ 问答     │  │ 引用查看 │                  │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘                  │
└───────┼─────────────┼─────────────┼─────────────────────────┘
        │             │             │
┌───────┼─────────────┼─────────────┼─────────────────────────┐
│       │    后端     │             │                         │
│  ┌────▼─────┐  ┌────▼─────┐  ┌────▼─────┐                  │
│  │ 文档     │  │ 问答     │  │ 引用     │                  │
│  │ 处理     │  │ 引擎     │  │ 溯源     │                  │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘                  │
│       │             │             │                         │
│  ┌────▼─────────────▼─────────────▼────┐                   │
│  │          RAG Pipeline               │                   │
│  │  解析 → 分块 → Embedding → 检索 → 生成                 │
│  └─────────────────────────────────────┘                   │
└─────────────────────────────────────────────────────────────┘
        │
┌───────┼─────────────────────────────────────────────────────┐
│       │                  存储层                              │
│  ┌────▼─────┐  ┌──────────┐  ┌──────────┐                  │
│  │ Milvus   │  │ PostgreSQL│  │  MinIO   │                  │
│  │ (向量)   │  │ (元数据) │  │ (文件)   │                  │
│  └──────────┘  └──────────┘  └──────────┘                  │
└─────────────────────────────────────────────────────────────┘
```

## 3. 核心代码片段

### 文档解析
```python
from marker import convert_pdf

def parse_pdf(file_path: str) -> list[Document]:
    """解析 PDF 为结构化文档"""
    # 使用 Marker 解析（支持表格、公式）
    result = convert_pdf(file_path)
    
    chunks = []
    for page in result.pages:
        # 文本块
        for block in page.text_blocks:
            chunks.append(Document(
                content=block.text,
                metadata={
                    "page": page.number,
                    "type": "text",
                    "bbox": block.bbox
                }
            ))
        
        # 表格
        for table in page.tables:
            chunks.append(Document(
                content=table_to_markdown(table),
                metadata={
                    "page": page.number,
                    "type": "table",
                    "data": table.data
                }
            ))
    
    return chunks
```

### RAG Pipeline
```python
from langchain.vectorstores import Milvus
from langchain.embeddings import HuggingFaceEmbeddings
from langchain.chains import RetrievalQA

class RAGPipeline:
    def __init__(self):
        self.embeddings = HuggingFaceEmbeddings(
            model_name="BAAI/bge-large-zh-v1.5"
        )
        self.vectorstore = Milvus(
            embedding_function=self.embeddings,
            connection_args={"host": "localhost", "port": "19530"}
        )
        self.qa_chain = RetrievalQA.from_chain_type(
            llm=ChatOpenAI(model="glm-4"),
            chain_type="stuff",
            retriever=self.vectorstore.as_retriever(search_kwargs={"k": 5})
        )
    
    def query(self, question: str) -> dict:
        # 1. Query 改写
        rewritten = self.rewrite_query(question)
        
        # 2. 检索
        docs = self.vectorstore.similarity_search(rewritten, k=10)
        
        # 3. 重排序
        reranked = self.rerank(docs, rewritten)
        
        # 4. 生成
        answer = self.qa_chain.run(rewritten)
        
        # 5. 引用溯源
        citations = [doc.metadata for doc in reranked[:3]]
        
        return {"answer": answer, "citations": citations}
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
    
    result = evaluate(
        dataset=dataset,
        metrics=[faithfulness, answer_relevancy, context_recall, context_precision]
    )
    
    return result
```

## 4. 架构决策记录（ADR）

### ADR-001：为什么选 Milvus 而不是 Qdrant？
- **背景**：需要支持十亿级向量
- **决策**：选择 Milvus
- **原因**：分布式、水平扩展、支持混合检索
- **后果**：运维复杂度增加

### ADR-002：为什么用 BGE-Reranker 而不是 Cohere Rerank？
- **背景**：需要中文重排序
- **决策**：选择 BGE-Reranker-v2-m3
- **原因**：中文更强、本地部署、无 API 成本
- **后果**：需要 GPU 资源

## 5. 踩坑 & 复盘

### 坑 1：表格数据解析失败
- **问题**：PDF 中的表格被解析为乱码
- **解决**：使用 Table Transformer 提取结构
- **结果**：表格问答准确率从 40% → 80%

### 坑 2：长文档检索噪音大
- **问题**：10 页文档分块后，检索到不相关块
- **解决**：加入文档结构信息（章节标题）作为元数据过滤
- **结果**：Recall@5 从 65% → 89%

### 坑 3：幻觉问题
- **问题**：LLM 编造不存在的答案
- **解决**：加入拒答机制 + 引用溯源
- **结果**：幻觉率从 15% → 3%

## 6. 量化结果

| 指标 | 优化前 | 优化后 | 提升 |
|------|--------|--------|------|
| Recall@5 | 65% | 89% | +37% |
| 答案准确率 | 70% | 88% | +26% |
| 平均查找时间 | 15min | 30s | -97% |
| 用户满意度 | 3.2/5 | 4.5/5 | +41% |
| 幻觉率 | 15% | 3% | -80% |

## 7. 面试话术

### 30 秒版
"我独立完成了智能 PDF 问答系统，实现了从文档解析到检索生成的完整链路。最大的挑战是表格数据处理，通过 Table Transformer 使表格问答准确率提升 40%。最终 Recall@5 达到 89%，用户查找时间从 15 分钟降至 30 秒。"

### 2 分钟版
"这个项目解决了公司知识库查找效率低的问题。我设计并实现了完整的 RAG Pipeline：用 Marker 解析 PDF（支持表格和公式），用 BGE-large-zh 做 Embedding，用 Milvus 做向量检索，用 BGE-Reranker 做重排序，最后用 GLM-4 生成答案。

项目中最大的挑战有三个：一是表格解析，普通 PDF 解析器无法正确处理表格，我用了 Table Transformer 提取结构；二是检索噪音，长文档分块后检索不准确，我加入了文档结构元数据过滤；三是幻觉问题，LLM 会编造答案，我加入了拒答机制和引用溯源。

最终效果：Recall@5 从 65% 提升到 89%，答案准确率从 70% 提升到 88%，用户查找时间从 15 分钟降至 30 秒，用户满意度从 3.2 提升到 4.5。"

### 5 分钟版
（包含完整架构图 + 代码演示 + 现场画架构 + 讨论扩展方向）

## 8. 扩展思考

- **多模态**：支持图片、图表理解
- **多轮对话**：支持追问和上下文记忆
- **实时更新**：文档变更后实时更新索引
- **多租户**：支持多部门数据隔离
