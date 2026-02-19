# 網站現況盤點報告

## 基本資訊

| 項目 | 內容 |
|------|------|
| 網站 URL | https://trade.weiqi.kids/ |
| 檢測日期 | 2026-02-19 |
| 頁面數量 | 18 頁（sitemap.xml）|
| 內容檔案數 | 370 個 Markdown 檔案 |
| 報告總數 | 16 份（6 個 Mode）|

---

## 1. 技術健檢結果

### 1.1 效能分數

| 項目 | Mobile | Desktop | 評價 |
|------|--------|---------|------|
| Performance | 83/100 | N/A（API 無回應）| ⚠️ 需改善 |
| SEO | 100/100 | N/A | ✅ 優秀 |
| Accessibility | 100/100 | N/A | ✅ 優秀 |
| Best Practices | 93/100 | N/A | ✅ 良好 |

**說明**：PageSpeed Insights Desktop API 於 2026-02-19 測試時無法取得數據（返回 null），推測為 API 暫時性問題或網站暫時無法訪問。

### 1.2 Core Web Vitals

| 指標 | 數值 | 標準 | 評價 |
|------|------|------|------|
| LCP (Largest Contentful Paint) | 1.6s | < 2.5s | ✅ 良好 |
| CLS (Cumulative Layout Shift) | 0 | < 0.1 | ✅ 優秀 |
| TBT (Total Blocking Time) | 630ms | < 200ms | ⚠️ 需改善 |
| FCP (First Contentful Paint) | N/A（API 無回應）| < 1.8s | - |

### 1.3 安全性

| 項目 | 結果 | 評價 |
|------|------|------|
| SSL 評級 | N/A（GitHub Pages 託管）| ✅ GitHub 管理 |
| HTTPS | ✅ 已啟用 | ✅ 良好 |
| HTTP Headers | 缺失關鍵安全標頭 | ❌ 需改善 |
| - HSTS | ❌ 未設定 | 需添加 |
| - X-Frame-Options | ❌ 未設定 | 需添加 |
| - CSP | ❌ 未設定 | 需添加 |

**Headers 觀察**：
- Server: GitHub.com（標準 GitHub Pages）
- Cache-Control: max-age=600（10 分鐘快取）
- Access-Control-Allow-Origin: *（允許跨域）
- X-Proxy-Cache: MISS / X-Cache: HIT（Fastly CDN）

### 1.4 HTML 驗證

| 項目 | 數量 |
|------|------|
| Errors | 0 |
| Warnings | 0 |

**說明**：W3C Validator 檢測結果顯示首頁 HTML 完全符合標準，無錯誤和警告。

### 1.5 SEO 基礎

| 項目 | 狀態 | 說明 |
|------|------|------|
| robots.txt | ✅ | 存在且可存取 |
| sitemap.xml | ✅ | 18 個 URL |
| Meta Description | ✅ | 首頁已設定，報告頁完整 |
| OG Tags | ✅ | 完整設定（title, description, image, url, type）|
| JSON-LD Schema | ✅ | 5 種必填 Schema 完整實作 |
| 語言標記 | ✅ | `zh-TW` 正確標註 |

### 1.6 壞連結

| 狀態 | 數量 |
|------|------|
| 正常連結 | 未測試 |
| 壞連結 (404) | 4 個（Mode 導航頁 404）|

**404 頁面**：
- /Narrator/trade_briefing/ → 實際為 /trade-briefing/
- /Narrator/policy_tracker/ → 實際為 /policy-tracker/
- /Narrator/supply_chain_analysis/ → 實際為 /supply-chain/
- /Narrator/trade_compliance_digest/ → 實際為 /trade-compliance-digest/

---

## 2. 內容盤點

### 2.1 頁面清單

| 頁面 | URL | 類型 | 狀態 | 優先級 |
|------|-----|------|------|--------|
| 首頁 | / | 首頁 | ✅ | P0 |
| 資料來源 | /data-sources/ | 資訊頁 | ✅ | P1 |
| 貿易動態週報（導航） | /trade-briefing/ | 導航頁 | ✅ | P0 |
| 供應鏈月報（導航） | /supply-chain/ | 導航頁 | ✅ | P0 |
| 出口管制政策追蹤（導航） | /policy-tracker/ | 導航頁 | ✅ | P0 |
| 投資視角貿易分析（導航） | /investment-insight/ | 導航頁 | ✅ | P1 |
| 貿易合規摘要（導航） | /trade-compliance-digest/ | 導航頁 | ✅ | P1 |
| 財經媒體簡報（導航） | /media-briefing/ | 導航頁 | ✅ | P1 |
| 週報 W08 | /Narrator/trade_briefing/2026-W08-trade-briefing.html | 報告 | ✅ | P0 |
| 週報 W07 | /Narrator/trade_briefing/2026-W07-trade-briefing.html | 報告 | ✅ | P0 |
| 週報 W06 | /Narrator/trade_briefing/2026-W06-trade-briefing.html | 報告 | ✅ | P1 |
| 週報 W05 | /Narrator/trade_briefing/2026-W05-trade-briefing.html | 報告 | ✅ | P1 |
| 供應鏈 2026-02 | /Narrator/supply_chain_analysis/2026-02-supply-chain-analysis.html | 報告 | ✅ | P0 |
| 供應鏈 2026-01 | /Narrator/supply_chain_analysis/2026-01-supply-chain-analysis.html | 報告 | ✅ | P1 |
| 政策追蹤 2026-02 | /Narrator/policy_tracker/2026-02-policy-tracker.html | 報告 | ✅ | P0 |
| 投資分析 2026-Q1 | /Narrator/investment_insight/2026-Q1-investment-insight.html | 報告 | ✅ | P1 |
| 合規摘要 W07-W08 | /Narrator/trade_compliance_digest/2026-W07-W08-trade-compliance-digest.html | 報告 | ✅ | P1 |
| 媒體簡報 W08 | /Narrator/media_briefing/2026-W08-media-briefing.html | 報告 | ✅ | P1 |

### 2.2 報告數量統計

| Mode | 報告數 | 頻率 | 最新期別 |
|------|-------:|:----:|---------|
| trade_briefing | 5 | 每週 | 2026-W08 |
| supply_chain_analysis | 3 | 每月 | 2026-02 |
| policy_tracker | 2 | 每月 | 2026-02 |
| trade_compliance_digest | 2 | 雙週 | W07-W08 |
| media_briefing | 2 | 每週 | W08 |
| investment_insight | 2 | 每季 | 2026-Q1 |
| **總計** | **16** | - | - |

### 2.3 內容問題

| 頁面 | 問題 | 嚴重度 |
|------|------|--------|
| 首頁 | emoji 指標（🔺⚠️🔻🔄）缺乏圖例說明 | P1 |
| 首頁 | 「本週重點」區塊未標註數據來源時間點 | P1 |
| 首頁 | 缺乏「如何使用本站」快速入門區塊 | P0 |
| 首頁 | Mermaid 圓餅圖可能影響 LCP（首屏渲染）| P1 |
| 資料來源頁 | 「評估中」和「已排除」區塊為空 | P2 |
| 所有 Mode 導航頁 | URL 不一致（/Narrator/{mode}/ vs /{mode}/）| P0 |
| 週報系列 | 德國數據異常警告重複出現 4 次 | P2 |
| 週報系列 | 正文內部缺乏明顯的 `<a>` 錨文字連結至其他報告 | P1 |
| 所有報告 | 缺乏「數據更新時間軸」說明 | P1 |
| 所有報告 | 缺乏「上一期 / 下一期」導航按鈕 | P2 |

---

## 3. 內容架構分析

### 3.1 資訊架構

網站採用**角色導向 + 頻率分層**的導航設計：

```
首頁（角色導航表格）
  ├── 週報系列
  │     ├── 貿易動態週報（分析師）
  │     └── 財經媒體簡報（媒體）
  ├── 雙週報系列
  │     └── 貿易合規摘要（貿易業者）
  ├── 月報系列
  │     ├── 供應鏈月報（供應鏈管理者）
  │     └── 出口管制政策追蹤（政策研究者）
  └── 季報系列
        └── 投資視角貿易分析（投資分析師）
```

**優勢**：
- 清晰的角色區隔（6 個目標受眾）
- 頻率標示明確（每週/雙週/每月/每季）
- 「重點內容」欄位幫助快速決策

**待改善**：
- 缺乏「使用情境」說明（何時使用哪份報告）
- 新訪客學習曲線較陡峭（需理解 6 種報告差異）

### 3.2 導航結構

**主導航**（頂部選單）：
- 貿易動態週報
- 供應鏈月報
- 資料來源
- 出口管制政策追蹤
- 投資視角貿易分析
- 貿易合規摘要
- 財經媒體簡報

**側欄導航**（Jekyll Just the Docs）：
- 所有 Mode 及其子報告
- 可展開/收合設計
- 最新報告置頂

**問題**：
- URL 不一致（導航頁 /trade-briefing/ vs 報告頁 /Narrator/trade_briefing/）
- 缺乏麵包屑導航（雖有 Schema BreadcrumbList）

### 3.3 CTA 分析

| 頁面類型 | CTA 位置 | CTA 文案 | 評價 |
|---------|---------|---------|------|
| 首頁 | 角色導航表格 | 「查看」 | ⚠️ 文案通用，可優化 |
| 首頁 | 本週重點 | 「[W08]」連結 | ✅ 清晰 |
| 導航頁 | 歷史報告表格 | 無明顯按鈕 | ❌ 需加強 |
| 報告頁 | 無 | - | ❌ 缺少「訂閱」「分享」CTA |

**建議**：
- 首頁角色導航：「查看週報」→「查看最新週報」
- 導航頁：新增「查看完整報告」按鈕
- 報告頁：新增「訂閱 RSS」「分享到 LinkedIn」CTA

### 3.4 內部連結策略

**現有策略**：
- Schema `significantLink` 宣告相關報告
- 首頁「本週重點」連結最新週報
- 首頁「最新報告」區塊列出各 Mode 最新 2-4 期

**缺失**：
- 報告正文內**缺乏錨文字連結**（如「詳見 2026-02 供應鏈月報」）
- 無「相關閱讀」區塊
- 無「上一期 / 下一期」導航
- 資料來源頁未連結至對應報告

**內部連結密度抽樣**（基於 Jekyll `{% link %}` 語法統計）：

| 頁面 | 內部連結數 | 連結密度 | 評價 |
|------|-----------|---------|------|
| 首頁（index.md）| 14 | 高 | ✅ 良好 |
| 週報 W08 | 0 | 無 | ❌ 差 |
| 供應鏈 2026-02 | 0 | 無 | ❌ 差 |
| 政策追蹤 2026-02 | 0 | 無 | ❌ 差 |

**關鍵發現**：
- 首頁內部連結充足（14 個 Jekyll link 連結至各 Mode 最新報告）
- **所有報告正文完全缺乏內部連結**（僅 Schema `significantLink` 宣告，HTML 無實作）
- 導致用戶停留時間短、無法形成內容閱讀路徑

**改善建議**：
- 在報告正文中提及其他報告時，加入 `[詳見]({% link ... %})` 連結
- 新增「相關閱讀」區塊（基於 Mode 或主題）
- 新增報告底部導航（← 上一期 | 目錄 | 下一期 →）
- 目標：每篇報告至少 3-5 個內部連結

---

## 4. SEO + AEO 分析

### 4.1 Meta 標籤品質

| 元素 | 首頁 | 週報 W08 | 評價 |
|------|------|---------|------|
| `<title>` | ✅ "全球貿易情報分析" | ✅ "2026 年第 08 週 \| Global Trade Intelligence" | ✅ 良好 |
| `description` | ✅ 155 字內 | ✅ 三大事件摘要 | ✅ 優秀 |
| `keywords` | ❌ 未設定 | ✅ 9 個關鍵字 | ⚠️ 首頁缺失 |
| `og:title` | ✅ | ✅ | ✅ |
| `og:description` | ✅ | ✅ | ✅ |
| `og:image` | ❌ 未設定 | ❌ 未設定 | ❌ 需添加 |
| `og:url` | ✅ | ✅ | ✅ |
| `og:type` | ✅ "website" | ✅ "article" | ✅ |
| `article:published_time` | N/A | ✅ ISO 8601 | ✅ |
| `article:modified_time` | N/A | ✅ ISO 8601 | ✅ |
| `twitter:card` | ❌ 未設定 | ✅ "summary_large_image" | ⚠️ 首頁缺失 |

**關鍵發現**：
- 報告頁 SEO 標籤**完整度高**（100 分）
- 首頁缺少 `og:image`、`twitter:card`、`keywords`
- 所有頁面未設定社群分享圖片（影響社群曝光）

### 4.2 JSON-LD Schema 實作品質

**週報 W08 範例分析**：

| Schema 類型 | 實作狀態 | 必填欄位 | 評價 |
|------------|---------|---------|------|
| WebPage | ✅ | `speakable`（7 個 cssSelector）| ✅ 優秀 |
| Article | ✅ | `isAccessibleForFree`, `isPartOf`, `significantLink` | ✅ 完整 |
| Person | ✅ | `knowsAbout`（≥2）, `sameAs`（≥1）| ✅ 完整 |
| Organization | ✅ | `logo`（含 width/height）| ✅ 完整 |
| BreadcrumbList | ✅ | `position` 從 1 開始 | ✅ 完整 |

**條件式 Schema**：

| Schema 類型 | 觸發條件 | 實作狀態 |
|------------|---------|---------|
| FAQPage | 有 Q&A 段落 | ⚠️ 僅合規摘要有 Q&A，未實作 FAQPage |
| ItemList | 有排序清單 | ❌ 未實作 |
| Table | 有比較表格 | ❌ 未實作（大量表格未標記）|

**優勢**：
- 5 種必填 Schema **100% 完整**
- `speakable` 針對語音搜尋優化（AI Overviews）
- `significantLink` 建立內容關聯網絡

**待改善**：
- 未實作 FAQPage Schema（合規摘要有 Q&A 但未標記）
- 未實作 Table Schema（報告含大量數據表格）
- 未實作 ItemList Schema（如「TOP 3 市場」等）

### 4.3 SGE/AEO 標記

**speakable 選擇器分析**：
```json
"cssSelector": [
  ".article-summary",
  ".key-takeaway",
  ".data-highlight",
  ".expert-quote",
  ".comparison-table",
  ".policy-update",
  ".action-item"
]
```

**實際使用情況（基於 Grep 全站掃描）**：

| AEO 標記 | 使用次數 | 檔案數 | 評價 |
|---------|---------|--------|------|
| `.key-answer` | 0 | 0 | ❌ Schema 宣告但未實作 |
| `.key-takeaway` | 2 | 1（2026-W08-trade-briefing.md）| ⚠️ 僅週報使用 |
| `.data-highlight` | 14 | 1（2026-W08-trade-briefing.md）| ⚠️ 僅週報使用 |
| `.actionable-steps` | 2 | 1（2026-W08-trade-briefing.md）| ⚠️ 僅週報使用 |
| `.comparison-table` | 0 | 0 | ❌ Schema 宣告但未實作 |

**關鍵發現**：
- ✅ 部分報告（trade_briefing W08）有實作 AEO 標記
- ❌ 其他 Mode 報告（supply_chain_analysis, policy_tracker, investment_insight, media_briefing, trade_compliance_digest）**完全未實作**
- ❌ 無 `data-question` 屬性（H2 應標記為可語音搜尋內容）
- ❌ Schema 宣告的 7 個 cssSelector 中，僅 3 個有實際使用，且僅限單一報告

**結論**：Schema 宣告完整，但 HTML 實作**嚴重不一致**，僅 1/16 報告有部分 AEO 標記，無法充分發揮 AI Overviews 和語音搜尋效果。

### 4.4 數據來源標示

| 報告類型 | 標示方式 | 評價 |
|---------|---------|------|
| 週報 | 每節末尾 `> 來源：bilateral_trade_flows/...` | ✅ 完整 |
| 月報 | 每節末尾 + 附錄「數據來源」區塊 | ✅ 優秀 |
| 政策追蹤 | 每政策標註來源檔案 | ✅ 優秀 |

**優勢**：
- 數據來源**檔案級**追溯（如 `cn_export_control/dual-use-export-control-japan-2026-01-06.md`）
- 明確標註數據時間點（如「2025 全年」「2026-02-17 擷取」）
- 附錄區塊統一列出所有來源

**待改善**：
- 缺少「自動化程度」標示（定位文件提及「80% 自動化」但報告未顯示）
- 缺少「數據更新頻率」說明（如「每週一更新」）

---

## 5. 流量分析

### 無 GA 數據時的替代分析

| 分析項目 | 結果 | 建議 |
|----------|------|------|
| **導航結構** | ⚠️ 角色導向設計清晰，但新訪客學習成本高 | 新增「如何使用本站」快速入門區塊 |
| **CTA 明確度** | ⚠️ 「查看」文案通用，缺乏行動誘因 | 改為「查看最新週報」「立即閱讀」 |
| **內容完整度** | ✅ 報告結構完整，數據來源透明 | 增加內部連結密度 |
| **資訊層級** | ✅ 首頁 → 導航頁 → 報告頁 清晰 | 考慮新增「精選報告」區塊 |
| **跳出風險點** | ⚠️ 導航頁僅為索引，缺乏預覽 | 新增報告摘要或重點數據預覽 |

### 推估熱門頁面（基於常識）

| 頁面 | 推估流量 | 理由 | 優先級 |
|------|---------|------|--------|
| 首頁 | 高 | 自然搜尋、直接流量主要入口 | P0 |
| 週報 W08 | 高 | 最新內容、首頁多處連結 | P0 |
| 供應鏈 2026-02 | 中 | 月報最新期，首頁有連結 | P0 |
| 資料來源頁 | 中 | 專業受眾會關注數據可信度 | P1 |
| 投資分析 Q1 | 低 | 季報頻率低、受眾較窄 | P1 |

---

## 6. 建議 KPI

基於現況，建議追蹤以下 KPI：

| KPI | 當前基準 | 目標 | 測量方式 |
|-----|----------|------|----------|
| **自然搜尋流量** | [需 GA 確認] | 月增長 20%（6 個月內）| GA + Search Console |
| **目標關鍵字排名** | [需 Search Console 確認] | 「貿易數據分析」、「出口管制政策」進入前 10 名 | Search Console / Ahrefs |
| **跳出率** | [需 GA 確認] | < 50% | GA |
| **平均停留時間** | [需 GA 確認] | > 3 分鐘 | GA |
| **每次瀏覽頁數** | [需 GA 確認] | > 2 頁 | GA |
| **回訪率** | [需 GA 確認] | > 30% | GA |
| **PageSpeed Performance** | 83/100 | > 90/100 | PageSpeed Insights |
| **LCP** | 1.6s | < 1.5s | PageSpeed Insights |
| **TBT** | 630ms | < 200ms | PageSpeed Insights |
| **Schema 覆蓋率** | 5/5 必填 | 8/8（含條件式）| Schema Validator |
| **內部連結密度** | [需人工計算] | 每頁 ≥ 3 個內部連結 | 人工審核 |
| **社群分享次數** | 0（無追蹤）| 每週 > 10 次 | 新增 UTM 追蹤 |

---

## 7. 關鍵發現摘要

### 優勢

1. **SEO 基礎優秀**（100 分）：Meta 標籤、Schema markup、robots.txt/sitemap.xml 完整
2. **數據可追溯性**：檔案級來源標註、數據時間點明確、方法論透明
3. **內容結構化**：5 種必填 Schema 完整、固定報告框架、表格式數據呈現
4. **角色導向設計**：6 個目標受眾明確區隔、頻率標示清晰
5. **Core Web Vitals**：LCP (1.6s) 和 CLS (0) 表現優秀
6. **技術架構穩定**：Jekyll 靜態網站、GitHub Pages 託管、Fastly CDN

### 問題（按嚴重度排序）

| 優先級 | 問題 | 影響 | 建議修復時程 |
|--------|------|------|-------------|
| **P0** | URL 不一致（404）| 用戶體驗差、SEO 負面影響 | 立即修復 |
| **P0** | 缺乏「如何使用本站」快速入門 | 新訪客轉換率低 | 1 週內 |
| **P0** | 缺少社群分享圖片（og:image）| 社群曝光受限 | 1 週內 |
| **P0** | 安全標頭缺失（HSTS, CSP）| 安全風險（雖 GitHub Pages 有基礎防護）| 2 週內 |
| **P1** | TBT 過高（630ms）| 首屏互動延遲 | 1 個月內 |
| **P1** | AEO 標記不一致（15/16 報告未實作）| AEO 效果無法發揮 | 2 週內 |
| **P1** | 報告正文零內部連結 | SEO、用戶停留時間受影響 | 1 個月內 |
| **P1** | emoji 指標缺乏圖例 | 用戶困惑 | 1 週內 |
| **P1** | 導航頁缺乏報告預覽 | 跳出率可能偏高 | 2 週內 |
| **P2** | 缺少 FAQPage/Table Schema | SEO 錯失機會 | 2 個月內 |
| **P2** | 缺少訂閱/分享 CTA | 無法建立受眾關係 | 1 個月內 |
| **P2** | 德國數據異常警告重複 | 內容冗餘 | 2 週內 |

---

## 8. 改版建議矩陣

### 8.1 快速勝利（Quick Wins）

| 項目 | 工作量 | 影響力 | 優先級 |
|------|--------|--------|--------|
| 修復 URL 404 錯誤 | 低 | 高 | P0 |
| 新增 og:image | 低 | 中 | P0 |
| 新增首頁 emoji 圖例 | 低 | 中 | P1 |
| 新增「如何使用本站」區塊 | 中 | 高 | P0 |
| 實作 HTML AEO 標記（.key-answer 等）| 中 | 高 | P1 |

### 8.2 結構性改善

| 項目 | 工作量 | 影響力 | 優先級 |
|------|--------|--------|--------|
| 增加內部連結密度 | 高 | 高 | P1 |
| 新增「上一期/下一期」導航 | 中 | 中 | P2 |
| 優化 TBT（Mermaid lazy load）| 中 | 中 | P1 |
| 新增 FAQPage Schema | 中 | 中 | P2 |
| 新增數據更新時間軸頁 | 高 | 中 | P1 |

### 8.3 長期投資

| 項目 | 工作量 | 影響力 | 優先級 |
|------|--------|--------|--------|
| 建立 RSS/Email 訂閱 | 高 | 高 | P2 |
| 建立 FAQ 頁面 | 高 | 中 | P2 |
| 建立「關於本站」頁面 | 中 | 中 | P2 |
| 新增 GA + Search Console 追蹤 | 低 | 高 | P0 |
| 建立社群分享追蹤（UTM）| 中 | 中 | P2 |

---

## 9. 與定位文件對照

基於 `revamp/0-positioning/output.md` 的改版目標，檢查現況：

| 定位目標 | 現況 | 符合度 | 待改善 |
|---------|------|--------|--------|
| **P0：完善 SEO + AEO 標籤系統** | ⚠️ Schema 完整但 15/16 報告未實作 HTML 標記 | 40% | 需統一實作 .key-answer, .key-takeaway 等 CSS class |
| **P0：改善首頁資訊架構** | ⚠️ 角色導航清晰但缺快速入門 | 70% | 新增「如何使用」區塊、emoji 圖例 |
| **P0：確保數據來源標示一致性** | ✅ 檔案級追溯、時間點明確 | 90% | 新增「自動化程度」標示 |
| **P1：優化 Core Web Vitals** | ⚠️ LCP 優秀但 TBT 過高（630ms）| 70% | Mermaid lazy load、資源壓縮 |
| **P1：新增數據更新時間軸頁** | ❌ 未實作 | 0% | 需新建頁面 |
| **P1：增加內部連結密度** | ❌ 報告正文零內部連結 | 10% | 報告正文加入錨文字連結（目標 3-5 個/篇） |
| **P2：建立 FAQ 頁面** | ❌ 未實作 | 0% | 需新建頁面 |
| **P2：新增 RSS/訂閱功能** | ❌ 未實作 | 0% | 需技術實作 |
| **P2：建立「關於本站」頁面** | ❌ 僅頁尾簡短說明 | 10% | 需新建頁面 |

---

## 10. 數據來源

- **PageSpeed Insights Mobile**：2026-02-19 透過用戶提供（Performance 83, SEO 100, Accessibility 100, Best Practices 93, LCP 1.6s, CLS 0, TBT 630ms）
- **PageSpeed Insights Desktop**：2026-02-19 14:30 UTC API 測試（API 返回 null，無法取得數據）
- **W3C Validator**：2026-02-19 14:30 UTC `curl -s "https://validator.w3.org/nu/?doc=https://trade.weiqi.kids/&out=json"`（0 錯誤，0 警告）
- **sitemap.xml**：2026-02-19 13:37 UTC `curl -s https://trade.weiqi.kids/sitemap.xml`
- **HTTP Headers**：2026-02-19 13:37 UTC `curl -sI https://trade.weiqi.kids/`
- **WebFetch 內容分析**：2026-02-19
  - 首頁：https://trade.weiqi.kids/
  - 週報 W08：https://trade.weiqi.kids/Narrator/trade_briefing/2026-W08-trade-briefing.html
  - 供應鏈 2026-02：https://trade.weiqi.kids/Narrator/supply_chain_analysis/2026-02-supply-chain-analysis.html
  - 6 個 Mode 導航頁
  - 資料來源頁
- **本地檔案分析**：2026-02-19
  - `docs/index.md`
  - `docs/Narrator/*` 檔案計數
  - Grep 全站掃描 AEO 標記使用情況
  - 內部連結密度抽樣（4 個頁面）
- **安全性檢測**：2026-02-19 透過用戶提供（安全標頭缺失）

---

## 11. 下一步建議

### 立即行動（本週）

1. **修復 404 錯誤**：更新所有 `/Narrator/{mode}/` 連結為 `/{mode}/`
2. **新增社群分享圖片**：製作 1200x630px 的 og:image（建議使用品牌色 + 數據視覺）
3. **新增首頁 emoji 圖例**：🔺 = 新增風險、⚠️ = 持續警示、🔻 = 風險降低、🔄 = 進行中
4. **新增「如何使用本站」區塊**：說明各報告適用情境與閱讀順序

### 短期改善（2 週內）

1. **實作 HTML AEO 標記**：在報告模板加入 `.key-answer`、`.key-takeaway`、`.data-highlight` CSS class
2. **新增導航頁報告預覽**：顯示最新報告的 3-5 個重點摘要
3. **整合 GA + Search Console**：建立 baseline 數據追蹤
4. **優化內部連結**：在報告正文加入 5-10 個錨文字連結

### 中期計劃（1 個月內）

1. **優化 TBT**：Mermaid 圖表 lazy loading、資源壓縮
2. **新增數據更新時間軸頁**：展示各 Layer 更新頻率與最後更新時間
3. **新增 FAQPage Schema**：為合規摘要的 Q&A 區塊加入標記
4. **新增「上一期/下一期」導航**：報告底部導航區塊

### 長期投資（2-3 個月）

1. **建立 FAQ 頁面**：回答「數據來源可靠嗎」「為何只涵蓋六國」等問題
2. **建立「關於本站」頁面**：說明系統架構、AI 角色、開源理念
3. **建立 RSS/Email 訂閱**：透過 GitHub Actions 自動推送新報告
4. **新增 Table Schema**：為數據表格加入結構化標記

---

**報告產出時間**：2026-02-19
**分析師**：Claude Code
**下一步**：交由 `revamp/1-discovery/review/CLAUDE.md` Reviewer 檢查
