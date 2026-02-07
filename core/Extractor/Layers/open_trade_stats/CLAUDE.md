# open_trade_stats — 開放貿易統計 Layer

## Layer 定義表

| 項目 | 內容 |
|------|------|
| **Layer name** | open_trade_stats（開放貿易統計） |
| **Layer type** | Type A（數據型） |
| **Engineering function** | 擷取 HS6 級別雙邊貿易數據，用於交叉驗證與細部分析 |
| **Collectable data** | Open Trade Statistics API — HS6 雙邊貿易流量 |
| **Automation level** | 95% — 全自動 API 擷取 + jq 計算 |
| **Output value** | 細粒度商品貿易、交叉驗證 Comtrade 數據、產品級別供應鏈分析 |
| **Risk type** | API 服務穩定性、資料與 Comtrade 的口徑差異 |
| **Reviewer persona** | 貿易數據審核員、供應鏈專業審核員 |
| **Category enum** | 見下方分類規則 |
| **WebFetch 策略** | 不使用（API 已包含完整結構化資料） |

## 資料源

- **API**: Open Trade Statistics (tradestatistics.io)
- **Base URL**: `${OTS_API_BASE}` (https://api.tradestatistics.io)
- **免費**: 無需 API Key
- **端點**:
  - `/yrpc` — 年度-報告國-夥伴國-商品 (Year-Reporter-Partner-Commodity)
  - `/yrp` — 年度-報告國-夥伴國 (Year-Reporter-Partner)
  - `/yrc` — 年度-報告國-商品 (Year-Reporter-Commodity)
  - `/yr` — 年度-報告國 (Year-Reporter)

## 目標國家（ISO3 代碼）

| ISO3 | 國家 |
|------|------|
| twn | 台灣 |
| usa | 美國 |
| chn | 中國 |
| jpn | 日本 |
| kor | 韓國 |
| deu | 德國 |

## 分類規則（Category Enum）

| 英文 key | 中文 | 判定條件 |
|----------|------|----------|
| `bilateral_flow` | 雙邊流量 | 兩國之間的貿易總額（yrp 端點） |
| `product_detail` | 產品明細 | HS6 級別的產品貿易數據（yrpc 端點） |
| `country_profile` | 國家概況 | 單一國家的貿易總覽（yr 端點） |
| `hs_section` | HS 大類分析 | 按 HS Section 彙整（yrc 端點） |

> **嚴格限制**：category 只能使用以上 4 個值，不可自行新增。

## `[REVIEW_NEEDED]` 觸發規則

以下情況**必須**標記 `[REVIEW_NEEDED]`：
1. API 回傳空資料（預期有資料的國家/年份）
2. 與 Comtrade 同口徑數據差異超過 20%（需交叉驗證）
3. API 連線失敗但快取資料過時超過 30 天

以下情況**不觸發** `[REVIEW_NEEDED]`：
- OTS 與 Comtrade 的系統性差異（統計方法不同）
- 某些小國資料不完整（覆蓋率限制）

## 輸出格式

```markdown
# {reporter_name} — {category_description}

- **Source**: Open Trade Statistics (tradestatistics.io)
- **Reporter**: {reporter_iso3}
- **Period**: {year}
- **Fetched**: {fetched_at}
- **confidence**: {高/中/低}

## Data

{結構化數據表格}

---

*Source: Open Trade Statistics, https://tradestatistics.io/*
```

## 自我審核 Checklist

- [ ] 國家代碼使用 ISO3（小寫）
- [ ] 商品代碼為 HS6 格式
- [ ] 金額單位明確（USD）
- [ ] 交叉驗證備註（與 Comtrade 差異）
