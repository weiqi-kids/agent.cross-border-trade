# investment_insight — 投資視角貿易分析 Mode

## Mode 定義表

| 項目 | 內容 |
|------|------|
| **Mode name** | investment_insight（投資視角貿易分析） |
| **Purpose and audience** | 為投資分析師、基金經理提供貿易數據的投資角度解讀，識別產業趨勢與投資機會 |
| **Source layers** | bilateral_trade_flows（主要）、world_macro_indicators（宏觀背景）、cn_export_control（政策風險）、us_trade_census（短期驗證） |
| **Automation ratio** | 40% — 數據計算自動化，投資建議與產業影響評估需人工審核 |
| **Content risk** | 投資建議誤導、產業趨勢過度推論、未充分揭露數據延遲風險 |
| **Reviewer persona** | 投資建議責任審核員、貿易數據審核員、使用者誤導風險審核員 |

## 資料來源定義

### 主要來源（docs/ 檔案）

1. **bilateral_trade_flows** — 讀取 `docs/Extractor/bilateral_trade_flows/` 下所有 category 的 `.md` 檔
   - `export_flow/` — 出口流量趨勢
   - `import_flow/` — 進口流量趨勢
   - `trade_balance/` — 貿易差額
   - `market_concentration/` — 市場集中度（HHI）
   - `commodity_structure/` — 市場份額結構

2. **world_macro_indicators** — 讀取 `docs/Extractor/world_macro_indicators/` 下的 `.md` 檔
   - `gdp_growth/` — GDP 成長率
   - `trade_gdp_ratio/` — 貿易占 GDP 比重
   - `trade_openness/` — 貿易開放度
   - `current_account/` — 經常帳

3. **cn_export_control** — 讀取 `docs/Extractor/cn_export_control/` 下的 `.md` 檔（政策風險因子）

4. **us_trade_census** — 讀取 `docs/Extractor/us_trade_census/` 下的 `.md` 檔（短期趨勢驗證）

### 輔助來源（Qdrant 語意搜尋）

透過 Qdrant 搜尋產業相關歷史資料，建立長期趨勢脈絡。

### 歷史參考策略

#### 短期趨勢（前 2 季）

1. 讀取 `docs/Narrator/investment_insight/` 下前 2 季報告
2. 僅提取「執行摘要」和「一、宏觀貿易格局」區塊
3. 檔案不存在時跳過，在「已知限制」中說明

**整合方式**：
- 數據表格加入「上季」「2 季平均」欄位
- 趨勢標註箭頭（↑↓→）

#### 去年同期（同季）

1. 查找 `{YYYY-1}-Q{Q}-investment-insight.md` 報告
2. 用於同比分析

**整合方式**：
- YoY 欄位顯示同比變化
- 無去年資料時標註「N/A（無歷史資料）」

#### 語意搜尋（Qdrant）

**查詢設計**：基於產業主題生成 5-8 個查詢

| 查詢主題 | 查詢範例 | 目標 |
|---------|---------|------|
| 產業趨勢 | 「半導體貿易流量」「電動車供應鏈」 | 產業面追蹤 |
| 區域機會 | 「{國家}出口成長」「{國家}市場開放」 | 區域投資機會 |
| 政策風險 | 「{管制物項}出口管制」 | 風險因子識別 |
| 宏觀背景 | 「GDP 成長趨勢」「貿易依存度」 | 經濟背景 |

**搜尋參數**：
- 每個查詢返回 5 筆結果
- 總計不超過 15 筆（去重後）
- 包含 score > 0.45 的結果

**整合方式**：
- 在「二、產業趨勢分析」引用相關歷史數據
- 正文引用時標註來源和 Qdrant score

## 輸出框架

```markdown
---
layout: default
title: "{YYYY} 年 Q{Q}"
parent: 投資視角貿易分析
nav_order: {降序編號，最新為 1}
---

# 投資視角貿易分析 — {YYYY} 年 Q{Q}

> 報告期間：{YYYY} Q{Q}
> 產出時間：{generated_at}
> 自動化程度：40%（數據計算自動化，投資觀點建議人工審核）

## 執行摘要

{5-8 句話概述本季貿易格局，從投資角度解讀重點趨勢與機會}

## 一、宏觀貿易格局

### 1.1 六大經濟體貿易總覽

| 經濟體 | 出口總額 (USD) | YoY | 進口總額 (USD) | YoY | 貿易餘額 |
|--------|---------------|-----|---------------|-----|---------|
| 台灣 | {value} | {%} | {value} | {%} | {value} |
| 美國 | {value} | {%} | {value} | {%} | {value} |
| 中國 | {value} | {%} | {value} | {%} | {value} |
| 日本 | {value} | {%} | {value} | {%} | {value} |
| 韓國 | {value} | {%} | {value} | {%} | {value} |
| 德國 | {value} | {%} | {value} | {%} | {value} |

{基於 bilateral_trade_flows 和 us_trade_census 數據}

### 1.2 宏觀經濟背景

| 經濟體 | GDP 成長率 | 貿易/GDP | 經常帳 | 投資意涵 |
|--------|-----------|---------|--------|---------|
| {經濟體} | {%} | {%} | {value} | {簡要解讀} |

{基於 world_macro_indicators 數據}

### 1.3 市場集中度觀察

| 經濟體 | HHI | 等級 | 前三大市場占比 | 趨勢 | 投資意涵 |
|--------|-----|------|---------------|------|---------|
| {經濟體} | {value} | {等級} | {%} | {↑↓→} | {解讀} |

{基於 bilateral_trade_flows/market_concentration}

## 二、產業趨勢分析

### 2.1 成長性產業識別

{基於 bilateral_trade_flows 的 YoY 變化識別高成長領域}

#### 半導體產業

- **貿易數據**：{數據摘要}
- **政策風險**：{cn_export_control 相關政策}
- **投資角度**：{分析 — 明確標註為推測}
- **受益國家/企業類型**：{推測性分析}

#### 新能源材料（鋰電池、稀土）

{類似結構}

#### 電動車供應鏈

{類似結構}

### 2.2 風險產業識別

{基於 cn_export_control 執法頻繁領域}

| 產業 | 風險類型 | 主要政策 | 影響程度 | 建議關注 |
|------|---------|---------|---------|---------|
| {產業} | {類型} | {政策} | {高/中/低} | {觀察指標} |

## 三、區域投資機會

> **重要聲明**：以下投資觀點為系統推測，不構成投資建議。投資決策需考慮更多因素，建議諮詢專業投資顧問。

### 3.1 台灣

#### 貿易亮點
- {數據支持的觀察}

#### 投資主題
- {推測性分析，明確標註}

#### 風險因子
- {政策風險、集中度風險}

### 3.2 美國

{類似結構}

### 3.3 中國

{類似結構}

### 3.4 日本

{類似結構}

### 3.5 韓國

{類似結構}

### 3.6 德國

{類似結構}

## 四、下季觀察清單

### 可追蹤指標

| 指標 | 當前值 | 閾值 | 觸發條件 | 投資意涵 |
|------|--------|------|---------|---------|
| {指標} | {value} | {閾值} | {條件} | {解讀} |

### 待觀察事件

1. {事件 1 — 預期時間、可能影響}
2. {事件 2}
3. {事件 3}

## 五、方法論與限制

### 使用的數據源

| 來源 | 最新期間 | 延遲 | 備註 |
|------|---------|------|------|
| bilateral_trade_flows | {期間} | 6-12 個月 | 年度數據 |
| world_macro_indicators | {期間} | 1-2 年 | 宏觀背景 |
| us_trade_census | {期間} | 2 個月 | 短期驗證 |
| cn_export_control | {期間} | 即時 | 政策風險 |

### 計算方法

- **YoY**：Year-over-Year，同比變化率
- **HHI**：Herfindahl-Hirschman Index，市場份額平方和（0-10000）
- **趨勢判斷**：基於前 2 季數據變化方向

### 已知限制

1. **數據延遲**：bilateral_trade_flows 延遲 6-12 個月，可能未反映最新趨勢
2. **口徑差異**：不同來源數據口徑可能不一致
3. **推測性質**：投資觀點為系統推測，基於有限數據
4. **無商品明細**：Comtrade Preview API 無 HS 商品級別數據
5. {其他限制}

---

## 免責聲明

本報告由自動化系統產出，結合多個公開資料源分析。

**重要聲明**：
- **本報告不構成投資建議**
- 投資觀點為系統推測，基於歷史數據，不代表未來趨勢
- 產業趨勢分析可能因數據延遲而未反映最新情況
- 區域機會評估僅為探索性方向，實際投資需考慮更多因素
- 數據可能因來源更新而發生回溯修正
- 建議使用者諮詢專業投資顧問

## 資料來源

- UN Comtrade Database (https://comtradeplus.un.org/)
- World Bank Open Data (https://data.worldbank.org/)
- U.S. Census Bureau Foreign Trade (https://www.census.gov/foreign-trade/)
- 中國商務部出口管制資訊網 (http://exportcontrol.mofcom.gov.cn/)
```

## 輸出位置

`docs/Narrator/investment_insight/{YYYY}-Q{Q}-investment-insight.md`

## 自我審核 Checklist

發布前必須逐項確認：

- [ ] 所有數據可追溯至具體 Layer 和 .md 檔案
- [ ] 投資觀點與事實陳述明確區分
- [ ] 投資建議標註「不構成投資建議」
- [ ] 數據延遲風險已充分揭露
- [ ] 免責聲明完整包含
- [ ] 時間範圍明確說明
- [ ] 無幻覺內容（所有聲明可追溯至來源 .md 檔）
- [ ] YoY 計算基於相同口徑
- [ ] HHI 值在 0-10000 範圍
- [ ] 區域分析不含無根據的投資推薦
- [ ] 風險因子有政策或數據支持
- [ ] 下季觀察清單為具體可追蹤指標
