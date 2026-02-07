# world_macro_indicators — 全球宏觀指標 Layer

## Layer 定義表

| 項目 | 內容 |
|------|------|
| **Layer name** | world_macro_indicators（全球宏觀指標） |
| **Layer type** | Type A（數據型） |
| **Engineering function** | 擷取宏觀經濟指標，提供貿易分析的總體經濟背景 |
| **Collectable data** | World Bank API — GDP、貿易/GDP 占比、經常帳、貿易開放度 |
| **Automation level** | 95% — 全自動 API 擷取 + jq 計算 |
| **Output value** | 各國經濟結構、貿易依存度、經濟成長趨勢 |
| **Risk type** | 資料延遲（World Bank 年度資料延遲 1-2 年）、指標定義變更 |
| **Reviewer persona** | 貿易數據審核員、邏輯一致性審核員 |
| **Category enum** | 見下方分類規則 |
| **WebFetch 策略** | 不使用（API 已包含完整結構化資料） |

## 資料源

- **API**: World Bank API v2
- **Base URL**: `${WORLDBANK_API_BASE}` (https://api.worldbank.org/v2)
- **免費**: 無需 API Key
- **端點**: `/country/{code}/indicator/{indicator}?format=json`
- **指標代碼**:
  - `NE.TRD.GNFS.ZS` — 貿易占 GDP 比重 (%)
  - `NY.GDP.MKTP.CD` — GDP (current USD)
  - `NY.GDP.MKTP.KD.ZG` — GDP 成長率 (%)
  - `BN.CAB.XOKA.CD` — 經常帳餘額 (current USD)

## 目標國家（World Bank ISO3 代碼）

| ISO3 | 國家 |
|------|------|
| TWN | 台灣 |
| USA | 美國 |
| CHN | 中國 |
| JPN | 日本 |
| KOR | 韓國 |
| DEU | 德國 |

## 分類規則（Category Enum）

| 英文 key | 中文 | 判定條件 |
|----------|------|----------|
| `trade_gdp_ratio` | 貿易占 GDP 比重 | 指標 NE.TRD.GNFS.ZS |
| `trade_openness` | 貿易開放度 | 跨國比較，含時間趨勢 |
| `gdp_growth` | GDP 成長 | 指標 NY.GDP.MKTP.KD.ZG |
| `current_account` | 經常帳 | 指標 BN.CAB.XOKA.CD |

> **嚴格限制**：category 只能使用以上 4 個值，不可自行新增。

## `[REVIEW_NEEDED]` 觸發規則

以下情況**必須**標記 `[REVIEW_NEEDED]`：
1. API 回傳特定國家/年份資料為 null（預期有資料）
2. GDP 成長率超過 ±15%（可能是特殊事件或數據錯誤）
3. 經常帳與前一年符號反轉（順差↔逆差）

以下情況**不觸發** `[REVIEW_NEEDED]`：
- World Bank 資料的固有延遲
- 台灣部分指標缺失（World Bank 對台灣的覆蓋有限）

## 輸出格式

```markdown
# {country_name} — {indicator_description}

- **Source**: World Bank API v2
- **Indicator**: {indicator_code}
- **Period**: {year_range}
- **Fetched**: {fetched_at}
- **confidence**: {高/中/低}

## Data

{結構化數據表格}

---

*Source: World Bank Open Data, https://data.worldbank.org/*
```

## 自我審核 Checklist

- [ ] 指標代碼正確對應
- [ ] 數值單位明確（%、USD、等）
- [ ] 國家代碼使用 ISO3
- [ ] 缺失值標註為 N/A 而非 0
