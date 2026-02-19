# 全球貿易與供需智慧分析系統 — 系統執行指令

本系統由 Claude CLI 全程編排，透過 Task tool 分派子代理完成貿易數據擷取、分析與報告產出。

> 詳細規範請見各子目錄 CLAUDE.md：
> - 角色定義：`core/Architect/CLAUDE.md`
> - Extractor 雙路徑模型：`core/Extractor/CLAUDE.md`
> - Narrator 報告規範：`core/Narrator/CLAUDE.md`
> - 系統維護指令：`core/CLAUDE.md`
> - 各 Layer / Mode 定義：`core/Extractor/Layers/{layer}/CLAUDE.md`、`core/Narrator/Modes/{mode}/CLAUDE.md`
> - **網站改版流程**：`revamp/CLAUDE.md`（含 6 階段 + final-review）

---

## 執行流程

使用者說「執行完整流程」或「更新資料」時，依序執行以下八步：

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

**每個 Mode 報告產出後，必須同步更新以下檔案**：

1. **Mode 導航頁** — 更新 `docs/Narrator/{mode}/index.md` 的歷史報告表格
   - 將新報告加入表格最上方
   - 移除「即將推出」或「尚無歷史報告」的佔位行

2. **首頁最新報告區塊** — 更新 `docs/index.md` 的「最新報告」區塊
   - 更新對應 Mode 的報告表格
   - 將新報告加入最上方
   - 保留最近 2-4 筆報告（依 Mode 頻率決定）
   - 移除「即將推出」的佔位行

3. **首頁本週重點區塊**（僅 trade_briefing）— 更新 `docs/index.md` 的「本週重點」表格
   - 更新重點信號和連結

4. **首頁風險信號區塊**（僅 trade_briefing / supply_chain_analysis）
   - 更新 HHI 指數表格
   - 更新政策動態統計

5. **Git 提交** — 執行 `git add . && git commit && git push`

6. GitHub Actions 自動部署到 Pages

**更新範例**：

```markdown
# 更新 docs/index.md 中的對應區塊

### 出口管制政策追蹤

| 期別 | 重點 | 連結 |
|------|------|:----:|
| 2026-02 | {本期重點摘要} | [查看]({% link Narrator/policy_tracker/2026-02-policy-tracker.md %}) |
| 2026-01 | {上期重點摘要} | [查看]({% link Narrator/policy_tracker/2026-01-policy-tracker.md %}) |
```

### 步驟七：完成品質檢查

執行完整流程後，必須通過以下品質關卡才能視為成功。**全部通過才能回報「完成」。**

詳細檢查項目見下方「完成品質關卡」章節。

### 步驟八：網站優化建議

品質檢查通過後，執行網站健檢並產出優化建議：

**1. 執行技術健檢**

```bash
revamp/tools/site-audit.sh https://your-site.com --output site-audit-$(date +%Y%m%d).json
```

**2. 分析健檢結果**

讀取 `revamp/1-discovery/CLAUDE.md`，對健檢數據進行分析，產出：

| 項目 | 內容 |
|------|------|
| 效能分數變化 | 與上次健檢比較 |
| Core Web Vitals | LCP、CLS、TBT 是否達標 |
| SEO 分數 | 是否有退步 |
| 安全性評級 | SSL、HTTP Headers |

**3. 產出優化建議**

若發現問題，產出優化建議到 `docs/site-audit/` 目錄：

```markdown
# 網站健檢報告 - {日期}

## 健檢摘要
| 指標 | 數值 | 評價 | 變化 |
|------|------|------|------|
| Performance | | ✅/⚠️/❌ | ↑/↓/→ |
| SEO | | | |
| Accessibility | | | |

## 優化建議
| 優先級 | 問題 | 建議行動 |
|--------|------|----------|
| P0 | | |
| P1 | | |

## 下次健檢追蹤
- [ ] {追蹤項目}
```

**4. 觸發深度分析**（可選）

若健檢發現 P0 問題，建議執行完整 revamp 流程：

| 條件 | 建議行動 |
|------|----------|
| Performance < 50 | 執行 `revamp 1-discovery` 深度分析 |
| SEO 退步 > 10% | 執行 `revamp 2-competitive` 競品比較 |
| 多項 P0 問題 | 執行 `revamp 完整流程` |

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
| 步驟七 | 品質檢查 | 主執行緒 | 直接執行 |
| 步驟八 | 網站健檢（site-audit.sh） | `sonnet` | `Bash` |
| 步驟八 | 優化建議產出 | `sonnet` | `general-purpose` |

### 網站改版流程（revamp）

| 階段 | 任務類型 | 指定模型 | 子代理類型 |
|------|----------|----------|------------|
| 0-positioning | Writer | `sonnet` | `general-purpose` |
| 0-positioning | Reviewer | `sonnet` | `general-purpose` |
| 1-discovery | 技術健檢（site-audit.sh） | `sonnet` | `Bash` |
| 1-discovery | Writer | `sonnet` | `general-purpose` |
| 1-discovery | Reviewer | `sonnet` | `general-purpose` |
| 2-competitive | 競品健檢（competitive-audit.sh） | `sonnet` | `Bash` |
| 2-competitive | Writer | `sonnet` | `general-purpose` |
| 2-competitive | Reviewer | `sonnet` | `general-purpose` |
| 3-analysis | Writer | `opus` | `general-purpose` |
| 3-analysis | Reviewer | `sonnet` | `general-purpose` |
| 4-strategy | Writer | `opus` | `general-purpose` |
| 4-strategy | Reviewer | `sonnet` | `general-purpose` |
| 5-content-spec | Writer | `opus` | `general-purpose` |
| 5-content-spec | Reviewer | `sonnet` | `general-purpose` |
| final-review | Reviewer | `opus` | `general-purpose` |

**強制規則**：
- 只有步驟四使用 `opus`，其餘一律 `sonnet`
- **revamp 例外**：3-analysis、4-strategy、5-content-spec、final-review 的 Writer/Reviewer 使用 `opus`（需深度推理）
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
| 步驟七 | ❌ | 必須前台執行，確保全部通過 |
| 步驟八 | ✅ | 健檢背景執行，建議產出前台 |

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
| 「執行網站改版」或「revamp」 | 網站改版流程（見下方章節） |
| 「revamp {階段}」 | 指定階段，如 `revamp 0-positioning` |
| 「網站健檢」或「site audit」 | 執行 1-discovery 階段的技術健檢 |

指定執行時，模型指派規則仍然生效。

---

## 網站改版流程

使用者說「執行網站改版」、「revamp」、「網站健檢」時，執行以下流程。

> **詳細規範**：`revamp/CLAUDE.md`
> **自動化工具**：`revamp/tools/site-audit.sh`、`revamp/tools/competitive-audit.sh`

### 流程總覽

```
0-Positioning → 1-Discovery → 2-Competitive → 3-Analysis → 4-Strategy → 5-Content-Spec → 執行 → Final-Review
     ↓              ↓             ↓              ↓            ↓              ↓                       ↓
  Review ✓      Review ✓      Review ✓      Review ✓     Review ✓       Review ✓                Review ✓
```

### 階段說明

| 階段 | 目的 | 輸出 | 詳細規範 |
|------|------|------|----------|
| **0-positioning** | 釐清品牌定位、核心價值 | 定位文件 | `revamp/0-positioning/CLAUDE.md` |
| **1-discovery** | 盤點現有內容 + 技術健檢 | 健檢報告 + KPI | `revamp/1-discovery/CLAUDE.md` |
| **2-competitive** | 分析競爭對手 | 競品分析報告 | `revamp/2-competitive/CLAUDE.md` |
| **3-analysis** | 受眾分析 + 內容差距 | 差距分析報告 | `revamp/3-analysis/CLAUDE.md` |
| **4-strategy** | 改版計劃 + 優先級排序 | 改版計劃書 | `revamp/4-strategy/CLAUDE.md` |
| **5-content-spec** | 每頁內容規格 | 內容規格書 | `revamp/5-content-spec/CLAUDE.md` |
| **final-review** | 驗收執行結果 | 驗收報告 | `revamp/final-review/CLAUDE.md` |

### 執行方式

每個階段依序執行 **Writer → Reviewer** 雙角色：

1. **Writer**：讀取該階段 `CLAUDE.md`，產出文件
2. **Reviewer**：讀取該階段 `review/CLAUDE.md`，檢查文件品質
3. 若 Reviewer 回報「需修改」，Writer 修正後重新送審
4. 通過後進入下一階段

### 快速指令

| 使用者指令 | 執行範圍 |
|------------|----------|
| 「網站健檢」 | 僅執行 1-discovery 技術健檢（site-audit.sh） |
| 「競品分析」 | 執行 2-competitive，需提供競品 URL |
| 「revamp 0-positioning」 | 執行單一階段 |
| 「revamp 完整流程」 | 執行全部 6 階段 + final-review |

### 自動化工具

```bash
# 網站健檢（本地 Lighthouse，不受 API 配額限制）
revamp/tools/site-audit.sh https://example.com

# 競品比較
revamp/tools/competitive-audit.sh https://our-site.com https://competitor1.com https://competitor2.com
```

### 輸出原則

1. **結構化**：使用 Markdown 表格、清單
2. **可追溯**：標註數據來源（工具、指令、時間）
3. **可執行**：建議事項具體、可操作
4. **有優先級**：重要事項標註 P0/P1/P2

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

## 完成品質關卡

> **強制規則**：執行完整流程後，必須通過以下所有檢查才能回報「完成」。未通過時需立即修正並重新檢查。

### 1. 連結檢查

- [ ] 所有新增/修改的內部連結正常，無 404
- [ ] 所有新增/修改的外部連結正常
- [ ] 無死連結或斷裂連結

### 2. SEO + AEO 標籤檢查

#### 2.1 Meta 標籤

- [ ] `<title>` 存在且 ≤ 60 字，含核心關鍵字
- [ ] `<meta name="description">` 存在且 ≤ 155 字
- [ ] `og:title`, `og:description`, `og:image`, `og:url` 存在
- [ ] `og:type` = "article"
- [ ] `article:published_time`, `article:modified_time` 存在（ISO 8601 格式）
- [ ] `twitter:card` = "summary_large_image"

#### 2.2 JSON-LD Schema（必填 5 種）

| Schema | 必填欄位 |
|--------|----------|
| WebPage | speakable（至少 7 個 cssSelector） |
| Article | isAccessibleForFree, isPartOf（含 SearchAction）, significantLink |
| Person | knowsAbout（≥2）, sameAs（≥1） |
| Organization | logo（含 width/height） |
| BreadcrumbList | position 從 1 開始連續編號 |

#### 2.3 條件式 Schema（依報告內容判斷）

| Schema | 觸發條件 | 必填欄位 |
|--------|----------|----------|
| FAQPage | 有 Q&A 段落 | 3-5 個 Question + Answer |
| ItemList | 有排序清單（「N 大」「TOP」） | itemListElement |
| Table | 有比較表格 | about, description |

#### 2.4 SGE/AEO 標記（AI 引擎優化）

| 標記 | 要求 |
|------|------|
| `.key-answer` | 每個 H2 必須有，含 `data-question` 屬性 |
| `.key-takeaway` | 文章重點摘要（2-3 個） |
| `.data-highlight` | 重要數據標示 |
| `.actionable-steps` | 行動建議清單（若有） |
| `.comparison-table` | 比較表格（若有） |

#### 2.5 數據來源標示

- [ ] 所有數據標明來源（UN Comtrade、US Census、World Bank 等）
- [ ] 數據時間點明確（如「2024 年 1-11 月累計」）
- [ ] 至少 2 個高權威外部連結（數據來源官網）

### 3. 內容更新確認

- [ ] 列出本次預計修改的所有檔案
- [ ] 逐一確認每個檔案都已正確更新
- [ ] 修改內容與任務要求一致
- [ ] 無遺漏項目

### 4. Git 狀態檢查

- [ ] 所有變更已 commit
- [ ] commit message 清楚描述本次變更
- [ ] 已 push 到 Github
- [ ] 遠端分支已更新

### 5. SOP 完成度檢查

- [ ] 回顧原始任務需求
- [ ] 步驟一至七每個步驟都已執行
- [ ] 步驟八網站健檢已執行（完整流程時）
- [ ] 無遺漏的待辦項目
- [ ] 無「之後再處理」的項目

### 檢查報告格式

完成檢查後，必須輸出以下格式：

```
## 完成檢查報告

| 類別 | 狀態 | 問題（如有） |
|------|------|-------------|
| 連結檢查 | ✅/❌ | |
| Meta 標籤 | ✅/❌ | |
| Schema（必填） | ✅/❌ | |
| Schema（條件式） | ✅/❌/N/A | |
| SGE/AEO 標記 | ✅/❌ | |
| 數據來源標示 | ✅/❌ | |
| 內容更新 | ✅/❌ | |
| Git 狀態 | ✅/❌ | |
| SOP 完成度 | ✅/❌ | |

**總結**：X/Y 項通過，狀態：通過/未通過
```

### 檢查未通過時

1. **不回報完成**
2. 列出所有未通過項目
3. 立即修正問題
4. 重新執行檢查
5. 全部通過才能說「完成」

---

## 互動規則

完成執行後，簡要回報：

1. 各 Layer 擷取與分析結果（筆數、有無 REVIEW_NEEDED）
2. 各 Mode 報告產出狀態
3. 是否有錯誤或需要人工介入的項目
4. **完成檢查報告**（步驟七的品質關卡結果）
5. **網站健檢摘要**（步驟八的優化建議）
6. 若為完整流程，更新 `README.md` 中的健康度儀表板

**重要**：只有品質關卡全部通過才能說「完成」。未通過時需說明問題並立即修正。

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
