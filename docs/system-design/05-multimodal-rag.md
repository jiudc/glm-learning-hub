# 系统设计：设计多模态 RAG 系统

## 1. 需求澄清

### 功能需求
- 支持文本、图片、表格、PDF、视频输入
- 跨模态检索（以文搜图、以图搜文）
- 多模态生成（文本+图片输出）
- 引用溯源（标注来源：文字段落/图片/表格位置）

### 非功能需求
- **检索延迟**：< 500ms
- **准确率**：Recall@5 > 85%
- **支持模态**：文本、图片、表格、图表、视频帧

### 规模估算
| 指标 | 数值 |
|------|------|
| 文档总量 | 1000 万 |
| 图片总量 | 5000 万 |
| 视频总量 | 100 万小时 |
| 日均查询 | 1000 万 |

---

## 2. 高层架构图

```
┌─────────────────────────────────────────────────────────────────┐
│                         用户入口                                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │ 文本输入 │  │ 图片上传 │  │ PDF上传  │  │ 语音输入 │        │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘        │
└───────┼─────────────┼─────────────┼─────────────┼───────────────┘
        │             │             │             │
        └─────────────┴──────┬──────┴─────────────┘
                             │
                    ┌────────▼────────┐
                    │  多模态解析器   │
                    └────────┬────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
┌───────▼───────┐   ┌────────▼────────┐   ┌───────▼───────┐
│  文本处理     │   │  图片处理       │   │  表格处理     │
│  (分块+Embed) │   │  (OCR+ Caption) │   │  (TATR+描述)  │
└───────┬───────┘   └────────┬────────┘   └───────┬───────┘
        │                    │                    │
        └────────────────────┼────────────────────┘
                             │
                    ┌────────▼────────┐
                    │  统一向量空间   │
                    │  (CLIP/BGE-m3)  │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │  多模态检索     │
                    │  (向量+关键词)  │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │  多模态生成     │
                    │  (GLM-5V/GPT4V) │
                    └─────────────────┘
```

---

## 3. 核心模块详解

### 3.1 多模态解析

**文本**：
- 分块：递归分块 512 tokens
- Embedding：BGE-large-zh

**图片**：
```
图片 → OCR（文字提取）+ Caption（视觉描述）→ 文本 → Embedding
```

**表格**：
```
表格 → Table Transformer（结构提取）→ 自然语言描述 → Embedding
```

**视频**：
```
视频 → 关键帧提取（1帧/秒）→ 每帧 Caption → 音频转文字 → 合并
```

**PDF**：
```
PDF → 页面分割 → {文本块, 图片, 表格} → 分别处理
```

### 3.2 统一向量空间

**方案对比**：
| 方案 | 优点 | 缺点 | 选择 |
|------|------|------|------|
| CLIP | 图文统一 | 中文弱 | ❌ |
| BGE-m3 | 多语言+多模态 | 图片需 Caption | ✅ |
| 分离索引 | 精确 | 复杂 | ❌ |

**BGE-m3 方案**：
1. 所有模态转为文本（Caption/OCR/描述）
2. 统一 Embedding 到同一向量空间
3. 支持稠密+稀疏+多向量

### 3.3 多模态检索

**检索策略**：
```
文本 Query → 文本 + 图片 + 表格 检索
图片 Query → 图片 + 相关文本 检索
混合 Query → 多模态融合检索
```

**融合算法**：
- RRF（Reciprocal Rank Fusion）
- 模态权重：根据 Query 类型动态调整

### 3.4 多模态生成

**模型选型**：
| 模型 | 能力 | 延迟 | 成本 |
|------|------|------|------|
| GLM-5V | 图文理解 | 中 | 中 |
| GPT-4V | 最强 | 慢 | 高 |
| CogAgent | GUI 理解 | 中 | 中 |

**生成策略**：
```
检索结果（文本+图片）→ 多模态 Prompt → 生成答案 + 引用
```

---

## 4. 数据库 Schema

```sql
-- 文档表
CREATE TABLE mm_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT,
  doc_type VARCHAR(20), -- text/image/table/video/pdf
  source_url TEXT,
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 内容块表
CREATE TABLE mm_chunks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id UUID REFERENCES mm_documents(id),
  chunk_type VARCHAR(20), -- text/image/table/video_frame
  content TEXT,
  caption TEXT, -- 图片/表格的描述
  embedding vector(1024),
  metadata JSONB, -- {page, bbox, timestamp}
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 索引
CREATE INDEX idx_chunks_doc ON mm_chunks(document_id);
CREATE INDEX idx_chunks_type ON mm_chunks(chunk_type);
CREATE INDEX idx_chunks_embedding ON mm_chunks USING ivfflat (embedding vector_cosine_ops);
```

---

## 5. Trade-off 讨论

### Trade-off 1：统一 vs 分离索引
| | 统一索引 | 分离索引 |
|---|---|---|
| 跨模态检索 | ✅ | ❌ |
| 精确度 | 中 | 高 |
| 复杂度 | 低 | 高 |

**选择统一索引**：BGE-m3 已能满足跨模态需求。

### Trade-off 2：Caption 质量
| | 简短 Caption | 详细 Caption |
|---|---|---|
| 检索噪音 | 低 | 高 |
| 信息保留 | 少 | 多 |

**选择分层 Caption**：简短用于检索，详细用于生成。

---

## 6. 高频追问

### Q1: 如何处理图表理解？
1. 图表 → 数据提取（Chart OCR）
2. 数据 → 自然语言描述
3. 描述 + 原图 → 双索引
4. 检索时同时匹配描述和视觉特征

### Q2: 视频如何处理？
1. 关键帧提取（场景检测）
2. 每帧生成 Caption
3. 音频转文字（ASR）
4. 时间戳对齐
5. 检索时返回关键帧 + 时间戳

### Q3: 如何评估多模态 RAG？
1. 检索：Recall@K（分模态）
2. 生成：Faithfulness + Relevancy
3. 跨模态：跨模态检索准确率
4. 用户：满意度 + 任务完成率
