# 系统设计：设计代码助手（Copilot）

## 1. 需求澄清

### 功能需求
- 实时代码补全（输入时提示）
- 代码解释和文档生成
- Bug 检测和修复建议
- 代码审查
- 跨文件理解

### 非功能需求
- **补全延迟**：< 200ms（用户无感知）
- **接受率**：> 30%
- **隐私**：代码不出域（企业版）

### 规模估算
| 指标 | 数值 |
|------|------|
| 开发者 | 100 万 |
| 日均补全请求 | 5000 万 |
| 平均补全长度 | 50 tokens |
| 代码库索引 | 1000 万文件 |

---

## 2. 高层架构图

```
┌─────────────────────────────────────────────────────────────────┐
│                        IDE 插件                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │ VS Code  │  │ IntelliJ │  │ Vim/Neo  │  │ Web IDE  │        │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘        │
└───────┼─────────────┼─────────────┼─────────────┼───────────────┘
        │             │             │             │
        └─────────────┴──────┬──────┴─────────────┘
                             │
                    ┌────────▼────────┐
                    │   LSP Gateway   │
                    │  (语言服务器)    │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
     ┌────────▼────────┐    │    ┌────────▼────────┐
     │  Context        │    │    │  Cache          │
     │  Builder        │    │    │  (KV + 语义)    │
     └────────┬────────┘    │    └────────┬────────┘
              │              │             │
              │    ┌─────────▼─────────┐  │
              │    │   Retrieval       │  │
              │    │   Engine          │  │
              │    └─────────┬─────────┘  │
              │              │             │
     ┌────────▼──────────────▼─────────────▼────────┐
     │              Inference Layer                  │
     │  ┌──────────┐ ┌──────────┐ ┌──────────┐     │
     │  │ Small    │ │ Medium   │ │ Large    │     │
     │  │ Model    │ │ Model    │ │ Model    │     │
     │  │ (1-3B)   │ │ (7B)     │ │ (70B)    │     │
     │  └──────────┘ └──────────┘ └──────────┘     │
     └──────────────────────────────────────────────┘
```

---

## 3. 核心模块详解

### 3.1 上下文构建

**上下文来源**（按优先级）：
```
1. 当前文件（光标前后 500 行）
2. 最近打开的文件（最近 5 个）
3. 相关文件检索（项目级 Embedding）
4. Import 依赖分析
5. 项目结构（README、配置文件）
```

**上下文窗口分配**：
```
总窗口: 8192 tokens
├── 系统 Prompt: 500 tokens
├── 项目上下文: 2000 tokens
├── 相关文件: 3000 tokens
├── 当前文件: 2000 tokens
└── 输出预留: 692 tokens
```

### 3.2 检索引擎

**项目级 Indexing**：
```python
# 构建项目索引
1. 解析 AST（Tree-sitter）
2. 提取：函数定义、类定义、Import
3. Embedding 每个代码块
4. 存储到向量数据库
```

**检索策略**：
- 精确匹配：函数名、变量名
- 语义匹配：功能相似的代码
- 结构匹配：AST 相似度

### 3.3 推理优化

**Speculative Decoding**：
```
小模型（1B）先猜 N 个 token → 大模型（70B）验证
延迟降低 2-3x，吞吐量提升 2x
```

**KV Cache 复用**：
- 相同前缀只算一次
- 编辑后只重新计算变化部分
- 缓存命中率 > 60%

**模型分级**：
| 任务 | 模型 | 延迟 |
|------|------|------|
| 单行补全 | 1-3B | < 100ms |
| 多行补全 | 7B | < 200ms |
| 代码解释 | 7B | < 500ms |
| 架构建议 | 70B | < 2s |

### 3.4 隐私保护

**企业版方案**：
- 本地部署 Embedding 模型
- 代码脱敏（变量名/字符串替换）
- 私有向量数据库
- 审计日志

---

## 4. 数据库 Schema

```sql
-- 项目表
CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255),
  repo_url TEXT,
  language VARCHAR(50),
  last_indexed TIMESTAMPTZ
);

-- 代码文件表
CREATE TABLE code_files (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID REFERENCES projects(id),
  path TEXT NOT NULL,
  content_hash VARCHAR(64),
  embedding vector(1024),
  ast_hash VARCHAR(64),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 补全记录表
CREATE TABLE completions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID,
  project_id UUID,
  prompt TEXT,
  suggestion TEXT,
  accepted BOOLEAN,
  latency_ms INT,
  model VARCHAR(50),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 索引
CREATE INDEX idx_files_project ON code_files(project_id, path);
CREATE INDEX idx_completions_user ON completions(user_id, created_at DESC);
```

---

## 5. Trade-off 讨论

### Trade-off 1：补全延迟 vs 质量
| | 小模型（快） | 大模型（慢） |
|---|---|---|
| 延迟 | < 100ms | > 500ms |
| 质量 | 中 | 高 |
| 接受率 | 25% | 35% |

**选择分级模型**：简单任务用小模型保证延迟，复杂任务用大模型保证质量。

### Trade-off 2：本地 vs 云端
| | 本地 | 云端 |
|---|---|---|
| 隐私 | ✅ | ❌ |
| 性能 | 受限 | 无限 |
| 成本 | 高（硬件） | 低（按量） |

**选择混合**：敏感代码本地处理，通用功能云端处理。

---

## 6. 高频追问

### Q1: 如何实现跨文件理解？
1. 构建项目级 Embedding 索引
2. 通过 Import 依赖分析关联文件
3. 通过 AST 分析调用链
4. 检索时返回相关代码片段

### Q2: 如何处理大型代码库（100万+ 文件）？
1. 分层索引：文件级 + 函数级
2. 增量更新：只索引变化文件
3. 分布式存储：按项目/目录分片
4. 缓存：热门文件缓存

### Q3: 如何评估补全质量？
1. **接受率**：用户接受补全的比例
2. **编辑相似度**：补全与最终代码的相似度
3. **延迟分布**：P50/P95/P99
4. **用户留存**：DAU/MAU
