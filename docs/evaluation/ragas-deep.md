# 评估实战：RAGAS 指标详解

## 1. Faithfulness（忠实度）

### 定义
答案中的声明是否基于给定 Context，无幻觉。

### 公式
```
Faithfulness = 答案中可验证声明的正确数 / 总声明数
```

### 计算代码
```python
from ragas.metrics import faithfulness
from ragas import evaluate
from datasets import Dataset

data = {
    "question": ["什么是 RAG？"],
    "answer": ["RAG 是检索增强生成，通过检索外部知识增强 LLM 能力。"],
    "contexts": [["RAG 全称 Retrieval-Augmented Generation，是一种通过检索外部知识库来增强大语言模型生成能力的技术。"]]
}

result = evaluate(
    dataset=Dataset.from_dict(data),
    metrics=[faithfulness]
)
print(result['faithfulness'])  # 0.0 - 1.0
```

### 解读指南
| 值 | 含义 | 行动 |
|---|---|---|
| > 0.9 | 优秀 | 保持 |
| 0.7-0.9 | 良好 | 检查低分样本 |
| 0.5-0.7 | 需改进 | 优化 Prompt + 检索 |
| < 0.5 | 严重 | 重新设计 Pipeline |

### 改进策略
1. **提高检索质量**：更相关的 Context
2. **Prompt 约束**："仅基于给定信息回答"
3. **引用溯源**：标注答案来源
4. **输出审核**：LLM-as-Judge 检测

---

## 2. Answer Relevancy（答案相关性）

### 定义
答案是否真正回答了问题。

### 公式
```
Answer Relevancy = 从答案反向生成的问题与原始问题的相似度均值
```

### 计算代码
```python
from ragas.metrics import answer_relevancy

result = evaluate(
    dataset=dataset,
    metrics=[answer_relevancy]
)
```

### 解读指南
| 值 | 含义 | 行动 |
|---|---|---|
| > 0.9 | 优秀 | 保持 |
| 0.7-0.9 | 良好 | 检查答非所问 |
| < 0.7 | 需改进 | 优化 Prompt |

### 改进策略
1. **Query 理解**：准确识别用户意图
2. **Prompt 优化**：明确要求"直接回答问题"
3. **拒答机制**：无相关信息时诚实拒绝

---

## 3. Context Recall（上下文召回率）

### 定义
检索结果是否覆盖完整答案所需信息。

### 公式
```
Context Recall = Ground Truth 中能归因于 Context 的声明数 / Ground Truth 总声明数
```

### 解读指南
| 值 | 含义 | 行动 |
|---|---|---|
| > 0.85 | 优秀 | 保持 |
| 0.7-0.85 | 良好 | 增加检索数量 |
| < 0.7 | 需改进 | 优化检索策略 |

### 改进策略
1. **增加 Top-K**：检索更多文档
2. **混合检索**：BM25 + 向量
3. **Query 改写**：HyDE、Query Expansion
4. **Multi-hop**：复杂问题拆分

---

## 4. Context Precision（上下文精确率）

### 定义
检索结果中有多大比例是有用的。

### 解读指南
| 值 | 含义 | 行动 |
|---|---|---|
| > 0.8 | 优秀 | 保持 |
| 0.6-0.8 | 良好 | 优化分块 |
| < 0.6 | 需改进 | 减少噪声 |

### 改进策略
1. **优化分块**：调整分块大小和重叠
2. **重排序**：Cross-Encoder Reranker
3. **过滤**：按元数据过滤

---

## 5. 完整评估流程

```python
from ragas import evaluate
from ragas.metrics import faithfulness, answer_relevancy, context_recall, context_precision
from datasets import Dataset

# 1. 构建测试集
test_data = {
    "question": ["Q1", "Q2", "Q3"],
    "answer": ["A1", "A2", "A3"],
    "contexts": [["C1"], ["C2"], ["C3"]],
    "ground_truth": ["GT1", "GT2", "GT3"]
}

# 2. 评估
result = evaluate(
    dataset=Dataset.from_dict(test_data),
    metrics=[faithfulness, answer_relevancy, context_recall, context_precision]
)

# 3. 输出报告
print(f"Faithfulness: {result['faithfulness']:.2f}")
print(f"Answer Relevancy: {result['answer_relevancy']:.2f}")
print(f"Context Recall: {result['context_recall']:.2f}")
print(f"Context Precision: {result['context_precision']:.2f}")
```

## 6. 工具集成

| 工具 | 用途 | 特点 |
|------|------|------|
| RAGAS | RAG 评估 | 四指标一站式 |
| lm-eval-harness | 模型能力 | 100+ benchmark |
| TruLens | 实时追踪 | Dashboard |
| Arize Phoenix | 可观测性 | 轨迹可视化 |
| LangSmith | 全链路 | LangChain 集成 |
