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
3. 使用 Qdrant 語意搜尋相關歷史資料
4. 依照輸出框架產出報告到 `docs/Narrator/{mode}/`
5. 報告必須包含 Jekyll front matter（layout、title、parent、nav_order）

### 步驟五：SEO 優化

對 `docs/Narrator/{mode}/` 下新產出的報告執行 SEO 優化：

1. 讀取 `seo/CLAUDE.md`（規則庫）和 `seo/writer/CLAUDE.md`
2. 對每篇新報告執行 SEO Writer 流程：
   - 分析頁面內容
   - 產出 JSON-LD Schema（Article、WebPage、Person、Organization、BreadcrumbList）
   - 產出 SGE 標記建議
   - 產出 Meta 標籤建議
3. 讀取 `seo/review/CLAUDE.md` 執行 Reviewer 檢查
4. 迭代修正直到 Reviewer 回報 "pass"
5. 將 SEO 優化結果寫入報告的 front matter 或獨立 JSON 檔

> 詳細規範見 `seo/CLAUDE.md`

### 步驟六：更新網站

1. 更新 `docs/Narrator/{mode}/index.md` 的歷史報告表格
2. 更新 `docs/index.md` 的最新報告連結
3. 執行 `git add . && git commit && git push`
4. GitHub Actions 自動部署到 Pages

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
| 步驟五 | SEO 優化 | `sonnet` | `general-purpose` |
| 步驟六 | 更新網站 | `sonnet` | `Bash` |

**強制規則**：
- 只有步驟四使用 `opus`，其餘一律 `sonnet`
- 需寫檔的 Task 必須用 `general-purpose`，純腳本執行用 `Bash`

**平行策略與背景執行**：

主執行緒保持可用，使用 `run_in_background: true` 讓 sonnet 子代理背景執行：

| 階段 | 背景執行 | 說明 |
|------|----------|------|
| 步驟一 | ❌ | 快速掃描，前台即可 |
| 步驟二 fetch | ✅ | 5 個 Layer 同時背景執行 |
| 步驟二 analyze | ✅ | Type A 各自背景執行 |
| 步驟二 NLP 萃取 | ✅ | Type B 批次 5-10 個背景執行 |
| 步驟二 update | ❌ | 需等 fetch/analyze 完成，依序前台 |
| 步驟三 | ❌ | 快速掃描，前台即可 |
| 步驟四 Mode 報告 | ❌ | opus 依序前台執行（需深度推理） |
| 步驟五 SEO 優化 | ❌ | sonnet 依序前台執行（需迭代審核） |
| 步驟六 | ✅ | 背景執行，主執行緒立即可用 |

**執行範例**：

```
# 步驟二：5 個 Layer fetch 同時背景執行
Task(prompt="執行 bilateral_trade_flows fetch.sh", run_in_background=true)
Task(prompt="執行 us_trade_census fetch.sh", run_in_background=true)
Task(prompt="執行 world_macro_indicators fetch.sh", run_in_background=true)
Task(prompt="執行 open_trade_stats fetch.sh", run_in_background=true)
Task(prompt="執行 cn_export_control fetch.sh", run_in_background=true)

# 主執行緒用 TaskOutput 監控進度
TaskOutput(task_id="...", block=false)  # 非阻塞檢查
TaskOutput(task_id="...", block=true)   # 等待完成
```

**監控規則**：
- 背景任務啟動後，主執行緒定期用 `TaskOutput(block=false)` 檢查狀態
- 使用者有新指令時優先處理，不被背景任務阻塞
- 所有背景任務完成後才進入下一階段

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

---

## 經驗記錄

### 2026-02-08：效能優化

**問題一：WebFetch 解析特定網站失敗**

- **現象**：cn_export_control Layer 的 MOFCOM 網站，WebFetch 失敗率約 25%
- **原因**：WebFetch 工具對某些政府網站的 HTML 解析不穩定
- **解決方案**：在 Layer CLAUDE.md 中定義 curl 降級策略
  ```bash
  curl -sS "$url" --max-time 30 | sed -n 's/<p[^>]*>\(.*\)<\/p>/\1/gp' | sed 's/<[^>]*>//g'
  ```
- **學習**：Type B Layer 應在 CLAUDE.md 中預先定義降級策略，避免過多 REVIEW_NEEDED

**問題二：update.sh 執行時間過長**

- **現象**：cn_export_control 有 235 個檔案，逐個 embedding + upsert 耗時超過 3 分鐘
- **解決方案**：
  1. 新增 `chatgpt_embed_batch` 函式（lib/chatgpt.sh）
  2. 改用批次處理（預設每批 20 個）
  3. 使用 `qdrant_upsert_points_batch` 批次寫入
- **效能提升**：API 呼叫從 470 次降至約 24 次
- **安全防護**：批次失敗時自動降級為逐個處理
- **學習**：檔案數 > 100 時應考慮批次處理；批次大小 20 是保守但安全的選擇

**問題三：批次處理的資料長度限制**

- **考量**：OpenAI Embedding API 有 token 限制，Qdrant payload 有大小限制
- **防護措施**：
  - 每個文本限 500 字元（`cut -c1-500`）
  - 批次大小可透過 `QDRANT_BATCH_SIZE` 環境變數調整
  - 使用暫存檔傳遞資料，避免命令行長度問題

**問題四：MOFCOM API 回傳中文為問號**

- **現象**：cn_export_control fetch.sh 產出的 JSONL 中，中文標題顯示為 `????`
- **原因**：MOFCOM API 需要 `Accept-Language: zh-CN` 標頭才會回傳中文內容
- **解決方案**：更新 fetch.sh 的 curl 標頭
  ```bash
  -H "Accept-Language: zh-CN,zh;q=0.9,en;q=0.8"
  -H "Accept-Encoding: identity"
  -H "Referer: ${BASE_URL}/"
  ```
- **學習**：中國政府網站 API 可能根據 Accept-Language 標頭決定回傳語言；同時保留 iconv 轉碼函式作為備用
