# media_briefing — 財經媒體簡報 Mode

## Mode 定義表

| 項目 | 內容 |
|------|------|
| **Mode name** | media_briefing（財經媒體簡報） |
| **Purpose and audience** | 為財經記者、自媒體、商業媒體編輯提供可引用的貿易數據與簡明新聞角度 |
| **Source layers** | 所有 Layer（bilateral_trade_flows、us_trade_census、world_macro_indicators、cn_export_control） |
| **Automation ratio** | 80% — 數據彙整與摘要自動生成，新聞角度建議人工審核 |
| **Content risk** | 數據引用錯誤、新聞角度誤導、未標註資料來源 |
| **Reviewer persona** | 貿易數據審核員、使用者誤導風險審核員 |

## 資料來源定義

### 主要來源（docs/ 檔案）

1. **bilateral_trade_flows** — 讀取 `docs/Extractor/bilateral_trade_flows/` 下所有 category 的 `.md` 檔
2. **us_trade_census** — 讀取 `docs/Extractor/us_trade_census/` 下所有 category 的 `.md` 檔
3. **world_macro_indicators** — 讀取 `docs/Extractor/world_macro_indicators/` 下的 `.md` 檔
4. **cn_export_control** — 讀取 `docs/Extractor/cn_export_control/` 下所有 category 的 `.md` 檔

### 輔助來源（其他 Mode 報告）

可參考同期其他 Mode 報告，提取重點數據：
- `docs/Narrator/trade_briefing/` — 週報數據
- `docs/Narrator/supply_chain_analysis/` — 月報深度分析
- `docs/Narrator/policy_tracker/` — 政策追蹤

### 歷史參考策略

#### 短期趨勢（前 4 週）

1. 讀取 `docs/Narrator/media_briefing/` 下前 4 週報告
2. 僅提取「本週頭條數據」區塊
3. 避免重複報導相同新聞角度

**整合方式**：
- 標註「本週新增」vs「持續追蹤」
- 若數據連續 3 週出現，考慮調整角度或標註為「長期趨勢」

#### 語意搜尋（Qdrant）

**查詢設計**：基於本期頭條數據生成 2-3 個查詢

| 查詢主題 | 目標 |
|---------|------|
| 歷史對比 | 查找相似數據的歷史報導 |
| 背景脈絡 | 補充新聞背景資訊 |

**搜尋參數**：
- 每個查詢返回 3 筆結果
- 總計不超過 6 筆（去重後）
- 僅包含 score > 0.5 的結果

## 輸出框架

```markdown
---
layout: default
title: "{YYYY} 年第 {WW} 週"
parent: 財經媒體簡報
nav_order: {降序編號，最新為 1}
---

# 財經媒體簡報 — {YYYY} 年第 {WW} 週

> 報告期間：{start_date} — {end_date}
> 產出時間：{generated_at}
> 自動化程度：80%（數據彙整自動生成，新聞角度建議人工審核）

## 本週頭條數據

{: .highlight }
> 以下數據可直接引用，每項皆附來源標註。

### 1. {頭條標題}

**一句話摘要**：
> {可直接引用的一句話，含關鍵數據}

**核心數據**：
- {數據點 1}：{值}（來源：{Layer/category}）
- {數據點 2}：{值}（來源：{Layer/category}）

**可用角度**：
1. {角度 1 — 簡要說明}
2. {角度 2 — 簡要說明}
3. {角度 3 — 簡要說明}

**歷史對比**：
- {Qdrant 搜尋結果或前期數據對比}

---

### 2. {頭條標題}

{類似結構}

---

### 3. {頭條標題}

{類似結構}

## 可引用圖表

### 圖表 1：{標題}

```mermaid
{Mermaid 圖表代碼}
```

> 圖表說明：{一句話說明}
> 數據來源：{來源}

### 表格 1：{標題}

| {欄位 1} | {欄位 2} | {欄位 3} |
|----------|----------|----------|
| {值} | {值} | {值} |

> 數據來源：{來源}

## 本週政策速覽

{基於 cn_export_control，最多 5 條}

| 政策 | 日期 | 一句話摘要 | 新聞價值 |
|------|------|-----------|---------|
| {政策名稱} | {date} | {摘要} | {高/中/低} |

## 下週觀察

{新聞預測，標註為推測性內容}

1. **{觀察項 1}** — {預期時間}、{可能影響}
2. **{觀察項 2}** — {預期時間}、{可能影響}

## 引用指南

### 建議引用格式

```
根據全球貿易情報分析系統數據，{數據內容}。
（資料來源：{原始來源}，經全球貿易情報分析系統整理）
```

### 原始資料來源

| 數據類型 | 原始來源 | 連結 |
|---------|---------|------|
| 雙邊貿易 | UN Comtrade | https://comtradeplus.un.org/ |
| 美國貿易 | US Census Bureau | https://www.census.gov/foreign-trade/ |
| 宏觀指標 | World Bank | https://data.worldbank.org/ |
| 出口管制 | 中國商務部 | http://exportcontrol.mofcom.gov.cn/ |

---

## 免責聲明

本報告由自動化系統產出，數據來自多個公開資料源。

**重要聲明**：
- 本報告供新聞參考使用，引用時請標註資料來源
- 數據可能因來源更新而發生回溯修正
- 新聞角度建議為系統生成，僅供參考
- 政策解讀為系統推測，建議另行查證
- 本系統不對引用本報告造成的任何後果負責

## 資料來源

- UN Comtrade Database (https://comtradeplus.un.org/)
- U.S. Census Bureau Foreign Trade (https://www.census.gov/foreign-trade/)
- World Bank Open Data (https://data.worldbank.org/)
- 中國商務部出口管制資訊網 (http://exportcontrol.mofcom.gov.cn/)
```

## 輸出位置

`docs/Narrator/media_briefing/{YYYY}-W{WW}-media-briefing.md`

## 自我審核 Checklist

發布前必須逐項確認：

- [ ] 所有數據有明確來源標註（Layer、category、原始來源）
- [ ] 「一句話摘要」可獨立引用，無歧義
- [ ] 數據單位明確（USD、%、年份）
- [ ] 可用角度至少提供 2-3 個選項
- [ ] Mermaid 圖表語法正確
- [ ] 表格數據與來源一致
- [ ] 政策速覽不超過 5 條
- [ ] 下週觀察標註為推測性內容
- [ ] 免責聲明完整包含
- [ ] 引用指南格式正確
- [ ] 無幻覺內容（所有聲明可追溯至來源 .md 檔）
- [ ] 頭條數據排序合理（最重要的在前）

## 新聞價值判斷標準

| 等級 | 標準 |
|------|------|
| **高** | 數據變化 > 20%、重大政策生效、首次發生的事件 |
| **中** | 數據變化 10-20%、政策更新、持續追蹤的趨勢 |
| **低** | 數據變化 < 10%、例行更新、背景資訊 |
