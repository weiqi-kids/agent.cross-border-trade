# Extractor 角色定義

## 角色

**Extractor** 負責從外部資料源擷取（fetch）原始資料，並萃取（extract/analyze）為結構化 Markdown。

## 雙路徑萃取模型

### Type A：數據型（analyze.sh）

適用於結構化 API 資料源（JSON REST API）。

**流程**：
```
fetch.sh（下載 API 資料 → raw/*.json/jsonl）
  → analyze.sh（jq 計算 YoY、排名、HHI、份額 → {category}/*.md）
    → update.sh（Qdrant 寫入 + REVIEW_NEEDED 檢查）
```

**判斷條件**：Layer 目錄含有 `analyze.sh` 檔案。

**特性**：
- 純 shell + jq 計算，不需 Claude 子代理
- 產出結果可完全重現（deterministic）
- 適合大量數據的批次處理

### Type B：政策型（Claude NLP 萃取）

適用於非結構化資料源（RSS、HTML 網頁）。

**流程**：
```
fetch.sh（下載 RSS/HTML → raw/*.jsonl）
  → Claude 子代理逐行萃取（讀取 Layer CLAUDE.md → {category}/*.md）
    → update.sh（Qdrant 寫入 + REVIEW_NEEDED 檢查）
```

**判斷條件**：Layer 目錄不含 `analyze.sh` 檔案。

**特性**：
- 需要 Claude 理解非結構化文本
- 遵循 JSONL 處理規範（sed 逐行讀取，不可 Read .jsonl）
- 子代理使用 `sonnet` 模型 + `general-purpose` 類型

## 通用規則

### JSONL 處理規範（Type B 專用）

- **禁止**使用 Read 工具直接讀取 `.jsonl` 檔案
- 用 `wc -l < {jsonl_file}` 取得總行數
- 用 `sed -n '{N}p' {jsonl_file}` 逐行讀取
- 每行獨立交由一個 Task 子代理處理
- 子代理透過 Write tool 寫 `.md` 檔

### WebFetch 補充機制

各 Layer 的 CLAUDE.md 定義 WebFetch 使用策略：

| 策略 | 說明 |
|------|------|
| **必用** | 一律使用 WebFetch 抓取原始頁面 |
| **按需** | 資料不足時才使用 |
| **不使用** | 完全基於已取得的資料 |

WebFetch 失敗**不阻斷**流程，應降級為僅基於已有資料萃取，並在 `notes` 欄位標註。

### `[REVIEW_NEEDED]` 標記

- 表示萃取結果**可能有誤**，需要人工確認
- 各 Layer CLAUDE.md 定義具體觸發規則
- 子代理不可自行擴大判定範圍
- `confidence: 低` 與 `[REVIEW_NEEDED]` **不等價**

### 萃取前去重

在分派萃取 Task 前，頂層編排檢查 `docs/Extractor/{layer_name}/` 下是否已存在相同來源的 `.md` 檔：
- 相同且內容一致 → 跳過
- 相同但內容不同 → 依 Layer 策略覆蓋或保留

### Qdrant Payload 欄位（貿易領域）

| 欄位 | 說明 | 必要 |
|------|------|------|
| `source_url` | 資料來源 URL 或 API endpoint | 是 |
| `source_layer` | Layer 名稱 | 是 |
| `title` | 標題 | 是 |
| `date` | 資料日期 | 是 |
| `category` | 分類（Layer enum 值） | 是 |
| `reporter_code` | 報告國代碼 | 視 Layer |
| `partner_code` | 夥伴國代碼 | 視 Layer |
| `flow_direction` | 貿易方向（export/import） | 視 Layer |
| `commodity_code` | HS 商品代碼 | 視 Layer |
| `period` | 資料期間（年/月） | 視 Layer |
| `fetched_at` | 擷取時間 | 是 |
| `original_content` | 原始內容摘要 | 是 |
