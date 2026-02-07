# us_trade_census — 美國貿易統計 Layer

## Layer 定義表

| 項目 | 內容 |
|------|------|
| **Layer name** | us_trade_census（美國貿易統計） |
| **Layer type** | Type A（數據型） |
| **Engineering function** | 擷取美國月度進出口數據，提供較即時的貿易動態 |
| **Collectable data** | US Census Bureau International Trade API — 月度進出口（國家、HS 商品） |
| **Automation level** | 95% — 全自動 API 擷取 + jq 計算 |
| **Output value** | 美國月度貿易趨勢、主要夥伴國即時變化、商品結構月度波動 |
| **Risk type** | 資料修正（Census 會事後修正初報值）、API 格式變更 |
| **Reviewer persona** | 貿易數據審核員 |
| **Category enum** | 見下方分類規則 |
| **WebFetch 策略** | 不使用（API 已包含完整結構化資料） |

## 資料源

- **API**: US Census Bureau International Trade API
- **Base URL**: `${CENSUS_API_BASE}` (https://api.census.gov/data/timeseries/intltrade)
- **免費**: 無需 API Key（但有速率限制）
- **端點**: `/exports/hs` (出口) 和 `/imports/hs` (進口)
- **參數**: `time`, `CTY_CODE`, `I_COMMODITY` / `E_COMMODITY`, `GEN_VAL_MO` / `ALL_VAL_MO`

## 分類規則（Category Enum）

| 英文 key | 中文 | 判定條件 |
|----------|------|----------|
| `monthly_export` | 月度出口 | 美國出口數據，按國家/商品彙整 |
| `monthly_import` | 月度進口 | 美國進口數據（General Imports），按國家/商品彙整 |
| `trade_balance` | 貿易差額 | 月度出口 - 進口 |
| `country_detail` | 國別明細 | 特定國家的詳細進出口結構 |

> **嚴格限制**：category 只能使用以上 4 個值，不可自行新增。

## `[REVIEW_NEEDED]` 觸發規則

以下情況**必須**標記 `[REVIEW_NEEDED]`：
1. API 回傳空資料（預期有資料的月份/國家）
2. 月度 MoM 變化超過 ±30%（可能是資料修正或異常事件）
3. API 回傳錯誤但部分資料成功

以下情況**不觸發** `[REVIEW_NEEDED]`：
- Census 資料的固有延遲（通常延遲 2 個月）
- 初報值與修正值差異（這是結構性特徵）

## 輸出格式

```markdown
# United States — {category_description}

- **Source**: US Census Bureau International Trade API
- **Period**: {YYYY-MM}
- **Fetched**: {fetched_at}
- **confidence**: {高/中/低}

## Data

{結構化數據表格}

---

*Source: U.S. Census Bureau, https://www.census.gov/foreign-trade/*
```

## 自我審核 Checklist

- [ ] 金額單位為 USD
- [ ] 月份格式正確（YYYY-MM）
- [ ] 國家代碼使用 Census CTY_CODE
- [ ] 未超出 REVIEW_NEEDED 觸發範圍
