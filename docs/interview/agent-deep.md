# 面试题深度：Agent 专题

## 题目 1：设计一个能自主完成多步骤任务的 Agent

### 考察点
- Agent 架构设计能力
- 对 ReAct/Plan-and-Execute 的理解
- 工具调用安全意识
- 评估思维

### 答题框架
```
1. Agent 核心组件
2. 工作流设计
3. 工具调用设计
4. 错误处理
5. 评估体系
```

### 标准答案

#### 1. Agent 核心组件
```
Agent = LLM + 规划 + 记忆 + 工具

LLM：大脑（理解、推理、决策）
规划：任务分解、步骤排序
记忆：短期（上下文）+ 长期（向量存储）
工具：外部 API、代码执行、数据库
```

#### 2. 工作流设计

**ReAct 模式**：
```
Thought 1 → Action 1 → Observation 1
Thought 2 → Action 2 → Observation 2
... → Final Answer
```

**Plan-and-Execute 模式**：
```
Plan: [Step1, Step2, Step3]
Execute Step 1 → Result 1
Execute Step 2 → Result 2
Execute Step 3 → Result 3
```

**选择**：
- 任务步骤明确 → Plan-and-Execute
- 需要动态调整 → ReAct
- 复杂任务 → 混合（先 Plan 后 ReAct 执行）

#### 3. 工具调用设计

**工具定义**：
```python
tools = [
    {
        "name": "search",
        "description": "搜索最新信息",
        "parameters": {"query": "string"}
    },
    {
        "name": "python",
        "description": "执行 Python 代码",
        "parameters": {"code": "string"}
    }
]
```

**安全控制**：
- 输入校验
- 权限最小化
- 超时控制（< 10s）
- 审计日志

#### 4. 错误处理
```
工具调用失败 → 重试（指数退避）
→ 换工具（Plan B）
→ 降级返回（部分结果）
→ 转人工
```

#### 5. 评估体系
- Task Completion：是否完成目标
- Trajectory Quality：路径是否最优
- Tool Use Correctness：工具选择是否正确

### 追问链

**追问 1：ReAct 和 Plan-and-Execute 的区别？**
- ReAct：每步思考+行动交替，适合动态场景
- Plan-and-Execute：先规划再执行，适合步骤明确场景

**追问 2：Agent 幻觉如何抑制？**
- 工具调用获取真实数据
- 引用溯源
- 输出审核

**追问 3：如何评估 Agent 质量？**
- 结果：Task Completion + Output Quality
- 路径：步骤数 + 回溯次数
- 工具：选择正确率 + 参数正确率

### 评分标准

| 等级 | 标准 |
|------|------|
| 优秀 | 完整架构 + 工具设计 + 错误处理 + 评估 |
| 良好 | 核心组件 + 基本工具设计 |
| 及格 | 能说出 ReAct 流程 |
| 不及格 | 概念不清 |

---

## 题目 2：Agent 中工具调用失败如何处理？

### 考察点
- 容错设计能力
- 实际工程经验
- 分层思维

### 标准答案

#### 三层容错策略

**第一层：重试**
```python
for attempt in range(max_retries):
    try:
        result = call_tool(tool, args)
        return result
    except Timeout:
        if attempt == max_retries - 1:
            return fallback()
        time.sleep(2 ** attempt)  # 指数退避
    except ToolError as e:
        return {"error": str(e)}
```

**第二层：降级**
- 换工具（Plan B）
- 换模型（大 → 小）
- 部分结果（返回已完成 + 说明）

**第三层：兜底**
- 转人工
- 返回缓存
- 诚实拒绝

### 追问链

**追问 1：什么情况下不应该重试？**
- 非幂等操作（如支付）
- 参数错误（重试无意义）
- 权限错误

**追问 2：如何设计幂等工具？**
- 唯一请求 ID
- 服务端去重
- 客户端 Token

### 评分标准

| 等级 | 标准 |
|------|------|
| 优秀 | 三层策略 + 幂等设计 + 实际案例 |
| 良好 | 重试 + 降级基本思路 |
| 及格 | 能说出重试 |
| 不及格 | 无思路 |

---

## 题目 3：如何评估 Agent 的任务完成质量？

### 考察点
- 评估体系设计
- 多维度思考
- 实际落地能力

### 标准答案

#### 评估维度

**结果评估**：
- Task Completion：是否完成目标（0/1 或分级）
- Output Quality：输出质量评分（LLM-as-Judge）

**路径评估（Trajectory）**：
- 步骤数：vs 最优路径
- 回溯次数：是否频繁修正
- Token 消耗：效率

**工具评估**：
- Tool Selection：是否选对工具
- Tool Arguments：参数是否正确
- Tool Efficiency：工具调用次数

#### 实践工具
- LangSmith：自动追踪 + 评估
- Arize Phoenix：轨迹可视化
- 自定义：规则 + LLM Judge

### 追问链

**追问 1：LLM-as-Judge 有偏见怎么办？**
- 多个 Judge 投票
- 人工抽检校准
- 规则 + Judge 混合

**追问 2：如何建立 Agent 评估的 Ground Truth？**
- 人工标注（黄金标准）
- 众包标注
- 自动标注（规则 + LLM）

### 评分标准

| 等级 | 标准 |
|------|------|
| 优秀 | 三维度 + 工具 + 实际案例 |
| 良好 | 结果 + 路径基本思路 |
| 及格 | 能说出 Task Completion |
| 不及格 | 无思路 |
