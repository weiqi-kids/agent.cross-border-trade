# 資料源探索紀錄

## 已採用

| 資料源 | 類型 | 對應 Layer | 採用日期 | 備註 |
|--------|------|------------|----------|------|
| UN Comtrade Preview API | JSON API | bilateral_trade_flows | 2026-01-27 | 免 API Key，年度雙邊貿易數據 |
| 中國商務部出口管制資訊網 | HTML | cn_export_control | 2026-01-27 | exportcontrol.mofcom.gov.cn — JS 動態渲染，WebFetch 僅取得框架（~80% 失敗），需 Headless Browser |
| US Census Bureau Trade API | JSON API | us_trade_census | 2026-01-27 | 美國月度進出口明細 |
| World Bank API | JSON API | world_macro_indicators | 2026-01-27 | 宏觀指標（GDP、貿易占比） |
| Open Trade Statistics (tradestatistics.io) | JSON API | open_trade_stats | 2026-01-27 | HS6 級別雙邊貿易，交叉驗證 |

## 評估中

| 資料源 | 類型 | URL | 語言 | 發現日期 | 狀態 | 下次評估 |
|--------|------|-----|------|----------|------|----------|
| — | — | — | — | — | — | — |

## 已排除

| 資料源 | 類型 | 排除原因 | 排除日期 | 重新評估時間 |
|--------|------|----------|----------|--------------|
| — | — | — | — | — |
