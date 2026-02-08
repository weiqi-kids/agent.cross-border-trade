# trade_briefing — 貿易動態簡報 Mode

## Mode 定義表

| 項目 | 內容 |
|------|------|
| **Mode name** | trade_briefing（貿易動態簡報） |
| **Purpose and audience** | 為貿易分析師、供應鏈管理者提供每週貿易動態摘要 |
| **Source layers** | bilateral_trade_flows、us_trade_census、cn_export_control |
| **Automation ratio** | 80% — 數據彙整自動完成，趨勢解讀需人工審核 |
| **Content risk** | 數據解讀偏差、政策影響過度推論 |
| **Reviewer persona** | 貿易數據審核員、政策解讀審核員、使用者誤導風險審核員 |

## 資料來源定義

### 主要來源（docs/ 檔案）

1. **bilateral_trade_flows** — 讀取 `docs/Extractor/bilateral_trade_flows/` 下所有 category 的 `.md` 檔
2. **us_trade_census** — 讀取 `docs/Extractor/us_trade_census/` 下所有 category 的 `.md` 檔
3. **cn_export_control** — 讀取 `docs/Extractor/cn_export_control/` 下所有 category 的 `.md` 檔

### 輔助來源（Qdrant 語意搜尋）

可透過 Qdrant 搜尋相關歷史資料，用於趨勢比較。

### 歷史參考策略

#### 短期趨勢（前 4 週）

1. 讀取 `docs/Narrator/trade_briefing/` 下前 4 週報告
2. 僅提取「摘要」區塊（控制 context 長度）
3. 檔案不存在時跳過，在「已知限制」中說明

**整合方式**：
- 摘要中簡述與前週主要變化
- 表格加入「上週」欄位（若有資料）

#### 去年同期（同週 ±1 週）

1. 查找 `{YYYY-1}-W{WW}` 報告
2. 若不存在，嘗試 `{YYYY-1}-W{WW-1}` 或 `{YYYY-1}-W{WW+1}`
3. 提取「摘要」和關鍵數據表格

**整合方式**：
- YoY 欄位顯示同比變化
- 無去年資料時標註「N/A（無歷史資料）」

#### 語意搜尋（Qdrant）

**查詢設計**：基於本期內容動態生成 3-5 個查詢

| 查詢主題 | 查詢範例 | 目標 Layer |
|---------|---------|-----------|
| 政策追蹤 | 基於 cn_export_control 本期政策關鍵詞 | cn_export_control |
| 貿易趨勢 | "{國家}貿易逆差趨勢" | us_trade_census, bilateral_trade_flows |
| 集中度 | "市場集中度 HHI 指數" | bilateral_trade_flows |

**搜尋參數**：
- 每個查詢返回 5 筆結果
- 總計不超過 10 筆（去重後）
- 僅包含 score > 0.5 的結果

**整合方式**：
- 在「附錄：語意搜尋參考」呈現查詢結果
- 正文引用時標註來源和 Qdrant score

## 輸出框架

```markdown
---
layout: default
title: "{YYYY} 年第 {WW} 週"
parent: 貿易動態週報
nav_order: {降序編號，最新為 1}
---

# 貿易動態簡報 — {YYYY} 年第 {WW} 週

> 報告期間：{start_date} — {end_date}
> 產出時間：{generated_at}
> 自動化程度：80%（數據彙整自動，趨勢解讀建議人工審核）

## 摘要

{3-5 句話概述本週重點，包含最重要的數據變化和政策更新}

## 一、出口重點

### 主要變化
{基於 bilateral_trade_flows/export_flow 和 us_trade_census/monthly_export}

### 數據表格
| 國家 | 出口額 (USD) | YoY 變化 | 備註 |
|------|-------------|----------|------|

## 二、進口重點

### 主要變化
{基於 bilateral_trade_flows/import_flow 和 us_trade_census/monthly_import}

### 數據表格
| 國家 | 進口額 (USD) | YoY 變化 | 備註 |
|------|-------------|----------|------|

## 三、政策更新

{基於 cn_export_control 的最新萃取結果}

### 本週管制政策動態
- {政策 1 摘要}
- {政策 2 摘要}

### 潛在供應鏈影響
{推測性分析，明確標註}

## 四、市場集中度變化

{基於 bilateral_trade_flows/market_concentration}

| 國家 | HHI 指數 | 集中度 | 趨勢 |
|------|---------|--------|------|

## 五、觀察清單

{需要持續關注的項目}

1. {觀察項 1}
2. {觀察項 2}

---

## 免責聲明

本報告由自動化系統產出，數據來自 UN Comtrade、US Census Bureau 及中國商務部公開資訊。
報告內容僅供參考，不構成投資、法律或商業決策建議。
政策解讀為系統推測，可能與實際情況有差異，建議諮詢專業人士。
數據可能因來源更新而發生回溯修正。

## 資料來源

- UN Comtrade Database (https://comtradeplus.un.org/)
- U.S. Census Bureau Foreign Trade (https://www.census.gov/foreign-trade/)
- 中國商務部出口管制資訊網 (http://exportcontrol.mofcom.gov.cn/)
```

## 輸出位置

`docs/Narrator/trade_briefing/{YYYY}-W{WW}-trade-briefing.md`

## 自我審核 Checklist

發布前必須逐項確認：

- [ ] 所有數據有明確來源標註（哪個 Layer、哪個 category）
- [ ] 推測性內容與事實性內容明確區分
- [ ] 政策解讀附帶「建議人工審核」標註
- [ ] 數值單位統一（USD）
- [ ] 免責聲明完整包含
- [ ] 時間範圍明確說明
- [ ] 無幻覺內容（所有聲明可追溯至來源 .md 檔）
- [ ] 觀察清單基於數據支持，非主觀判斷
- [ ] YoY / MoM 計算基於相同口徑
