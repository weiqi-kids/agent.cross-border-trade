# 全球貿易與供需智慧分析系統 — 系統執行指令

本系統由 Claude CLI 全程編排，透過 Task tool 分派子代理完成貿易數據擷取、分析與報告產出。

> 詳細規範請見各子目錄 CLAUDE.md：
> - 角色定義：`core/Architect/CLAUDE.md`
> - Extractor 雙路徑模型：`core/Extractor/CLAUDE.md`
> - Narrator 報告規範：`core/Narrator/CLAUDE.md`
> - 系統維護指令：`core/CLAUDE.md`
> - 各 Layer / Mode 定義：`core/Extractor/Layers/{layer}/CLAUDE.md`、`core/Narrator/Modes/{mode}/CLAUDE.md`

---

## 執行流程

使用者說「執行完整流程」或「更新資料」時，依序執行以下四步：

### 步驟一：動態發現所有 Layer

掃描 `core/Extractor/Layers/*/`，排除含有 `.disabled` 檔案的目錄。

### 步驟二：逐一執行 Layer

對每個 Layer 依序執行三階段：

**1. fetch** — 執行 `core/Extractor/Layers/{layer}/fetch.sh`

**2. 萃取/分析** — 根據 Layer 目錄是否含有 `analyze.sh` 判斷路徑：

```
含 analyze.sh → Type A（數據型）：直接執行 analyze.sh（純 jq 計算）
不含 analyze.sh → Type B（政策型）：Claude 子代理逐行 NLP 萃取
```

Type B 萃取流程：
1. 讀取該 Layer 的 `CLAUDE.md` 和 `core/Extractor/CLAUDE.md`
2. `wc -l` 取得 JSONL 總行數，`sed -n '{N}p'` 逐行讀取（**禁止用 Read 工具讀取 .jsonl**）
3. 每行分派一個 Task 子代理，子代理用 Write tool 寫出 `.md` 檔
4. 分派前做去重：檢查 `docs/Extractor/{layer}/` 下是否已有相同來源的 `.md`

**3. update** — 執行 `core/Extractor/Layers/{layer}/update.sh` 寫入 Qdrant + 檢查 REVIEW_NEEDED

### 步驟三：動態發現所有 Mode

掃描 `core/Narrator/Modes/*/`，排除含有 `.disabled` 檔案的目錄。

### 步驟四：逐一執行 Mode

對每個 Mode 依序執行：
1. 讀取該 Mode 的 `CLAUDE.md` 和 `core/Narrator/CLAUDE.md`
2. 讀取 CLAUDE.md 中宣告的來源 Layer 資料（`docs/Extractor/{layer}/` 下的 `.md` 檔）
3. 依照輸出框架產出報告到 `docs/Narrator/{mode}/`

---

## 模型與子代理指派規則

| 步驟 | 任務類型 | 指定模型 | 子代理類型 |
|------|----------|----------|------------|
| 步驟一 | 動態發現 Layer | `sonnet` | `Bash` |
| 步驟二 | fetch.sh 執行 | `sonnet` | `Bash` |
| 步驟二 | Type A：analyze.sh | `sonnet` | `Bash` |
| 步驟二 | Type B：NLP 萃取 | `sonnet` | `general-purpose` |
| 步驟二 | update.sh 執行 | `sonnet` | `Bash` |
| 步驟三 | 動態發現 Mode | `sonnet` | `Bash` |
| 步驟四 | Mode 報告產出 | `opus` | `general-purpose` |

**強制規則**：
- 只有步驟四使用 `opus`，其餘一律 `sonnet`
- 需寫檔的 Task 必須用 `general-purpose`，純腳本執行用 `Bash`

**平行策略**：
- Type B 萃取可平行分派（如 20 筆一次分派 10 個 Task）
- 多個 Layer 的 fetch.sh 可平行執行
- Mode 報告依序執行（後者可能依賴前者）

---

## 指定執行

使用者可指定執行特定 Layer 或 Mode：

| 使用者指令 | 執行範圍 |
|------------|----------|
| 「執行 {layer_name}」 | 該 Layer 的 fetch → 萃取/分析 → update |
| 「執行 {mode_name}」 | 該 Mode 的報告產出 |
| 「只跑 fetch」 | 所有 Layer 的 fetch.sh，不做萃取/分析 |
| 「只跑萃取」 | 假設 raw/ 已有資料，只做萃取/分析 + update |

指定執行時，模型指派規則仍然生效。

---

## 環境設定

執行前確認 `.env` 包含：

```
# Qdrant Vector Database
QDRANT_URL=...
QDRANT_API_KEY=...
QDRANT_COLLECTION=cross-border-trade

# Embedding
EMBEDDING_MODEL=text-embedding-3-small
EMBEDDING_DIMENSION=1536
OPENAI_API_KEY=sk-...

# Trade Data APIs
COMTRADE_BASE_URL=https://comtradeapi.un.org/public/v1
CENSUS_API_BASE=https://api.census.gov/data/timeseries/intltrade
WORLDBANK_API_BASE=https://api.worldbank.org/v2
OTS_API_BASE=https://api.tradestatistics.io

# Target reporter countries (ISO numeric codes)
TRADE_TARGET_REPORTERS=158,842,156,392,410,276
```

---

## 輸出規則

1. Layer 產出的 `.md` 必須遵循該 Layer `CLAUDE.md` 定義的格式與 category enum
2. Mode 報告必須遵循該 Mode `CLAUDE.md` 定義的輸出框架
3. 所有輸出必須通過各自的「自我審核 Checklist」
4. 未通過審核的輸出在開頭加上 `[REVIEW_NEEDED]`
5. `[REVIEW_NEEDED]` 觸發規則由各 Layer CLAUDE.md 定義，子代理不可自行擴大範圍
6. category enum 值不可自行新增，需與使用者確認後寫入 CLAUDE.md
7. `index.json` 由 GitHub Actions 自動產生，不在此流程中處理

**禁止行為**：
- 不可用 Read 工具讀取 `.jsonl` — 一律 `sed -n '{N}p'` 逐行讀取
- 不可產出無來源的聲明
- 不可混淆推測與事實
- 不可跳過自我審核 Checklist

---

## 互動規則

完成執行後，簡要回報：

1. 各 Layer 擷取與分析結果（筆數、有無 REVIEW_NEEDED）
2. 各 Mode 報告產出狀態
3. 是否有錯誤或需要人工介入的項目
4. 若為完整流程，更新 `README.md` 中的健康度儀表板

本系統專為全球貿易情報分析設計，每次執行不需重新詢問用途。
