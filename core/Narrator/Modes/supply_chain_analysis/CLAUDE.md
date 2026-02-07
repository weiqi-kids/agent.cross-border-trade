# supply_chain_analysis — 供應鏈分析報告 Mode

## Mode 定義表

| 項目 | 內容 |
|------|------|
| **Mode name** | supply_chain_analysis（供應鏈分析報告） |
| **Purpose and audience** | 為供應鏈策略決策者提供月度深度分析，識別集中度風險與多元化機會 |
| **Source layers** | 所有 Layer（bilateral_trade_flows、us_trade_census、world_macro_indicators、open_trade_stats、cn_export_control） |
| **Automation ratio** | 60% — 數據計算自動完成，風險評估與策略建議需人工審核 |
| **Content risk** | 過度推論供應鏈風險、低估數據口徑差異、策略建議可能誤導決策 |
| **Reviewer persona** | 供應鏈專業審核員、貿易數據審核員、法規與責任審核員、使用者誤導風險審核員 |

## 資料來源定義

### 主要來源

1. **bilateral_trade_flows** — 雙邊貿易流量、HHI 集中度、商品結構
2. **us_trade_census** — 美國月度貿易趨勢（即時性較高）
3. **world_macro_indicators** — 宏觀經濟背景（GDP、貿易占比）
4. **open_trade_stats** — HS6 級別細部數據（交叉驗證）
5. **cn_export_control** — 出口管制政策（風險因子）

### 交叉驗證

- Comtrade vs OTS：同口徑數據差異應小於 20%
- Comtrade vs Census：美國相關數據應一致
- 不一致時在報告中標註並說明可能原因

## 輸出框架

```markdown
# 供應鏈分析報告 — {YYYY} 年 {MM} 月

> 報告期間：{YYYY}-{MM}
> 產出時間：{generated_at}
> 自動化程度：60%（數據計算自動完成，風險評估建議人工審核）

## 執行摘要

{5-8 句話概述本月關鍵發現，包含最重要的風險信號和機會}

## 一、關鍵發現

### 1.1 數據摘要
| 指標 | 本月 | 上月 | 變化 |
|------|------|------|------|

### 1.2 重要信號
1. {信號 1 — 附來源標註}
2. {信號 2}
3. {信號 3}

## 二、集中度風險分析

### 2.1 出口市場集中度
{基於 bilateral_trade_flows/market_concentration}

| 國家 | HHI | 等級 | Top 3 份額 | 趨勢 |
|------|-----|------|-----------|------|

### 2.2 進口來源集中度
{類似分析，針對進口方向}

### 2.3 商品集中度
{基於 bilateral_trade_flows/commodity_structure 和 open_trade_stats/hs_section}

| 國家 | 最大出口品項 | 占比 | 風險等級 |
|------|------------|------|---------|

## 三、管制影響評估

### 3.1 本月管制政策更新
{基於 cn_export_control}

### 3.2 影響分析

> **注意**：以下影響評估為推測性分析，建議人工審核。

| 政策 | 受影響產業 | 影響程度 | 信心水準 |
|------|----------|---------|---------|

## 四、多元化機會

### 4.1 替代供應來源
{基於 open_trade_stats/bilateral_flow 的交叉分析}

### 4.2 新興市場趨勢
{基於 world_macro_indicators 的成長率數據}

### 4.3 建議觀察方向
{列出具體可追蹤的指標和閾值}

## 五、方法論與限制

### 使用的數據源
| 來源 | 最新期間 | 延遲 | 備註 |
|------|---------|------|------|

### 計算方法
- **HHI**：Herfindahl-Hirschman Index，市場份額平方和（0-10000）
- **YoY**：Year-over-Year，同比變化率
- **市場份額**：個別夥伴國/商品占總量比例

### 已知限制
1. {限制 1 — 如 Comtrade 數據延遲}
2. {限制 2 — 如 Census 初報值修正}
3. {限制 3 — 如政策影響的不確定性}

### 數據一致性檢查
{Comtrade vs OTS / Census 的差異摘要}

---

## 免責聲明

本報告由自動化系統產出，結合多個公開資料源分析。

**重要聲明**：
- 本報告不構成投資、法律、貿易合規或供應鏈決策建議
- 集中度風險評估基於歷史數據，不代表未來趨勢
- 出口管制政策分析為系統推測，不構成法律意見
- 多元化建議僅為探索性方向，實際決策需考慮更多因素
- 數據可能因來源更新而發生回溯修正
- 建議使用者諮詢相關領域專業人士

## 資料來源

- UN Comtrade Database (https://comtradeplus.un.org/)
- U.S. Census Bureau Foreign Trade (https://www.census.gov/foreign-trade/)
- World Bank Open Data (https://data.worldbank.org/)
- Open Trade Statistics (https://tradestatistics.io/)
- 中國商務部出口管制資訊網 (http://exportcontrol.mofcom.gov.cn/)
```

## 輸出位置

`docs/Narrator/supply_chain_analysis/{YYYY}-{MM}-supply-chain-analysis.md`

## 自我審核 Checklist

發布前必須逐項確認：

- [ ] 所有數據可追溯至具體 Layer 和 .md 檔案
- [ ] 推測性分析與事實性陳述明確區分
- [ ] 風險評估附帶信心水準標註
- [ ] 交叉驗證結果記錄（數據源間差異）
- [ ] 方法論說明完整
- [ ] 已知限制完整列出
- [ ] 免責聲明完整包含
- [ ] 策略建議標註「建議人工審核」
- [ ] 無幻覺內容
- [ ] HHI 值在 0-10000 範圍
- [ ] 計算基於相同時間期間的數據
- [ ] 多元化建議不含無根據的國家/產品推薦
