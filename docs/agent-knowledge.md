# LLM Agent 开发进阶 — 完整知识体系

## 目录
1. [Agent 核心概念](#核心概念)
2. [核心范式](#核心范式)
3. [Agent 框架对比](#框架对比)
4. [LangGraph 实战](#langgraph)
5. [多代理协作](#多代理协作)
6. [工具调用安全](#工具调用安全)
7. [Agent 评估](#评估)
8. [智谱 Agent 生态](#智谱生态)
9. [面试高频问题](#面试问题)

---

## 1. 核心概念

### Agent = LLM + 规划 + 记忆 + 工具

| 组件 | 作用 | 实现 |
|------|------|------|
| LLM | 大脑：理解、推理、决策 | GLM-4/5, GPT-4, Claude |
| Planning | 任务分解、步骤排序 | ReAct, Plan-and-Execute |
| Memory | 短期（上下文）+ 长期（向量存储） | 对话历史 + 经验库 |
| Tools | 外部 API、代码执行、数据库 | Function Calling |

### Agent vs Chatbot vs Workflow
| 类型 | 决策者 | 特点 |
|------|--------|------|
| Chatbot | LLM | 一问一答，无工具 |
| Workflow | 开发者 | 预定义流程，确定性 |
| Agent | LLM | 自主决策，动态路径 |

---

## 2. 核心范式

### ReAct（推理+行动交替）
```
Thought 1: 我需要搜索最新信息
Action 1: search("2025 LLM 进展")
Observation 1: 搜索结果...
Thought 2: 需要进一步分析
Action 2: python("分析数据")
Observation 2: 分析结果...
Final Answer: ...
```
**关键**：每步输出思考和行动，行动结果反馈给下一步
**适合**：需要多步推理的任务

### Plan-and-Execute
```
Plan: [搜索资料, 分析数据, 生成报告]
Execute Step 1 → Result 1
Execute Step 2 → Result 2
Execute Step 3 → Result 3
```
**关键**：先规划再执行
**适合**：任务步骤相对独立的场景

### Reflexion（自我反思）
```
Execute → Evaluate → {成功: 输出 | 失败: 生成反思 → 重新执行}
```
**关键**：失败后自我反思，生成改进策略
**适合**：需要多次尝试的复杂任务

### LATS（Language Agent Tree Search）
```
Tree of Thought + MCTS + Self-Reflection
- 生成多个候选步骤
- 评估每个步骤的价值
- 选择最有前景的路径
- 失败时回溯
```
**关键**：树状搜索 + 价值评估
**适合**：解空间大的复杂推理

---

## 3. Agent 框架对比

| 框架 | 定位 | 特点 | 适合场景 |
|------|------|------|----------|
| LangGraph | 图编排 | 状态机、有循环、有分支 | 复杂 Agent、多代理 |
| LangChain | 链式调用 | 线性 Pipeline、简单易用 | 简单 RAG、单代理 |
| CrewAI | 角色化团队 | 预定义角色、任务分配 | 多角色协作 |
| AutoGen | 对话式 | 代理间自然语言对话 | 对话式协作 |
| OpenAI Assistants | 原生 | Function Calling + Code Interpreter | 快速构建 |
| Dify | 低代码 | 可视化编排、拖拽 | 快速原型 |

### LangGraph vs LangChain
| 维度 | LangChain | LangGraph |
|------|-----------|-----------|
| 核心 | Chain（线性） | Graph（图） |
| 循环 | 不支持 | 支持 |
| 状态 | 无状态 | 有状态（State） |
| 分支 | 无 | 条件边 |
| 适合 | 简单 Pipeline | 复杂 Agent |

---

## 4. LangGraph 实战

### 核心概念
- **State**：共享状态，所有节点读写（TypedDict）
- **Node**：执行单元（函数），接收 State → 返回更新
- **Edge**：节点间的转移（固定边 or 条件边）
- **Graph**：完整的工作流（StateGraph）

### 基础示例
```python
from langgraph.graph import StateGraph, END
from typing import TypedDict, Annotated
import operator

class AgentState(TypedDict):
    messages: Annotated[list, operator.add]
    next_step: str
    result: str

def search_node(state):
    # 搜索信息
    result = search_tool(state["messages"][-1])
    return {"messages": [result], "next_step": "analyze"}

def analyze_node(state):
    # 分析结果
    analysis = llm_analyze(state["messages"])
    return {"messages": [analysis], "result": analysis}

# 构建图
graph = StateGraph(AgentState)
graph.add_node("search", search_node)
graph.add_node("analyze", analyze_node)
graph.add_edge("search", "analyze")
graph.add_edge("analyze", END)

app = graph.compile()
result = app.invoke({"messages": ["分析 LLM Agent 趋势"]})
```

### 条件分支
```python
def should_retry(state):
    if state["attempts"] >= 3:
        return "finish"
    if state["quality_score"] < 0.7:
        return "retry"
    return "finish"

graph.add_conditional_edges("execute", should_retry, {
    "retry": "plan",
    "finish": END
})
```

### Human-in-the-loop
```python
from langgraph.checkpoint.memory import MemorySaver

# 在需要人类确认的节点暂停
graph.add_node("human_review", review_node)
graph.add_edge("human_review", "finalize")

# 使用 Checkpoint 保存状态
checkpointer = MemorySaver()
app = graph.compile(checkpointer=checkpointer, interrupt_before=["human_review"])
```

---

## 5. 多代理协作

### Supervisor 模式
```
         Supervisor Agent
        /    |    \
  Agent1  Agent2  Agent3
  (独立 Scratchpad)
```
- Supervisor 决定谁执行
- 每个 Agent 独立工作空间
- 适合：任务分工明确

### 协作模式（Shared Scratchpad）
```
  Agent1 → Shared State → Agent2
              ↓
           Agent3
```
- 所有 Agent 共享工作空间
- 适合：协作创作、头脑风暴

### 层级模式
```
       Root Supervisor
      /       |       \
  Team1    Team2    Team3
  / \      / \      / \
 A1 A2   B1 B2   C1 C2
```
- 分层管理
- 适合：复杂项目

### 实战：多代理写作平台
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
```

---

## 6. 工具调用安全

### Function Calling 安全要点
1. **输入校验**：类型、范围、格式检查
2. **权限最小化**：每个工具最小权限
3. **超时控制**：防止工具调用阻塞
4. **错误回退**：失败时的降级策略
5. **审计日志**：记录每次工具调用

### 错误处理
```python
def safe_tool_call(tool_name, args, max_retries=3):
    for attempt in range(max_retries):
        try:
            result = execute_tool(tool_name, args)
            return validate_output(result)
        except ToolTimeout:
            if attempt == max_retries - 1:
                return fallback_response(tool_name)
            time.sleep(2 ** attempt)  # 指数退避
        except ToolError as e:
            return {"error": str(e), "retry": True}
```

### Prompt Injection 防御
- 输入长度限制 + 特殊字符过滤
- 分类器检测注入模式
- 用户输入与系统 Prompt 隔离
- NeMo Guardrails / LlamaGuard

---

## 7. Agent 评估

### 评估维度
| 维度 | 指标 | 工具 |
|------|------|------|
| 结果 | Task Completion, Output Quality | 规则 + LLM Judge |
| 路径 | 步骤数, 回溯次数, Token 消耗 | LangSmith |
| 工具 | 选择正确率, 参数正确率 | 自定义 |
| 安全 | 有害输出率, 注入成功率 | LlamaGuard |

### 实践工具
- **LangSmith**：自动追踪 + 评估 + Dashboard
- **Arize Phoenix**：轨迹可视化 + 评估
- **自定义**：规则 + LLM Judge 混合

### Trajectory Evaluation
评估 Agent 的完整决策路径：
1. 步骤是否最优（vs 人类专家路径）
2. 是否频繁回溯（效率低）
3. 工具选择是否正确
4. Token 消耗是否合理

---

## 8. 智谱 Agent 生态

### AutoGLM
- 自主完成 50+ 步骤复杂任务
- 跨应用、跨设备操作
- 自反思 + 自改进能力
- 技术：自规划 + 自反思 + 工具使用

### CogAgent
- 18B 视觉语言模型
- 双编码器（低分辨率 + 1120×1120 高分辨率）
- 纯截图输入，无需 HTML
- GUI 导航 SOTA（Mind2Web, AITW）
- CVPR 2024 Highlight

### GLM-PC
- 基于 CogAgent-9B 的桌面 Agent
- 仅需屏幕截图作为输入
- 自主操作电脑完成复杂任务

---

## 9. 面试高频问题

### Q1: 设计一个能自主完成多步骤任务的 Agent
- 规划：ReAct / Plan-and-Execute
- 工具：Function Calling + 错误处理
- 记忆：短期上下文 + 长期向量存储
- 评估：Task Completion + Trajectory Quality

### Q2: Agent 中工具调用失败如何处理？
- 重试：指数退避，最多 3 次
- 降级：换工具 / 换模型 / 部分结果
- 兜底：转人工 / 缓存 / 诚实拒绝

### Q3: 如何评估 Agent 的任务完成质量？
- 结果：Task Completion + Output Quality
- 路径：步骤数 + 回溯次数 + Token 消耗
- 工具：选择正确率 + 参数正确率
- 工具：LangSmith + Arize Phoenix

### Q4: LangGraph 和 LangChain 的关系？
- LangChain：线性 Chain，适合简单 Pipeline
- LangGraph：图编排扩展，适合复杂 Agent
- 多代理协作：LangGraph（状态机 + 图编排）

### Q5: 多代理如何协作？
- Supervisor 调度（中心化）
- 共享状态（去中心化）
- 层级管理（混合）

### Q6: Agent 幻觉如何抑制？
- 工具调用获取真实数据（而非 LLM 记忆）
- 引用溯源（标注信息来源）
- 输出审核（LLM-as-Judge 检测）
- 拒答机制（不确定时诚实拒绝）
