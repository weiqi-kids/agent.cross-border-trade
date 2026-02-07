# 貿易動態簡報 — 2026 年第 06 週

> 報告期間：2026-02-03 — 2026-02-09
> 產出時間：2026-02-07T15:00:00Z
> 自動化程度：80%（數據彙整自動，趨勢解讀建議人工審核）
> **本週特色：整合 Qdrant 語意搜尋歷史資料**

## 摘要

本週貿易動態聚焦於中國出口管制政策的持續演進及其對全球供應鏈的深遠影響。透過 Qdrant 語意搜尋整合歷史資料後發現，中國自 2025 年 10 月起密集發布的稀土、鋰電池及中重稀土出口管制措施（公告 2025-56、57、58、61、62 號）形成完整的戰略性資源管制體系。美國對中貿易逆差呈現收窄趨勢（2024 年 2,955 億美元 → 2025 年前 11 月 1,894 億美元），主要反映對中進口下降而非出口增長。台灣出口市場集中度（HHI 1,183.15）為五大經濟體最高，需持續關注對中美市場依賴風險。

---

## 一、出口重點

### 主要變化

1. **台灣出口結構穩定**：台灣出口前三大市場為中國（1,926 億美元，21.24%）、美國（1,878 億美元，20.71%）及香港（1,100 億美元，12.13%），合計佔出口總額 54.08%。2023-2024 年累計出口總值約 9,069 億美元。
   - 來源：`bilateral_trade_flows/export_flow/158-export-2024.md`

2. **中國出口高度分散**：中國出口前三大市場為美國（14.7%）、香港（8.13%）及越南（4.53%），Top 3 佔比僅 27.34%，為主要經濟體中最低。此分散策略有效降低單一市場依賴風險。
   - 來源：`bilateral_trade_flows/export_flow/156-export-2024.md`

3. **美國出口結構**：美國出口前三大市場為加拿大（17.2%）、墨西哥（16.1%）及中國（7.1%），北美區域整合趨勢明顯。
   - 來源：`bilateral_trade_flows/export_flow/842-export-2024.md`

### 數據表格

| 經濟體 | 第一大出口市場 | 第二大出口市場 | 第三大出口市場 | Top 3 佔比 |
|--------|---------------|---------------|---------------|-----------|
| 台灣 (158) | 中國 (21.24%) | 美國 (20.71%) | 香港 (12.13%) | 54.08% |
| 中國 (156) | 美國 (14.7%) | 香港 (8.13%) | 越南 (4.53%) | 27.34% |
| 美國 (842) | 加拿大 (17.2%) | 墨西哥 (16.1%) | 中國 (7.1%) | 40.41% |
| 日本 (392) | 美國 (20.1%) | 中國 (17.6%) | 南韓 (6.5%) | 44.26% |
| 南韓 (410) | 中國 (19.6%) | 美國 (18.6%) | 越南 (8.5%) | 46.70% |

*來源：UN Comtrade Database, https://comtradeplus.un.org/*

---

## 二、進口重點

### 主要變化

1. **美國對中貿易逆差收窄**：2025 年美國對中貿易逆差為 1,894 億美元（前 11 月累計），較 2024 年全年 2,955 億美元顯著下降。此變化主要來自對中進口減少（2024 年 4,387 億 → 2025 年 2,873 億），而非對中出口增長（2024 年 1,432 億 → 2025 年 979 億）。
   - 來源：`us_trade_census/country_detail/us-detail-5700-2026.md`
   - Qdrant 語意搜尋佐證：查詢「美國貿易逆差歷史數據」找到 2022-2025 年趨勢資料（score: 0.535）

2. **美國對台貿易逆差擴大**：2025 年美國對台貿易逆差達 1,269 億美元（前 11 月累計），較 2024 年全年 737 億美元大幅增長 72%，主要因台灣半導體出口激增。
   - 來源：`us_trade_census/trade_balance/us-balance-5830-2026.md`

3. **台灣進口結構**：台灣進口前三大來源為中國（1,496 億美元）、日本（907 億美元）及美國（876 億美元），對日本進口主要為半導體設備及材料。
   - 來源：`bilateral_trade_flows/import_flow/158-import-2024.md`

### 數據表格

| 美國雙邊貿易（2025 年累計） | 出口 (億 USD) | 進口 (億 USD) | 貿易差額 (億 USD) | YoY 變化 |
|----------------------------|--------------|--------------|------------------|----------|
| 對中國 | 979.2 | 2,872.8 | -1,893.6（逆差） | 收窄 36% |
| 對台灣 | 498.7 | 1,767.3 | -1,268.6（逆差） | 擴大 72% |

*來源：US Census Bureau, https://www.census.gov/foreign-trade/*

---

## 三、政策更新

### 本週管制政策動態

**[建議人工審核]** 以下政策解讀為系統根據公開資訊及 Qdrant 歷史資料推測，可能與實際情況有差異。

#### 稀土出口管制體系（整合 Qdrant 搜尋結果）

透過 Qdrant 語意搜尋「稀土出口管制政策」，系統找到 5 筆高度相關歷史資料（score 0.59-0.68），揭示中國稀土管制政策演進脈絡：

| 公告編號 | 生效日期 | 管制範圍 | 關鍵影響 |
|---------|---------|---------|---------|
| 2025-56 | 2025-11-08 | 稀土設備及原輔料 | 離心萃取設備、智能除雜沉淀設備 |
| 2025-57 | 2025-11-08 | 中重稀土（Ho/Er/Tm/Eu/Yb） | 靶材、晶體材料、光纖材料、永磁體 |
| 2025-61 | 2025-10-09 | 含中國成分境外稀土物項 | 境外管轄延伸，0.1% 價值門檻 |
| 2025-62 | 2025-10-09 | 稀土相關技術 | 開採、冶煉分離、金屬冶煉、磁材製造技術 |

- 來源：`cn_export_control/mofcom-rare-earth-export-control-strengthening-oct2025.md`
- 來源：`cn_export_control/heavy-rare-earth-export-controls.md`
- Qdrant 歷史資料：公告 2025-56、57、61、62 號（score: 0.59-0.68）

#### 鋰電池與石墨負極材料管制

1. **公告 2025-58 號**（生效日期：2025-11-08）
   - 高能量密度鋰電池（≥300 Wh/kg）及製造設備
   - 磷酸鐵鋰正極材料（≥2.5 g/cm³）及前驅體
   - 人造石墨負極材料及生產設備
   - 來源：`cn_export_control/lithium-battery-graphite-anode-export-controls.md`

#### 兩用物項出口管制條例

透過 Qdrant 語意搜尋「中國兩用物項管制政策」，系統找到核心法規資料（score: 0.62）：

- **國務院令第 792 號**（生效日期：2024-12-01）
- 整合原有核、導彈、生物、化學兩用物項管制框架為統一許可制度
- 建立三級許可機制：單項許可證（1 年）、通用許可證（3 年）、登記證書
- 來源：`cn_export_control/dual-use-items-export-control-regulations-2024.md`
- Qdrant 歷史資料：兩用物項出口管制條例（score: 0.62）

#### 不可靠實體清單更新

- 新增實體：Counter-Unmanned Aircraft Systems Technology Company、TechInsights 及其附屬機構
- 理由：與台灣軍事合作、發表對中國敵意言論、協助打壓中國企業
- 來源：`cn_export_control/mofcom-unreliable-entity-list-additions-oct2025.md`

### 潛在供應鏈影響

**[建議人工審核]** 以下影響評估為系統推測。

| 管制類別 | 受影響產業 | 影響程度 | 風險等級 |
|---------|----------|---------|---------|
| 稀土材料及技術 | 永磁體、電動車、風電、半導體 | 極高 | 紅色 |
| 中重稀土元素 | 光纖通訊、雷射技術、顯示器 | 高 | 橙色 |
| 鋰電池材料 | 電動車、儲能系統、航空 | 高 | 橙色 |
| 兩用物項 | 半導體、航太、先進材料 | 中高 | 橙色 |

**關鍵風險點**：
- 中國佔全球稀土開採約 70%、加工約 90%，技術出口管制將限制其他國家建立替代產能
- 0.1% 價值門檻創造境外管轄延伸，幾乎涵蓋所有含中國稀土微量成分的製成品
- 中重稀土管制直接影響半導體靶材及光纖通訊材料供應

---

## 四、市場集中度變化

透過 Qdrant 語意搜尋「台灣出口市場集中度 HHI」，系統找到五大經濟體 HHI 趨勢資料（score: 0.54-0.71），確認各經濟體出口市場集中度均維持低位：

| 經濟體 | HHI 指數 | 集中度等級 | Top 3 市場佔比 | 貿易夥伴數 | Qdrant Score |
|--------|---------|-----------|---------------|-----------|--------------|
| 中國 | 447.18 | 低 | 27.34% | 220 | 0.57 |
| 美國 | 723.51 | 低 | 40.41% | 223 | 0.57 |
| 日本 | 894.65 | 低 | 44.26% | 218 | 0.54 |
| 南韓 | 911.24 | 低 | 46.70% | 225 | 0.55 |
| 台灣 | 1,183.15 | 低 | 54.08% | 221 | 0.71 |

**HHI 參考標準**：
- < 1,500：低集中度（市場分散）
- 1,500-2,500：中等集中度
- > 2,500：高集中度（市場依賴）

*來源：UN Comtrade Database, https://comtradeplus.un.org/*
*Qdrant 語意搜尋：查詢「台灣出口市場集中度 HHI」（搜尋時間：2026-02-07）*

**觀察**：
- 台灣 HHI 指數（1,183.15）為五大經濟體最高，接近中等集中度門檻
- 台灣對中國及美國市場合計依賴度達 41.95%，地緣政治風險需密切監控
- 中國 HHI 指數（447.18）為最低，出口市場高度分散

---

## 五、觀察清單

| 項目 | 風險類型 | 監測指標 | 建議追蹤頻率 |
|------|---------|---------|-------------|
| 稀土境外管制實施情況 | 供應鏈中斷 | 出口許可核發數量、境外企業申請案件 | 週 |
| 美中貿易逆差走勢 | 政策風險 | 月度貿易數據、關稅調整動態 | 月 |
| 台灣半導體出口 | 市場依賴 | 對美 HS84 出口變化、客戶集中度 | 週 |
| 鋰電池供應鏈調整 | 供應鏈重組 | 韓日電池廠產能擴張、替代材料開發 | 月 |
| 中重稀土替代方案 | 技術突破 | 美澳加稀土產能、回收技術進展 | 季 |
| 兩用物項許可審批 | 合規風險 | MOFCOM 許可處理時間、拒絕率 | 月 |

**近期關注事件**：
1. 稀土及鋰電池出口管制已於 2025-11-08 正式生效，關注許可申請實務
2. 美國對台貿易逆差擴大趨勢，可能引發貿易政策調整
3. TechInsights 等實體被列入不可靠實體清單，半導體逆向工程服務受限

---

## 附錄：Qdrant 語意搜尋參考

本週報告整合 Qdrant 向量資料庫語意搜尋結果，提供歷史資料脈絡與趨勢比較。

### 查詢 1: "稀土出口管制政策"

| 相關資料 | Score | 日期 | 來源 |
|----------|-------|------|------|
| 商务部公告2025第62号 - 稀土相关技术出口管制 | 0.678 | 2025-10-09 | cn_export_control |
| 商务部 海关总署公告2025年第56号 - 稀土设备和原辅料出口管制 | 0.669 | 2025-10-09 | cn_export_control |
| 商务部新闻发言人就加强稀土相关物项出口管制应询答记者问 | 0.655 | 2025-10-09 | cn_export_control |
| 公告2025年第57号 - 中重稀土出口管制 | 0.595 | 2025-10-13 | cn_export_control |
| 稀土相关技术出口管制公告 | 0.594 | 2025-10-09 | cn_export_control |

### 查詢 2: "美國貿易逆差歷史數據"

| 相關資料 | Score | 日期 | 來源 |
|----------|-------|------|------|
| United States - Trade Balance with Taiwan | 0.535 | 2026-02-07 | us_trade_census |
| United States - Trade Balance with China | 0.516 | 2026-02-07 | us_trade_census |
| United States - Trade Detail with Taiwan | 0.515 | 2026-02-07 | us_trade_census |
| United States - Trade Detail with China | 0.510 | 2026-02-07 | us_trade_census |
| United States - Trade Balance (UN Comtrade) | 0.490 | 2026-02-06 | bilateral_trade_flows |

### 查詢 3: "台灣出口市場集中度 HHI"

| 相關資料 | Score | 日期 | 來源 |
|----------|-------|------|------|
| Taiwan - Market Concentration (Export) | 0.706 | 2026-02-06 | bilateral_trade_flows |
| China - Market Concentration (Export) | 0.574 | 2026-02-06 | bilateral_trade_flows |
| United States - Market Concentration (Export) | 0.568 | 2026-02-06 | bilateral_trade_flows |
| South Korea - Market Concentration (Export) | 0.548 | 2026-02-06 | bilateral_trade_flows |
| Japan - Market Concentration (Export) | 0.536 | 2026-02-06 | bilateral_trade_flows |

### 查詢 4: "中國兩用物項管制政策"

| 相關資料 | Score | 日期 | 來源 |
|----------|-------|------|------|
| 中华人民共和国两用物项出口管制条例 | 0.620 | 2024-10-23 | cn_export_control |
| 生物两用品及相关设备和技术出口管制条例【已废止】 | 0.595 | 2002-10-14 | cn_export_control |
| 两用物项出口管制条例（国务院令792号） | 0.571 | 2024-10-23 | cn_export_control |
| 瑞士修訂《貨物管制條例》新增新興技術兩用物項管制 | 0.569 | 2025-04-08 | cn_export_control |
| 生物两用品出口管制条例（原文） | 0.568 | 2021-12-30 | cn_export_control |

**搜尋技術說明**：
- Embedding 模型：text-embedding-3-small
- 向量維度：1536
- 搜尋時間：2026-02-07
- Collection：cross-border-trade

---

## 免責聲明

本報告由自動化系統產出，數據來自 UN Comtrade、US Census Bureau 及中國商務部公開資訊。
報告內容僅供參考，不構成投資、法律或商業決策建議。
政策解讀為系統推測，可能與實際情況有差異，建議諮詢專業人士。
數據可能因來源更新而發生回溯修正。
Qdrant 語意搜尋結果基於向量相似度，相關性分數僅供參考。

---

## 資料來源

- UN Comtrade Database (https://comtradeplus.un.org/)
- U.S. Census Bureau Foreign Trade (https://www.census.gov/foreign-trade/)
- 中國商務部出口管制資訊網 (http://exportcontrol.mofcom.gov.cn/)
- Qdrant Vector Database (cross-border-trade collection)

### 引用檔案清單

**雙邊貿易流量 (bilateral_trade_flows)**
- `/docs/Extractor/bilateral_trade_flows/export_flow/158-export-2024.md`
- `/docs/Extractor/bilateral_trade_flows/export_flow/842-export-2024.md`
- `/docs/Extractor/bilateral_trade_flows/export_flow/156-export-2024.md`
- `/docs/Extractor/bilateral_trade_flows/import_flow/158-import-2024.md`
- `/docs/Extractor/bilateral_trade_flows/trade_balance/842-balance-2024.md`
- `/docs/Extractor/bilateral_trade_flows/market_concentration/158-hhi-2024.md`
- `/docs/Extractor/bilateral_trade_flows/market_concentration/842-hhi-2024.md`
- `/docs/Extractor/bilateral_trade_flows/market_concentration/156-hhi-2024.md`

**美國貿易普查 (us_trade_census)**
- `/docs/Extractor/us_trade_census/trade_balance/us-balance-5700-2026.md`
- `/docs/Extractor/us_trade_census/trade_balance/us-balance-5830-2026.md`
- `/docs/Extractor/us_trade_census/country_detail/us-detail-5700-2026.md`

**中國出口管制 (cn_export_control)**
- `/docs/Extractor/cn_export_control/mofcom-rare-earth-export-control-strengthening-oct2025.md`
- `/docs/Extractor/cn_export_control/heavy-rare-earth-export-controls.md`
- `/docs/Extractor/cn_export_control/lithium-battery-graphite-anode-export-controls.md`
- `/docs/Extractor/cn_export_control/dual-use-items-export-control-regulations-2024.md`
- `/docs/Extractor/cn_export_control/mofcom-unreliable-entity-list-additions-oct2025.md`
