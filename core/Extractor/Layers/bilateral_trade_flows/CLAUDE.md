# bilateral_trade_flows — 雙邊貿易流量 Layer

## Layer 定義表

| 項目 | 內容 |
|------|------|
| **Layer name** | bilateral_trade_flows（雙邊貿易流量） |
| **Layer type** | Type A（數據型） |
| **Engineering function** | 擷取雙邊貿易數據，計算 YoY 變化、市場集中度、商品結構 |
| **Collectable data** | UN Comtrade Preview API — 年度雙邊貿易（進出口金額、數量、夥伴國、HS 商品） |
| **Automation level** | 95% — 全自動 API 擷取 + jq 計算，僅異常值需人工確認 |
| **Output value** | 各國貿易結構、主要夥伴國排名、集中度趨勢、商品依賴度 |
| **Risk type** | 數據延遲（Comtrade 年度資料通常延遲 6-12 個月）、API 改版 |
| **Reviewer persona** | 貿易數據審核員、供應鏈專業審核員 |
| **Category enum** | 見下方分類規則 |
| **WebFetch 策略** | 不使用（API 已包含完整結構化資料） |

## 資料源

- **API**: UN Comtrade Preview API (v1)
- **Base URL**: `${COMTRADE_BASE_URL}` (https://comtradeapi.un.org/public/v1)
- **免費額度**: 無需 API Key（Preview API），但有每分鐘 / 每日呼叫限制
- **主要端點**: `/preview/C/A/{reporterCode}/{period}/{partnerCode}/{flowCode}`
  - `C` = Commodity (HS)
  - `A` = Annual
  - `reporterCode` = ISO 報告國代碼
  - `period` = 年份
  - `partnerCode` = 夥伴國代碼（0 = World）
  - `flowCode` = X (export) / M (import)

## 目標國家

| 代碼 | 國家 | 說明 |
|------|------|------|
| 158 | 台灣 | 主要分析對象 |
| 842 | 美國 | 全球最大經濟體 |
| 156 | 中國 | 全球最大貿易國 |
| 392 | 日本 | 亞太主要經濟體 |
| 410 | 韓國 | 半導體供應鏈關鍵 |
| 276 | 德國 | 歐洲最大經濟體 |

## 分類規則（Category Enum）

| 英文 key | 中文 | 判定條件 |
|----------|------|----------|
| `export_flow` | 出口流量分析 | flowCode == "X"，按夥伴國排名的出口數據 |
| `import_flow` | 進口流量分析 | flowCode == "M"，按夥伴國排名的進口數據 |
| `trade_balance` | 貿易差額 | 出口 - 進口計算，按夥伴國的順差/逆差 |
| `market_concentration` | 市場集中度 | HHI 指數計算、Top N 份額分析 |
| `commodity_structure` | 商品結構 | 按 HS 2位碼的商品類別分布 |

> **嚴格限制**：category 只能使用以上 5 個值，不可自行新增。

## 執行指令

### fetch.sh

1. 對每個目標國家（`$TRADE_TARGET_REPORTERS`），擷取最近 2 年的年度貿易數據
2. 分別擷取出口（X）和進口（M）流向
3. 夥伴國使用 `0`（World，彙總）+ 個別主要夥伴
4. 輸出 JSON 到 `docs/Extractor/bilateral_trade_flows/raw/`

### analyze.sh

1. 讀取 `raw/` 下的 JSON 檔案
2. 使用 `lib/trade_analysis.sh` 的函式：
   - `trade_rank`：Top 20 貿易夥伴排名 → `export_flow/` 和 `import_flow/`
   - `trade_yoy_diff`：YoY 變化率 → 附加於排名結果
   - `trade_balance`：貿易差額計算 → `trade_balance/`
   - `trade_hhi`：市場集中度 → `market_concentration/`
   - `trade_market_share`：商品份額 → `commodity_structure/`
3. 每個分析結果輸出為結構化 Markdown

## `[REVIEW_NEEDED]` 觸發規則

以下情況**必須**標記 `[REVIEW_NEEDED]`：
1. API 回傳資料筆數為 0（某國家某年度無資料）
2. YoY 變化率超過 ±50%（可能是數據異常或重大事件）
3. 同一國家兩年數據差異超過 2 倍（可能是報告口徑變更）
4. API 回傳 HTTP 錯誤但部分資料已成功（不完整資料集）

以下情況**不觸發** `[REVIEW_NEEDED]`：
- Comtrade 數據的固有延遲（這是結構性限制，在 confidence 欄位反映）
- 某些小國缺少雙邊數據（這是資料覆蓋率問題）
- 數值單位差異（Comtrade 統一為 USD）

## 輸出格式

每個 `.md` 檔案格式：

```markdown
# {reporter_name} — {category_description}

- **資料來源**: UN Comtrade Preview API
- **報告國**: {reporter_name} ({reporter_code})
- **資料期間**: {period}
- **擷取時間**: {fetched_at}
- **confidence**: {高/中/低}

## 分析結果

{結構化數據表格}

## 數據摘要

{關鍵發現，純基於計算結果}

---

*Source: UN Comtrade Database, https://comtradeplus.un.org/*
```

## 自我審核 Checklist

輸出前必須逐項確認：

- [ ] 所有數值有明確單位（USD、噸、%）
- [ ] YoY 計算基於相同口徑的兩年資料
- [ ] HHI 計算結果在 0-10000 範圍內
- [ ] 排名數據不含重複項目
- [ ] 貿易差額 = 出口 - 進口，正確標註順差/逆差
- [ ] confidence 欄位正確反映資料品質
- [ ] 未超出 REVIEW_NEEDED 觸發範圍
- [ ] 資料來源明確標註
