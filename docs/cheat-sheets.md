# 速查表 — Prompt / RAG / Agent / 部署

## Prompt Engineering 速查

### 基础技术
| 技术 | 用法 | 示例 |
|------|------|------|
| Zero-shot | 直接提问 | "翻译成英文：你好" |
| Few-shot | 给示例 | "苹果→apple, 香蕉→banana, 橙子→" |
| CoT | 让 LLM 思考 | "请一步步推理" |
| Role Play | 设定角色 | "你是一个资深后端工程师" |
| Output Format | 指定格式 | "用 JSON 输出，字段：name, age, city" |

### 高级技术
| 技术 | 用法 | 效果 |
|------|------|------|
| Self-Consistency | 多次采样取多数 | 准确率 +10-20% |
| Tree of Thoughts | 树状搜索推理 | 复杂推理提升 |
| ReAct | 推理+行动交替 | Agent 核心 |
| Reflexion | 自我反思改进 | 失败自修正 |
| DSPy | 声明式优化 | 自动 Prompt 优化 |

### Function Calling 模板
```json
{
  "name": "search",
  "description": "搜索最新信息",
  "parameters": {
    "type": "object",
    "properties": {
      "query": {"type": "string", "description": "搜索关键词"}
    },
    "required": ["query"]
  }
}
```

---

## RAG 速查

### 分块策略选择
| 场景 | 推荐策略 | 参数 |
|------|---------|------|
| 通用 | 递归分块 | 512 tokens, overlap 50 |
| 结构化文档 | 文档结构分块 | 按标题层级 |
| 对话记录 | 语义分块 | 基于 Embedding 相似度 |
| 代码 | 语法分块 | 按函数/类 |
| 表格 | 表格独立分块 | 不拆散表格 |

### Embedding 选型
| 场景 | 推荐模型 | 维度 |
|------|---------|------|
| 中文通用 | BGE-large-zh-v1.5 | 1024 |
| 多语言 | BGE-m3 | 1024 |
| 轻量快速 | m3e-base | 768 |
| 最高精度 | text-embedding-3-large | 3072 |

### 向量数据库选型
| 规模 | 推荐 | 部署 |
|------|------|------|
| < 100万 | Qdrant | Docker |
| 100万-10亿 | Milvus | K8s |
| > 10亿 | Milvus Cluster | K8s |
| 快速验证 | Pinecone | 全托管 |

### RAGAS 指标目标值
| 指标 | 优秀 | 良好 | 需改进 |
|------|------|------|--------|
| Faithfulness | > 0.9 | 0.7-0.9 | < 0.7 |
| Answer Relevancy | > 0.9 | 0.7-0.9 | < 0.7 |
| Context Recall | > 0.85 | 0.7-0.85 | < 0.7 |
| Context Precision | > 0.8 | 0.6-0.8 | < 0.6 |

---

## Agent 速查

### 框架选择
| 场景 | 推荐框架 | 原因 |
|------|---------|------|
| 简单 RAG | LangChain | 简单直接 |
| 复杂 Agent | LangGraph | 图编排 + 状态机 |
| 多角色协作 | CrewAI | 预定义角色 |
| 对话式协作 | AutoGen | 自然语言对话 |
| 快速构建 | OpenAI Assistants | 原生 Function Calling |
| 低代码 | Dify | 可视化编排 |

### 工具调用安全清单
- [ ] 输入校验（类型、范围、格式）
- [ ] 权限最小化
- [ ] 超时控制（< 10s）
- [ ] 错误回退（重试/降级/兜底）
- [ ] 审计日志
- [ ] 参数白名单
- [ ] 输出校验

### Agent 评估指标
| 维度 | 指标 | 目标 |
|------|------|------|
| 结果 | Task Completion | > 80% |
| 结果 | Output Quality | > 4/5 |
| 路径 | 步骤数 | 接近最优 |
| 工具 | 选择正确率 | > 90% |
| 安全 | 有害输出率 | < 1% |

---

## 部署速查

### vLLM 核心配置
```python
from vllm import LLM, SamplingParams

llm = LLM(
    model="THUDM/glm-4-9b-chat",
    tensor_parallel_size=2,      # GPU 数量
    max_model_len=8192,           # 最大上下文
    gpu_memory_utilization=0.9,   # GPU 显存利用率
    enforce_eager=False,          # 使用 CUDA Graph
    enable_prefix_caching=True,   # Prompt 缓存
)

sampling_params = SamplingParams(
    temperature=0.7,
    max_tokens=2048,
    top_p=0.9,
)
```

### 推理优化技术
| 技术 | 效果 | 适用 |
|------|------|------|
| PagedAttention | 显存利用率 40% → 95% | 所有场景 |
| Continuous Batching | 吞吐量 2-4x | 高并发 |
| Prefix Caching | 相同 Prompt 复用 | System Prompt 固定 |
| Speculative Decoding | 延迟降低 2-3x | 低延迟要求 |
| FP8 量化 | 显存减半 | 精度要求不高 |
| INT4 量化 | 显存降 1/4 | 可接受精度损失 |

### 模型路由策略
| 任务复杂度 | 推荐模型 | 成本 |
|-----------|---------|------|
| 简单 | GPT-4o-mini / GLM-4-Flash | $ |
| 中等 | GPT-4o / GLM-4 | $$ |
| 复杂 | GPT-4 / Claude 3.5 | $$$ |
| 超长上下文 | Claude 3 (200K) / GLM-4 (128K) | $$$ |

### 监控指标
| 维度 | 指标 | 告警阈值 |
|------|------|---------|
| 延迟 | P50/P95/P99 | P99 > 5s |
| 错误率 | 5xx 比例 | > 1% |
| 成本 | Token 消耗/天 | 超预算 80% |
| 质量 | 用户满意度 | < 4/5 |
| 资源 | GPU 利用率 | > 90% |

---

## 面试速查

### 系统设计答题框架（4S）
1. **Scene**：需求澄清（功能/非功能/规模估算）
2. **Shape**：高层架构图 + 核心模块
3. **Scale**：数据库 Schema + API 设计 + 扩展性
4. **Trade-off**：关键决策的 Why & Why Not

### STAR 项目回答
- **Situation**：背景（为什么做）
- **Task**：任务（目标是什么）
- **Action**：行动（你怎么做，技术细节）
- **Result**：结果（量化成果）

### 高频追问
- "如果流量增加 10 倍，怎么办？"
- "这个方案有什么缺点？"
- "如果让你重新设计，你会怎么做？"
- "如何保证高可用？"
- "成本如何控制？"

### 必背数字
| 指标 | 参考值 |
|------|--------|
| 首字延迟 | < 1s |
| 生成速度 | > 30 tokens/s |
| 可用性 | 99.9% |
| RAG Recall@5 | > 85% |
| Agent Task Completion | > 80% |
| 用户满意度 | > 4/5 |
