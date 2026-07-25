# LLM 评估体系 — 完整指南

## 目录
1. [评估概览](#概览)
2. [RAG 评估](#rag-评估)
3. [Agent 评估](#agent-评估)
4. [模型能力评估](#模型评估)
5. [安全评估](#安全评估)
6. [评估工具链](#工具链)
7. [面试高频问题](#面试问题)

---

## 1. 评估概览

### 为什么评估如此重要？
- LLM 应用涉及多环节，任何环节出问题都影响最终效果
- 没有评估就没有优化
- 大厂面试必考评估体系设计

### 评估层次
| 层次 | 内容 | 工具 |
|------|------|------|
| 组件级 | 检索质量、生成质量 | RAGAS, 自定义 |
| 系统级 | 端到端任务完成率 | 自定义 + LLM Judge |
| 业务级 | 用户满意度、成本、延迟 | Grafana, 自定义 |

### 评估类型
| 类型 | 时机 | 方法 |
|------|------|------|
| 离线评估 | 开发阶段 | 测试集批量评估 |
| 在线评估 | 生产阶段 | A/B 测试 + 用户反馈 |
| 人工评估 | 抽检 | 专家标注 |

---

## 2. RAG 评估

### RAGAS 指标体系
| 指标 | 范围 | 含义 | 公式 |
|------|------|------|------|
| Faithfulness | 0-1 | 答案是否基于 Context（无幻觉） | 正确声明数 / 总声明数 |
| Answer Relevancy | 0-1 | 答案是否切题 | 反向问题相似度均值 |
| Context Recall | 0-1 | 检索是否完整 | 可归因声明数 / GT 总声明数 |
| Context Precision | 0-1 | 检索是否精准 | 有用片段数 / 总片段数 |

### 检索评估指标
| 指标 | 含义 | 目标 |
|------|------|------|
| Recall@K | Top-K 中包含正确答案的比例 | > 85% |
| MRR | 正确答案排名的倒数均值 | > 0.7 |
| MAP | 考虑排序的精确率 | > 0.75 |
| NDCG | 考虑位置的相关性评分 | > 0.8 |

### 生成评估指标
| 指标 | 含义 | 工具 |
|------|------|------|
| BLEU | N-gram 重叠度 | nltk |
| ROUGE | 召回率导向 | rouge-score |
| BERTScore | 语义相似度 | bert-score |
| GPT-4 Score | GPT-4 打分 1-10 | OpenAI API |

### 实践代码（RAGAS）
```python
from ragas import evaluate
from ragas.metrics import (
    faithfulness, answer_relevancy,
    context_recall, context_precision
)
from datasets import Dataset

data = {
    "question": ["什么是 RAG？", "如何解决幻觉？"],
    "answer": ["RAG 是检索增强生成...", "通过 RAG、微调..."],
    "contexts": [["RAG 全称..."], ["幻觉产生于..."]],
    "ground_truth": ["RAG 是...", "通过..."]
}

result = evaluate(
    dataset=Dataset.from_dict(data),
    metrics=[faithfulness, answer_relevancy, context_recall, context_precision]
)
print(result)
```

---

## 3. Agent 评估

### 评估维度
| 维度 | 指标 | 说明 |
|------|------|------|
| 结果 | Task Completion | 是否完成目标 |
| 结果 | Output Quality | 输出质量评分 |
| 路径 | 步骤数 | 是否最优路径 |
| 路径 | 回溯次数 | 是否频繁修正 |
| 路径 | Token 消耗 | 效率 |
| 工具 | 选择正确率 | 是否选对工具 |
| 工具 | 参数正确率 | 参数是否正确 |

### Trajectory Evaluation
评估 Agent 的完整决策路径：
1. **最优性**：vs 人类专家路径
2. **效率**：步骤数、Token 消耗
3. **鲁棒性**：面对异常的处理
4. **安全性**：是否有危险操作

### 实践工具
| 工具 | 特点 |
|------|------|
| LangSmith | 自动追踪 + LLM-as-Judge 评估 |
| Arize Phoenix | 轨迹可视化 + 评估 |
| 自定义 | 规则 + LLM Judge 混合 |

---

## 4. 模型能力评估

### lm-eval-harness
EleutherAI 开源的模型评估框架，支持 100+ benchmark。

| Benchmark | 类型 | 说明 |
|-----------|------|------|
| MMLU | 知识 | 57 个科目，15908 题 |
| GSM8K | 数学 | 小学数学应用题 |
| MATH | 数学 | 竞赛级数学题 |
| HumanEval | 代码 | Python 代码生成 |
| MBPP | 代码 | 基础编程题 |
| BBH | 推理 | 23 个挑战性任务 |
| ARC | 科学 | 小学科学题 |
| TruthfulQA | 安全 | 事实准确性 |
| IFEval | 指令 | 指令遵循 |
| MT-Bench | 对话 | 多轮对话质量 |

### 实践代码
```bash
# 安装
pip install lm-eval

# 评估
lm_eval --model hf \
    --model_args pretrained=THUDM/glm-4-9b-chat \
    tasks mmlu,gsm8k,humaneval \
    device cuda:0 \
    batch_size 8
```

---

## 5. 安全评估

### 评估维度
| 维度 | 指标 | 工具 |
|------|------|------|
| 有害性 | 有害内容比例 | Perspective API, LlamaGuard |
| 事实性 | 幻觉率 | TruthfulQA, RAGAS Faithfulness |
| 隐私 | PII 泄露率 | 自定义检测 |
| 注入 | Prompt Injection 成功率 | 自定义攻击集 |
| 偏见 | 群体差异 | BBQ, WinoBias |

### 安全评估工具
| 工具 | 特点 |
|------|------|
| LlamaGuard | Meta 开源安全分类器 |
| NeMo Guardrails | NVIDIA 开源安全框架 |
| LLM Guard | 多维度安全评估 |
| PromptArmor | Prompt Injection 检测 |

---

## 6. 评估工具链

### 工具对比
| 工具 | 开源 | 定位 | 强项 |
|------|------|------|------|
| RAGAS | ✅ | RAG 评估 | 四指标一站式 |
| lm-eval-harness | ✅ | 模型能力 | 100+ benchmark |
| TruLens | ✅ | RAG + 追踪 | 实时 Dashboard |
| ARES | ✅ | RAG 评估 | 合成数据 + 统计 |
| LangSmith | ❌ | 全链路 | LangChain 深度集成 |
| Arize Phoenix | ✅ | 可观测性 | 轨迹可视化 |
| Weights & Biases | ❌ | 实验追踪 | 训练 + 评估 |

### 自建评估体系
```
离线评估：测试集 → 自动评估 → 报告
在线评估：A/B 测试 → 用户反馈 → Dashboard
人工评估：定期抽检 → Bad Case → 改进
```

---

## 7. 面试高频问题

### Q1: 如何设计 RAG 评估体系？
- 检索层：Recall@K、MRR
- 生成层：Faithfulness、Relevancy
- 端到端：RAGAS 四指标
- 在线：A/B 测试 + 用户反馈

### Q2: 如何评估 Agent 的任务完成质量？
- 结果：Task Completion + Output Quality
- 路径：步骤数 + 回溯次数
- 工具：选择正确率 + 参数正确率

### Q3: lm-eval-harness 支持哪些 benchmark？
- MMLU（知识）、GSM8K（数学）、HumanEval（代码）
- BBH（推理）、TruthfulQA（安全）、IFEval（指令）

### Q4: 如何评估 LLM 应用的安全性？
- 有害性：LlamaGuard + Perspective API
- 事实性：TruthfulQA + RAGAS
- 隐私：PII 检测
- 注入：Prompt Injection 攻击集
