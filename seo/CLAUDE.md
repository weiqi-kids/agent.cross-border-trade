# SEO + AEO 優化規則庫（貿易分析版）

## 概述

本規則庫定義貿易分析報告網站的 SEO（搜尋引擎優化）和 AEO（AI 答案引擎優化）標準。Writer 和 Reviewer 模組都必須參照此檔案執行任務。

> **適用範圍**：`docs/Narrator/{mode}/` 下的貿易分析報告

---

## 一、JSON-LD Schema 類型定義

### 必填 Schema（5 種 + 1 內嵌）

> **注意**：WebSite Schema 透過 Article.isPartOf 內嵌，包含 SearchAction 網站搜尋功能。

#### 1. WebPage + Speakable

```json
{
  "@type": "WebPage",
  "@id": "{{CANONICAL_URL}}#webpage",
  "url": "{{CANONICAL_URL}}",
  "name": "{{TITLE}}",
  "description": "{{META_DESCRIPTION}}",
  "inLanguage": "zh-TW",
  "isPartOf": { "@id": "https://trade.weiqi.kids/#website" },
  "primaryImageOfPage": { "@type": "ImageObject", "url": "{{OG_IMAGE}}" },
  "datePublished": "{{PUBLISHED_DATE}}",
  "dateModified": "{{MODIFIED_DATE}}",
  "speakable": {
    "@type": "SpeakableSpecification",
    "cssSelector": [
      ".article-summary",
      ".speakable-content",
      ".key-takeaway",
      ".key-answer",
      ".expert-quote",
      ".actionable-steps li",
      ".data-highlight"
    ]
  }
}
```

**必填欄位**：
- `@id`：必須使用 `{{CANONICAL_URL}}#webpage` 格式
- `speakable.cssSelector`：必須包含至少 7 個選擇器

---

#### 2. Article（完整版）

```json
{
  "@type": "Article",
  "@id": "{{CANONICAL_URL}}#article",
  "mainEntityOfPage": {
    "@id": "{{CANONICAL_URL}}#webpage",
    "significantLink": ["{{RELATED_REPORT_1}}", "{{RELATED_REPORT_2}}"]
  },
  "headline": "{{TITLE}}",
  "description": "{{META_DESCRIPTION}}",
  "image": { "@type": "ImageObject", "url": "{{OG_IMAGE}}", "width": 1200, "height": 630 },
  "author": { "@id": "https://trade.weiqi.kids/about#ai-analyst" },
  "publisher": { "@id": "https://trade.weiqi.kids/#organization" },
  "datePublished": "{{PUBLISHED_DATE}}",
  "dateModified": "{{MODIFIED_DATE}}",
  "articleSection": "{{ARTICLE_SECTION}}",
  "keywords": "{{META_KEYWORDS}}",
  "wordCount": "{{WORD_COUNT}}",
  "inLanguage": "zh-TW",
  "isAccessibleForFree": true,
  "isPartOf": {
    "@type": "WebSite",
    "@id": "https://trade.weiqi.kids/#website",
    "name": "全球貿易與供需智慧分析系統",
    "potentialAction": {
      "@type": "SearchAction",
      "target": "https://trade.weiqi.kids/search?q={search_term}",
      "query-input": "required name=search_term"
    }
  }
}
```

**必填欄位**：
- `author`：固定連結到 AI 分析師 Person Schema
- `publisher`：固定連結到 Organization Schema
- `isAccessibleForFree`：必須為 `true`
- `mainEntityOfPage.significantLink`：相關報告連結（至少 2 個）

---

#### 3. Person（AI 分析師 — 固定值）

```json
{
  "@type": "Person",
  "@id": "https://trade.weiqi.kids/about#ai-analyst",
  "name": "AI 貿易分析師",
  "url": "https://trade.weiqi.kids/about",
  "description": "基於 Claude 的智慧貿易分析系統，整合 UN Comtrade、US Census、World Bank 等權威數據源，提供即時貿易情報與趨勢分析。",
  "knowsAbout": [
    "國際貿易數據分析",
    "供應鏈風險評估",
    "關稅政策追蹤",
    "出口管制法規",
    "雙邊貿易流向"
  ],
  "affiliation": { "@id": "https://trade.weiqi.kids/#organization" },
  "sameAs": [
    "https://github.com/anthropics/claude-code"
  ]
}
```

**注意**：此 Schema 為固定值，不需每篇報告重新產生。

---

#### 4. Organization（出版者 — 固定值）

```json
{
  "@type": "Organization",
  "@id": "https://trade.weiqi.kids/#organization",
  "name": "全球貿易與供需智慧分析系統",
  "url": "https://trade.weiqi.kids",
  "logo": {
    "@type": "ImageObject",
    "url": "https://trade.weiqi.kids/assets/images/logo.png",
    "width": 600,
    "height": 60
  },
  "description": "自動化貿易情報分析平台，追蹤全球貿易流向、政策變動與供應鏈風險。",
  "sameAs": [
    "https://github.com/anthropics/claude-code"
  ]
}
```

**注意**：此 Schema 為固定值，不需每篇報告重新產生。

---

#### 5. BreadcrumbList（麵包屑導航）

```json
{
  "@type": "BreadcrumbList",
  "itemListElement": [
    { "@type": "ListItem", "position": 1, "name": "首頁", "item": "https://trade.weiqi.kids/" },
    { "@type": "ListItem", "position": 2, "name": "{{MODE_NAME}}", "item": "https://trade.weiqi.kids/Narrator/{{MODE}}/" },
    { "@type": "ListItem", "position": 3, "name": "{{TITLE}}", "item": "{{CANONICAL_URL}}" }
  ]
}
```

**規則**：
- 至少 3 層（首頁 + Mode + 報告）
- position 必須從 1 開始連續編號

---

### 條件式 Schema（3 種）

> 以下 Schema 依據報告內容動態判斷是否需要加入。

#### 6. FAQPage（若報告含 Q&A 段落）

```json
{
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "{{QUESTION_1}}",
      "acceptedAnswer": { "@type": "Answer", "text": "{{ANSWER_1}}" }
    }
  ]
}
```

**適用條件**：報告中有明確的問答段落
**規則**：若適用，必須包含 3-5 個 Q&A

---

#### 7. ItemList（若有排序清單）

```json
{
  "@type": "ItemList",
  "@id": "{{CANONICAL_URL}}#itemlist",
  "name": "{{LIST_TITLE}}",
  "description": "{{LIST_DESCRIPTION}}",
  "numberOfItems": {{ITEM_COUNT}},
  "itemListElement": [
    {
      "@type": "ListItem",
      "position": 1,
      "name": "{{ITEM_1_NAME}}",
      "description": "{{ITEM_1_DESCRIPTION}}"
    }
  ]
}
```

**適用條件**：報告含排序清單（如「前 10 大出口國」「5 大風險因素」）

---

#### 8. Table（若有比較表格）

```json
{
  "@type": "Table",
  "@id": "{{CANONICAL_URL}}#table",
  "about": "{{TABLE_SUBJECT}}",
  "description": "{{TABLE_DESCRIPTION}}"
}
```

**適用條件**：報告含比較表格（如關稅稅率對照、國家數據比較）

---

### 條件式 Schema 動態判斷規則

| Schema | 關鍵字/特徵偵測 | 優先級 |
|--------|----------------|--------|
| **FAQPage** | 明確的 Q&A 段落、「常見問題」標題 | 低（不強制） |
| **ItemList** | 「前 N 大」「排行」「TOP」+ 編號清單 | 中 |
| **Table** | `<table>` 標籤、數據比較表 | 中 |

---

## 二、SGE/AEO 標記規範

### HTML Class 標記（5 種）

| 標記 | CSS Class | data 屬性 | 用途 | 範例 |
|------|-----------|----------|------|------|
| **關鍵答案** | `.key-answer` | `data-question="搜尋問句"` | 每個 H2 開頭的直接答案 | `<p class="key-answer" data-question="美中貿易現況">2024年美中雙邊貿易額達...</p>` |
| **重點摘要** | `.key-takeaway` | - | 報告核心要點（2-3 個） | `<div class="key-takeaway">重點：...</div>` |
| **數據亮點** | `.data-highlight` | - | 重要數據標示 | `<span class="data-highlight">年增 15.3%</span>` |
| **行動建議** | `.actionable-steps` | - | 可執行的建議清單 | `<ol class="actionable-steps">...</ol>` |
| **比較表格** | `.comparison-table` | - | 結構化比較資訊 | `<table class="comparison-table">...</table>` |

### .key-answer 使用規則

1. **每個 H2 段落開頭**應有一個 `.key-answer`（若該段落可回答特定問題）
2. **必須包含 data-question 屬性**，值為該段落回答的搜尋問句
3. **內容必須是直接答案**，不超過 2 句話

```html
<h2>2024 年台美貿易概況</h2>
<p class="key-answer" data-question="2024年台美貿易額多少">
  2024 年台美雙邊貿易額達 <strong>1,234 億美元</strong>，較去年成長 8.5%。
</p>
```

### Speakable 選擇器（7 個）

```json
"speakable": {
  "cssSelector": [
    ".article-summary",
    ".speakable-content",
    ".key-takeaway",
    ".key-answer",
    ".data-highlight",
    ".actionable-steps li",
    ".expert-quote"
  ]
}
```

---

## 三、貿易分析報告專用欄位

### articleSection 對應表

| Mode | articleSection 值 |
|------|------------------|
| weekly_trade_pulse | 週報分析 |
| monthly_deep_dive | 月度深度分析 |
| policy_alert | 政策快報 |
| supply_chain_risk | 供應鏈風險評估 |

### keywords 建議格式

```
國際貿易, {{主要國家}}, {{商品類別}}, {{年份}}, 貿易數據, {{特定議題}}
```

範例：
```
國際貿易, 美國, 中國, 半導體, 2024, 貿易數據, 出口管制
```

---

## 四、SEO 檢查清單

### 關鍵字優化

- [ ] 標題（H1/title）包含核心關鍵字（國家、商品、時間）
- [ ] 第一段（前 100 字）包含關鍵字
- [ ] H2 標題自然融入關鍵字
- [ ] 包含 3-5 個 LSI 語意相關詞

### 結構優化

- [ ] H1 唯一且包含關鍵字
- [ ] H2 數量 3-6 個
- [ ] 段落長度 100-300 字

### 連結優化

- [ ] 內部連結 3+ 個（連到相關報告）
- [ ] 外部權威連結 2+ 個（數據來源）
- [ ] 無斷裂連結

### 數據來源標示

- [ ] 所有數據標明來源（UN Comtrade、US Census 等）
- [ ] 數據時間點明確（如「2024 年 1-11 月累計」）

---

## 五、Meta 標籤規範

### 基本標籤

```html
<title>{{TITLE}}（60字內，含關鍵字）</title>
<meta name="description" content="{{DESCRIPTION}}（155字內，含關鍵字）" />
<link rel="canonical" href="{{CANONICAL_URL}}" />
```

### Open Graph 標籤

```html
<meta property="og:title" content="{{TITLE}}" />
<meta property="og:description" content="{{DESCRIPTION}}" />
<meta property="og:image" content="{{OG_IMAGE}}" />
<meta property="og:url" content="{{CANONICAL_URL}}" />
<meta property="og:type" content="article" />
<meta property="og:site_name" content="全球貿易與供需智慧分析系統" />
<meta property="article:published_time" content="{{PUBLISHED_DATE}}" />
<meta property="article:modified_time" content="{{MODIFIED_DATE}}" />
<meta property="article:author" content="AI 貿易分析師" />
```

### Twitter Card 標籤

```html
<meta name="twitter:card" content="summary_large_image" />
<meta name="twitter:title" content="{{TITLE}}" />
<meta name="twitter:description" content="{{DESCRIPTION}}" />
<meta name="twitter:image" content="{{OG_IMAGE}}" />
```

---

## 六、JSON-LD 整合格式

所有 Schema 必須使用 `@graph` 整合：

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@graph": [
    { "@type": "WebPage", ... },
    { "@type": "Article", ... },
    { "@type": "Person", ... },
    { "@type": "Organization", ... },
    { "@type": "BreadcrumbList", ... }
  ]
}
</script>
```

### @id 互相連結規則

| Schema | @id 格式 | 被引用於 |
|--------|----------|---------|
| WebPage | `{{URL}}#webpage` | Article.mainEntityOfPage |
| Article | `{{URL}}#article` | - |
| Person | `https://trade.weiqi.kids/about#ai-analyst` | Article.author（固定值） |
| Organization | `https://trade.weiqi.kids/#organization` | Article.publisher（固定值） |
| ItemList | `{{URL}}#itemlist` | - |
| Table | `{{URL}}#table` | - |

---

## 七、驗證方式

### Google Rich Results Test

將完成的 JSON-LD 貼入以下工具驗證：
https://search.google.com/test/rich-results

### 預期通過項目

- [ ] Article
- [ ] BreadcrumbList
- [ ] ItemList（若適用）

---

## 八、常見錯誤清單

| 錯誤 | 說明 | 修正方式 |
|------|------|---------|
| 缺少 speakable | WebPage 沒有 speakable 欄位 | 加入 7 個 cssSelector |
| @id 格式錯誤 | 沒有使用 `#` 分隔符 | 使用 `{{URL}}#type` 格式 |
| 日期格式錯誤 | 沒有使用 ISO 8601 | 使用 YYYY-MM-DD 格式 |
| 缺少數據來源 | 報告數據沒有標明來源 | 加入來源標示 |
| description 過長 | 超過 155 字 | 精簡到 155 字內 |

---

## 附錄：快速參考卡

### 必填 Schema 清單（5 種）
1. WebPage（含 Speakable）
2. Article（含 SearchAction）
3. Person（AI 分析師 — 固定值）
4. Organization（固定值）
5. BreadcrumbList

### 條件式 Schema 清單（3 種）
1. FAQPage（若有 Q&A）
2. ItemList（若有排序清單）
3. Table（若有比較表格）

### SGE 標記清單
1. `.key-answer`（含 data-question）
2. `.key-takeaway`
3. `.data-highlight`
4. `.actionable-steps`
5. `.comparison-table`
