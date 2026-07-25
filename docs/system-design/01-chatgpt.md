# 系统设计：设计 ChatGPT 类对话系统

## 1. 需求澄清（30秒）

### 功能需求
- 用户输入文本，AI 流式返回回复
- 支持多轮对话（上下文记忆）
- 支持图片/文件上传（多模态）
- 支持代码高亮、Markdown 渲染

### 非功能需求
- **首字延迟（TTFT）**：< 1 秒
- **生成速度**：> 30 tokens/秒
- **可用性**：99.9%
- **并发**：支持 100K 并发用户

### 规模估算
| 指标 | 数值 | 说明 |
|------|------|------|
| DAU | 1 亿 | |
| 每用户日均轮次 | 10 | |
| 每轮输入 tokens | 500 | |
| 每轮输出 tokens | 300 | |
| 总 tokens/天 | 8000 亿 | 1亿 × 10 × 800 |
| 峰值 QPS | 50K | 假设 20% 用户在高峰时段 |
| 存储/天 | ~2TB | 对话历史 |

---

## 2. 高层架构图

```
┌─────────────────────────────────────────────────────────────────────┐
│                          客户端                                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐            │
│  │ Web App  │  │ iOS App  │  │ Android  │  │   API    │            │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘            │
└───────┼─────────────┼─────────────┼─────────────┼───────────────────┘
        │             │             │             │
        └─────────────┴──────┬──────┴─────────────┘
                             │
                    ┌────────▼────────┐
                    │   CDN + WAF     │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │  Load Balancer  │
                    │  (L7, SSL终止)  │
                    └────────┬────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
┌───────▼───────┐   ┌────────▼────────┐   ┌───────▼───────┐
│  Gateway      │   │  Gateway        │   │  Gateway      │
│  (WebSocket)  │   │  (HTTP REST)    │   │  (gRPC)       │
└───────┬───────┘   └────────┬────────┘   └───────┬───────┘
        │                    │                    │
        └────────────────────┼────────────────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
     ┌────────▼────────┐    │    ┌────────▼────────┐
     │  Session        │    │    │  Rate Limiter   │
     │  Manager        │    │    │  (Redis)        │
     └────────┬────────┘    │    └────────┬────────┘
              │              │             │
              │    ┌─────────▼─────────┐  │
              │    │   LLM Router      │  │
              │    │  (模型选择/降级)   │  │
              │    └─────────┬─────────┘  │
              │              │             │
     ┌────────▼──────────────▼─────────────▼────────┐
     │              LLM Inference Cluster            │
     │  ┌──────────┐ ┌──────────┐ ┌──────────┐     │
     │  │ vLLM     │ │ vLLM     │ │ vLLM     │     │
     │  │ Node 1   │ │ Node 2   │ │ Node N   │     │
     │  │ (A100×8) │ │ (A100×8) │ │ (A100×8) │     │
     │  └──────────┘ └──────────┘ └──────────┘     │
     └──────────────────────────────────────────────┘
```

---

## 3. 核心模块详解

### 3.1 流式输出（SSE/WebSocket）

**职责**：将 LLM 生成的 token 实时推送给客户端

**技术选型**：
| 方案 | 优点 | 缺点 | 选择 |
|------|------|------|------|
| SSE | 简单、自动重连、HTTP 友好 | 单向通信 | ✅ 主方案 |
| WebSocket | 双向通信 | 复杂、需要心跳 | 文件上传用 |
| Long Polling | 兼容性好 | 延迟高 | ❌ |

**关键设计**：
```
Token 生成 → 缓冲区(50ms) → SSE Push → 客户端渲染
```

**背压控制（Backpressure）**：
- 客户端消费慢时，服务端降速
- 缓冲区满时，暂停生成
- 实现：TCP 窗口 + 应用层 ACK

### 3.2 上下文窗口管理

**问题**：LLM 有上下文长度限制（如 128K tokens），多轮对话会溢出

**策略对比**：
| 策略 | 优点 | 缺点 | 适用 |
|------|------|------|------|
| 滑动窗口 | 简单 | 丢失早期信息 | 短对话 |
| 摘要压缩 | 保留关键信息 | 摘要可能失真 | 长对话 |
| 关键信息提取 | 精确 | 实现复杂 | 重要对话 |
| 分层记忆 | 完整 | 系统复杂 | ✅ 生产方案 |

**分层记忆方案**：
```
Layer 1: 最近 20 轮（完整保留）
Layer 2: 20-100 轮（摘要压缩）
Layer 3: 100+ 轮（关键信息提取 + 向量存储）
```

**Token 计数**：
- 使用 `tiktoken` 精确计数
- 超过阈值时触发压缩
- 预留 20% buffer 给输出

### 3.3 会话存储

**热数据（Redis）**：
- 活跃会话（最近 30 分钟有交互）
- TTL: 30 分钟
- 结构：`session:{id} → Hash {messages, metadata}`

**冷数据（PostgreSQL）**：
- 历史会话持久化
- 按 user_id 分片
- 30 天自动归档到对象存储

### 3.4 LLM 推理服务

**vLLM 核心优化**：
- **PagedAttention**：KV Cache 分页，显存利用率 40% → 95%
- **Continuous Batching**：每个 token 后插入新请求，吞吐 2-4x
- **Prefix Caching**：相同 System Prompt 复用 KV Cache
- **Tensor Parallelism**：多 GPU 并行推理

**模型路由**：
```
请求 → Router → 判断复杂度
                ├── 简单 → GLM-4-Flash（快、便宜）
                ├── 中等 → GLM-4（平衡）
                └── 复杂 → GPT-4/Claude（最强）
```

**降级策略**：
- 主模型超时 → 备用模型
- 全部模型不可用 → 返回缓存结果
- 熔断：错误率 > 50% → 熔断 30s

---

## 4. 数据库 Schema

```sql
-- 用户表
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  plan VARCHAR(20) DEFAULT 'free', -- free/pro/enterprise
  token_quota INT DEFAULT 100000,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 会话表
CREATE TABLE conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  title TEXT,
  model VARCHAR(50),
  total_tokens INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 消息表
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID REFERENCES conversations(id),
  role VARCHAR(10) CHECK (role IN ('user','assistant','system')),
  content TEXT,
  tokens INT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 索引
CREATE INDEX idx_conv_user ON conversations(user_id, updated_at DESC);
CREATE INDEX idx_msg_conv ON messages(conversation_id, created_at);
CREATE INDEX idx_conv_updated ON conversations(updated_at DESC);

-- 按 user_id 分片（生产环境）
-- 使用 Citus 或手动分片
```

---

## 5. API 设计

### 创建对话
```http
POST /api/conversations
Authorization: Bearer {token}
Content-Type: application/json

{
  "model": "glm-4",
  "system_prompt": "你是一个有用的助手"
}

Response 201:
{
  "id": "uuid",
  "created_at": "2025-01-01T00:00:00Z"
}
```

### 发送消息（流式）
```http
POST /api/conversations/{id}/messages
Authorization: Bearer {token}
Accept: text/event-stream

{
  "content": "你好",
  "stream": true
}

Response: SSE Stream
data: {"delta": "你", "finish_reason": null}
data: {"delta": "好", "finish_reason": null}
data: {"delta": "", "finish_reason": "stop"}
```

### 获取对话历史
```http
GET /api/conversations/{id}/messages?limit=50&before={message_id}
Authorization: Bearer {token}

Response:
{
  "messages": [
    {"id": "uuid", "role": "user", "content": "你好", "tokens": 2},
    {"id": "uuid", "role": "assistant", "content": "你好！", "tokens": 3}
  ],
  "has_more": true
}
```

---

## 6. Trade-off 讨论

### Trade-off 1：流式协议选择
| | SSE | WebSocket |
|---|---|---|
| 复杂度 | 低 | 高 |
| 双向 | ❌ | ✅ |
| 自动重连 | ✅ | ❌ |
| 穿透性 | 好（HTTP） | 需特殊处理 |

**选择 SSE**：对话场景单向为主，SSE 更简单可靠。文件上传用单独 HTTP。

### Trade-off 2：上下文策略
| | 滑动窗口 | 摘要压缩 | 分层记忆 |
|---|---|---|---|
| 实现 | 简单 | 中等 | 复杂 |
| 信息保留 | 差 | 中 | 好 |
| 成本 | 低 | 中 | 高 |

**选择分层记忆**：生产环境需要平衡体验和成本。

### Trade-off 3：模型部署
| | API 调用 | 自研部署 | 混合 |
|---|---|---|---|
| 成本 | 高（按 token） | 中（硬件） | 中 |
| 可控性 | 低 | 高 | 中 |
| 启动速度 | 快 | 慢 | 快 |

**选择混合**：核心场景自研，兜底用 API。

---

## 7. 扩展性 & 容灾

### 水平扩展
```
                    ┌─────────────┐
                    │   Global    │
                    │   LB        │
                    └──────┬──────┘
           ┌───────────────┼───────────────┐
           │               │               │
    ┌──────▼──────┐ ┌──────▼──────┐ ┌──────▼──────┐
    │  Region US  │ │  Region EU  │ │  Region CN  │
    │  (3 AZs)    │ │  (3 AZs)    │ │  (3 AZs)    │
    └─────────────┘ └─────────────┘ └─────────────┘
```

### 多区域部署
- **就近路由**：用户就近访问最近区域
- **数据同步**：用户数据异步复制
- **模型同步**：模型权重定期同步

### 容灾
- **AZ 级容灾**：同一 Region 多 AZ 部署
- **Region 级容灾**：跨 Region 热备
- **降级模式**：高峰期关闭非核心功能

---

## 8. 高频追问 & 答案

### Q1: 如果流量增加 10 倍，怎么办？
**答**：
1. **Gateway 层**：无状态，直接水平扩展
2. **Session 层**：Redis Cluster 分片
3. **LLM 层**：增加 vLLM 节点，使用 K8s HPA 自动扩缩
4. **降级**：高峰期关闭摘要、关闭多模态

### Q2: 如何控制成本？
**答**：
1. **模型路由**：80% 请求用小模型
2. **缓存**：热门问题缓存结果
3. **批处理**：非实时请求批量处理
4. **Spot 实例**：推理节点用 Spot GPU

### Q3: 如何保证数据安全？
**答**：
1. **传输**：TLS 1.3
2. **存储**：AES-256 加密
3. **隔离**：多租户数据隔离
4. **审计**：所有操作记录审计日志

### Q4: 上下文溢出怎么处理？
**答**：
1. **预防**：实时监控 token 数
2. **压缩**：触发阈值时自动摘要
3. **分级**：最近轮次完整保留，远期压缩
4. **用户提示**：接近上限时提醒用户

### Q5: 如何评估系统质量？
**答**：
1. **技术指标**：TTFT、TPS、错误率
2. **业务指标**：DAU、留存率、对话轮次
3. **质量指标**：用户满意度、Bad Case 率
4. **成本指标**：单次对话成本、Token 成本
