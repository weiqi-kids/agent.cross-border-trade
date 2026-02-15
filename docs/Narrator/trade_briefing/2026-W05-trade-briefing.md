---
layout: default
title: "2026 年第 05 週"
parent: 貿易動態週報
nav_order: 3
description: "鋰電池材料出口管制實施；六國 HHI 市場集中度分析"
date: 2026-01-28
article_section: 週報分析
keywords: "國際貿易, 中國, 鋰電池, 出口管制, HHI, 市場集中度, 2026"
related_reports:
  - "/Narrator/trade_briefing/2026-W06-trade-briefing/"
  - "/Narrator/supply_chain_analysis/2026-01-supply-chain-analysis/"
---


> 報告期間：2026-01-27 — 2026-02-02
> 產出時間：2026-01-28T12:00:00Z
> 自動化程度：80%（數據彙整自動，趨勢解讀建議人工審核）

---

## 摘要

本週資料更新涵蓋六大報告國（美國、中國、日本、南韓、德國、台灣）的雙邊貿易流量（UN Comtrade 2023-2024 年度彙總）、美國對主要東亞與歐洲貿易夥伴的商品級別進出口明細（US Census Bureau 2025 年 1-10 月累計），以及中國出口管制政策動態（cn_export_control，84 筆萃取結果中擇取最新重要政策 13 筆分析）。中國持續維持對美國 USD 6,971 億的最大貿易順差（來源：bilateral_trade_flows/trade_balance/156-balance-2024.md）；美國對台灣貿易逆差（US Census 口徑）達 USD 1,119 億，其中機械設備（HS84）進口逆差 USD 918 億，反映半導體供應鏈的極端集中性（來源：us_trade_census/trade_balance/us-balance-5830-2026.md）。政策面方面，2024-2025 年間中國系統性擴大關鍵礦物出口管制範圍（覆蓋石墨、鎵鍺、銻、鎢、銦、碲、鉍、鉬、稀土、超硬材料），同時 2025 年 11 月中美雙方在吉隆坡磋商後達成階段性緩和共識，美方暫停穿透性規則（FDPR）一年（來源：cn_export_control）。

---

## 一、出口重點

### 主要變化

**美國出口**（來源：bilateral_trade_flows/export_flow/842-export-2024.md、us_trade_census/monthly_export）

美國 2023-2024 年度前三大出口目的地為加拿大（Partner 124，USD 7,012 億）、墨西哥（Partner 484，USD 6,573 億）與中國（Partner 156，USD 2,914 億），三國合計占出口總額 40.41%。US Census 2025 年 1-10 月數據進一步顯示商品結構差異：對中國出口以電子電機設備（HS85，USD 138 億）和航空器（HS88，USD 137 億）為主；對台灣出口的核反應爐與機械（HS84，USD 133 億）為最大單一品項，反映半導體設備需求強勁；對韓國和日本出口則以礦物燃料（HS27）居首，分別達 USD 144 億和 USD 105 億。

**中國出口**（來源：bilateral_trade_flows/export_flow/156-export-2024.md、bilateral_trade_flows/commodity_structure/156-commodity-2024.md）

中國最大出口市場為美國（USD 1.03 兆，占比 14.76%），其次為香港（Partner 344，USD 5,654 億，占比 8.13%）及日本（USD 3,095 億，占比 4.45%）。中國出口市場的 HHI 為 447.18（低集中度），前三大市場合計僅占 27.34%，為六國中最分散的出口結構。越南（Partner 704，USD 2,995 億）與南韓（USD 2,952 億）為第四、五大出口市場。

**日本出口**（來源：bilateral_trade_flows/export_flow/392-export-2024.md）

日本出口高度依賴美國（USD 2,867 億，占比 20.11%）與中國（USD 2,511 億，占比 17.61%），兩國合計占出口近四成。南韓（USD 932 億，占比 6.54%）排名第三。HHI 為 894.65，屬低集中度。

**南韓出口**（來源：bilateral_trade_flows/export_flow/410-export-2024.md）

南韓前兩大出口市場為中國（USD 2,576 億，占比 19.59%）與美國（USD 2,447 億，占比 18.61%），越南（Partner 704，USD 1,118 億，占比 8.50%）排名第三，反映南韓製造業對東南亞的供應鏈佈局。HHI 為 911.24。

**德國出口**（來源：bilateral_trade_flows/export_flow/276-export-2024.md）

德國出口以中國（USD 1,069 億，占比 19.62%）、波蘭（Partner 616，USD 977 億，占比 17.94%）和英國（USD 862 億，占比 15.81%）為主。HHI 為 1188.5，為六國中最高，接近中度集中度門檻（1500）。注意：德國數據僅涵蓋 62 個夥伴群組（其他國家約 218-225 個），可能受 API 回傳範圍限制。（建議人工審核）

**台灣**（來源：bilateral_trade_flows/export_flow/158-export-2024.md）

UN Comtrade Preview API 未回傳台灣（158）出口記錄，confidence 標記為「低」。此為已知的長期資料限制（台灣非聯合國會員國）。[REVIEW_NEEDED]

### 數據表格

| 國家 | 前三大出口市場 | 前三大市場占比 | HHI | 備註 |
|------|-------------|---------------|-----|------|
| 美國 (842) | 加拿大、墨西哥、中國 | 40.41% | 723.51 | 北美自貿區框架占 33% |
| 中國 (156) | 美國、香港、日本 | 27.34% | 447.18 | 出口最分散 |
| 日本 (392) | 美國、中國、南韓 | 44.26% | 894.65 | 美中合占近 38% |
| 南韓 (410) | 中國、美國、越南 | 46.70% | 911.24 | 越南為第三大市場 |
| 德國 (276) | 中國、波蘭、英國 | 53.37% | 1188.50 | 接近中度集中，數據覆蓋較窄 |
| 台灣 (158) | -- | -- | -- | [REVIEW_NEEDED] 無數據 |

> 註：出口額為 UN Comtrade 2023-2024 年度彙總數據（2 年累計），非單年度數字。
> 來源：bilateral_trade_flows/export_flow、bilateral_trade_flows/market_concentration、bilateral_trade_flows/commodity_structure

---

## 二、進口重點

### 主要變化

**美國進口**（來源：bilateral_trade_flows/import_flow/842-import-2024.md、us_trade_census/monthly_import）

美國最大進口來源為墨西哥（USD 9,900 億）、中國（USD 9,106 億）和加拿大（USD 8,508 億）。US Census 商品結構數據顯示：從中國進口以電子電機設備（HS85，USD 698 億）和機械設備（HS84，USD 441 億）為最大宗；從台灣進口的機械設備（HS84）達 USD 1,051 億，為所有貿易夥伴中單一 HS 品項最高，主要反映半導體晶片進口；從日韓進口均以汽車（HS87）居首（日本 USD 374 億、南韓 USD 314 億）；從德國進口以機械（HS84，USD 253 億）和汽車（HS87，USD 227 億）為主。

美國對中國貿易逆差（US Census 2025 年 1-10 月口徑）為 USD 1,754 億，最大逆差商品為電子電機設備（HS85，逆差 USD 561 億）和機械（HS84，逆差 USD 350 億）。美國對台灣逆差 USD 1,119 億中，HS84 機械逆差 USD 918 億占 82%，反映半導體供應鏈的極端集中性。

*來源：us_trade_census/country_detail/us-detail-5700-2026.md、us_trade_census/country_detail/us-detail-5830-2026.md、us_trade_census/trade_balance/*

**中國進口**（來源：bilateral_trade_flows/import_flow/156-import-2024.md）

中國最大進口來源為「Other Asia nes」（Partner 490，USD 4,171 億，主要指台灣轉口），其次為南韓（USD 3,432 億）、美國（USD 3,297 億）和日本（USD 3,167 億）。澳大利亞（USD 2,964 億）和俄羅斯（Partner 643，USD 2,591 億）分列第五、六位，反映中國對能源與原物料的進口需求。

**日本進口**（來源：bilateral_trade_flows/import_flow/392-import-2024.md）

日本最大進口來源為中國（USD 3,352 億），遠超第二位的美國（USD 1,610 億）。中東能源進口占據重要地位（UAE USD 738 億、沙烏地 USD 645 億）。

**南韓進口**（來源：bilateral_trade_flows/import_flow/410-import-2024.md）

南韓最大進口來源為中國（USD 2,827 億），美國（USD 1,442 億）排名第二，日本（USD 952 億）第三。

**德國進口**（來源：bilateral_trade_flows/import_flow/276-import-2024.md）

德國進口數據量級明顯偏低（前 20 夥伴最大為斯洛伐克 USD 218 億），可能受 API 數據覆蓋範圍限制。（建議人工審核）

### 數據表格

| 國家 | 最大進口來源 | 最大進口來源額 (USD) | 對中貿易逆差 (UN Comtrade 口徑) | 備註 |
|------|------------|-------------------|------------------------------|------|
| 美國 (842) | 墨西哥 (484) | 9,900 億 | -6,193 億 (出口 2,914 億 vs 進口 9,106 億) | US Census 10 月逆差 -1,754 億 |
| 中國 (156) | Other Asia (490) | 4,171 億 | N/A | 含台灣轉口 |
| 日本 (392) | 中國 (156) | 3,352 億 | -841 億 (出口 2,511 億 vs 進口 3,352 億) | 能源進口依賴中東 |
| 南韓 (410) | 中國 (156) | 2,827 億 | -252 億 (出口 2,576 億 vs 進口 2,827 億) | 中間財進口為主 |
| 德國 (276) | 斯洛伐克 (703) | 218 億 | 數據偏低 | 數據覆蓋可能不完整 |

> 註：UN Comtrade 數據為 2023-2024 兩年度彙總。US Census 數據為 2025 年 1-10 月累計。數據口徑差異屬正常現象。
> 來源：bilateral_trade_flows/import_flow、us_trade_census/monthly_import、us_trade_census/trade_balance、us_trade_census/country_detail

---

## 三、政策更新

> **建議人工審核** — 以下政策解讀為系統分析結果，涉及法規詮釋與戰略判斷，建議專業人士覆核。

### 本週管制政策動態

基於 cn_export_control Layer 萃取結果（84 筆中擇取 13 筆最新重要政策分析），2024-2025 年間中國已建立一套系統性的關鍵礦物與戰略材料出口管制框架。以下按時間倒序呈現近期最重要的政策動態：

**一、中美階段性緩和措施（2025 年 11 月）**

1. **美方暫停穿透性規則（FDPR）一年**（來源：cn_export_control/us-export-control-penetration-rule-suspension-nov2025.md）
   - 暫停期間：2025-11-10 至 2026-11-09
   - 範圍：美國出口管制實體清單企業及其 >50% 持股關聯企業不受穿透性規則追加制裁
   - 中方評價：「美方落實中美吉隆坡經貿磋商共識的重要舉措」

2. **出口管制清單調整**（來源：cn_export_control/mofcom-export-control-list-adjustment-nov2025.md）
   - 暫停對 15 家美國實體（原第 13 號公告）的出口管制措施，自 2025-11-10 生效
   - 延長暫停 16 家美國實體（原第 21 號公告）的管制措施一年
   - 出口雙用途物項需向商務部申請審核

3. **不可靠實體清單調整**（來源：cn_export_control/mofcom-unreliable-entity-list-adjustment-nov2025.md）
   - 終止 2025 年 3 月 4 日公布的措施
   - 暫停 2025 年 4 月 4 日公布的措施一年（自 2025-11-10 起）
   - 建立國內企業交易申請通道

**二、關鍵礦物與戰略材料出口管制（2024-2025）**

4. **稀土強化管制**（來源：cn_export_control/mofcom-rare-earth-export-control-strengthening-oct2025.md）
   - 生效日期：2025-10-09
   - 第 61 號公告：管制「含中國成分的外國稀土相關物項」，首次確立域外效力
   - 第 62 號公告：限制稀土技術出口
   - 設有人道主義豁免條款和過渡期
   - 中國占全球稀土生產逾 60% 並主導加工環節

5. **超硬材料出口管制**（來源：cn_export_control/superhard-materials-export-control-2025.md）
   - 生效日期：2025-11-08
   - 管制合成金剛石微粉、單晶、線鋸、砂輪、DCPCVD 設備及工藝技術共 6 類
   - 影響半導體晶圓加工和精密製造產業鏈

6. **鎢、碲、鉍、鉬、銦出口管制**（來源：cn_export_control/critical-minerals-export-control-2025.md）
   - 生效日期：2025-02-04（發布即生效）
   - 涵蓋原材料、加工品、化合物及相關生產技術
   - 中國占全球鎢產量約 80%、銦約 60%、鉍約 80%
   - 生產技術管制限制外國建立替代供應能力

7. **銻及超硬材料設備管制**（來源：cn_export_control/antimony-superhard-materials-export-control-2024.md）
   - 生效日期：2024-09-15
   - 管制銻原礦、金屬銻、高純度有機銻化合物、銻化銦（InSb）
   - 同時管制六面頂壓機、微波等離子 CVD 設備及相關技術
   - 中國占全球銻產量約 48%，俄羅斯（第二大生產國）受制裁限制

8. **石墨出口管制優化**（來源：cn_export_control/graphite-export-control-optimization.md）
   - 生效日期：2023-12-01
   - 對高純度人造石墨（純度 >99.9%）及天然鱗片石墨（含球化石墨、膨脹石墨）實施出口許可管理
   - 中國占全球球化石墨產能逾 70%，直接影響鋰電池負極材料供應鏈

**三、反制裁與執法行動（2025）**

9. **反外國制裁法實施條例**（來源：cn_export_control/implementing-regulations-anti-foreign-sanctions-law-2025-04-08.md）
   - 生效日期：2025-04-08
   - 22 條實施條例，規範資產凍結、交易限制、出口管制等反制手段
   - 建立多部門協調反制裁執法框架

10. **不可靠實體清單新增（2025 年 10 月）**（來源：cn_export_control/mofcom-unreliable-entity-list-additions-oct2025.md）
    - 新增 Counter-Unmanned Aircraft Systems Technology Company、TechInsights 及附屬機構
    - 事由：軍事合作台灣、發表對中國的敵對言論、協助打壓中國企業

11. **對韓華海洋美國子公司反制**（來源：cn_export_control/mofcom-countermeasures-hanwha-ocean-subsidiaries-oct2025.md）
    - 因應美國 301 條款對中國海事造船業調查
    - 禁止中國組織與個人和韓華海洋 5 家美國子公司進行交易

**四、法規框架更新**

12. **兩用物項出口管制條例**（來源：cn_export_control/dual-use-items-export-control-regulations-2024.md）
    - 生效日期：2024-12-01（國務院令第 792 號）
    - 整合核、導彈、生物、化學雙用途物項的統一許可制度
    - 三級許可制：單項（1 年）、通用/綜合（3 年）、登記出口證書
    - 最終用戶管控與實體清單機制
    - 罰則：RMB 50 萬至 300 萬罰款，嚴重者追究刑事責任

13. **日本將中國企業列入最終用戶清單的中方回應**（來源：cn_export_control/mofcom-response-japan-end-user-list-update-sep2025.md）
    - 反對新增列入但歡迎移除兩家中國企業
    - 呼籲加強中日雙邊溝通擴大移除名單

### 潛在供應鏈影響

> 以下為推測性分析（speculative），非事實性陳述，僅供參考。建議人工審核。

- **半導體供應鏈風險**：銦化合物（III-V 族半導體關鍵材料）、合成金剛石工具（晶圓加工）、稀土（永磁體）的管制可能推高全球半導體製造成本。結合美國對台灣的半導體設備出口高度集中（HS84 USD 133 億），供應鏈雙重管制壓力值得關注。穿透性規則暫停一年為中國實體清單企業提供窗口期，但 2026 年 11 月後政策不確定性仍高。（推測）

- **電動車電池供應鏈衝擊**：石墨負極材料（中國產能 >70%）和稀土永磁材料的出口管制可能影響全球電動車生產計畫。球化石墨替代供應鏈建設需要數年時間。（推測）

- **國防工業供應壓力**：鎢合金（穿甲彈、配重）、銻（彈藥、紅外線系統）、稀土（導引系統、電子戰設備）的管制對西方國防工業形成直接供應壓力。中國在鎢（~80%）和銻（~48%）的全球產能占比使替代供應有限。（推測）

- **中美關係短期緩和信號**：吉隆坡磋商後的雙向緩和措施（出口管制清單調整 + 不可靠實體清單調整 + FDPR 暫停）表明雙方有管控衝突升級的共同意願。但暫停期限僅一年，2026 年 11 月後政策走向取決於後續談判進展。（推測）

- **域外效力擴大**：稀土管制中「含中國成分的外國物項」條款和兩用物項條例的域外管轄條款，可能要求使用中國原產受控材料的外國製造商申請出口許可，增加合規成本並可能造成供應鏈延遲。（推測）

---

## 四、市場集中度變化

以下為各報告國出口市場的 HHI（Herfindahl-Hirschman Index）指數，基於 UN Comtrade 2023-2024 年度數據計算。

| 國家 | HHI 指數 | 集中度 | 前三大市場占比 | 夥伴群組數 | 趨勢 |
|------|---------|--------|--------------|-----------|------|
| 中國 (156) | 447.18 | 低（最分散） | 27.34% | 220 | 出口多元化程度最高 |
| 美國 (842) | 723.51 | 低 | 40.41% | 223 | 北美自貿區框架下加墨合占 33%（推測） |
| 日本 (392) | 894.65 | 低 | 44.26% | 218 | 美中兩國結構性依賴 |
| 南韓 (410) | 911.24 | 低 | 46.70% | 225 | 越南崛起為第三大市場 |
| 德國 (276) | 1188.50 | 低（接近中度） | 53.37% | 62 | 前三大市場占逾半，需關注數據完整性 |
| 台灣 (158) | -- | -- | -- | -- | 無數據 [REVIEW_NEEDED] |

> HHI 參考值：<1500 低集中度（分散）；1500-2500 中度集中；>2500 高集中度（依賴）
> 集中度分析要點：
> - 中國 HHI 最低（447），儘管美國為最大單一市場（14.76%），出口高度多元化
> - 德國 HHI 最高（1189），但因夥伴群組數（62）遠低於其他國家（218-225），可能為數據覆蓋不足導致偏高（建議人工審核）
> - 日韓 HHI 結構相似（895 vs 911），前兩大市場皆為美國和中國（順序互換），反映東亞製造業對美中兩大市場的共同依賴
> 來源：bilateral_trade_flows/market_concentration

---

## 五、觀察清單

以下為基於本週數據更新需持續關注的項目，每項均附數據依據：

1. **美台半導體貿易逆差的集中度風險** — 美國從台灣進口 HS84（含半導體晶片）USD 1,052 億，占美台逆差 82%，為所有雙邊品類逆差中金額最大的單一項目。在地緣政治風險情境下，此極端集中性構成供應鏈脆弱點。
   *依據：us_trade_census/trade_balance/us-balance-5830-2026.md、us_trade_census/country_detail/us-detail-5830-2026.md*
   *（風險評估為推測，建議人工審核）*

2. **中國關鍵礦物管制的累積效應** — 從石墨（2023.12）、鎵鍺（2024.8）、銻（2024.9）、鎢銦碲鉍鉬（2025.2）、稀土（2025.10）到超硬材料（2025.11），管制範圍持續擴大，形成涵蓋半導體、電池、國防等領域的系統性管制體系。建議建立受管制物項追蹤清單。
   *依據：cn_export_control 多份文件（詳見政策更新章節）*

3. **中美穿透性規則暫停到期關注** — 暫停期至 2026-11-09 屆滿，屆時政策是否恢復具高度不確定性。影響實體清單上中國企業及其 >50% 持股關聯企業的技術取得能力，企業應利用窗口期進行供應鏈調整。
   *依據：cn_export_control/us-export-control-penetration-rule-suspension-nov2025.md*
   *（影響評估為推測）*

4. **稀土域外管制效力的實施觀察** — 「含中國成分的外國稀土相關物項」管制為中國出口管制中首次明確的域外效力條款。實際執法範圍與力度尚待觀察，可能影響永磁體、電子、國防、電動車等產業的全球供應鏈。
   *依據：cn_export_control/mofcom-rare-earth-export-control-strengthening-oct2025.md*
   *（影響評估為推測，建議人工審核）*

5. **日韓對美中市場的雙重依賴** — 日本與南韓對美國及中國的出口合計占比分別為 37.72% 和 38.20%。在中美出口管制互相升級的背景下，日韓企業面臨供應鏈選邊壓力。日本同時面臨中方對其最終用戶清單新增的外交反應。
   *依據：bilateral_trade_flows/commodity_structure/392-commodity-2024.md、410-commodity-2024.md、cn_export_control/mofcom-response-japan-end-user-list-update-sep2025.md*
   *（趨勢判斷為推測，建議人工審核）*

6. **德國出口市場集中度接近中度門檻** — HHI 1188.5 為六國最高。在歐中貿易摩擦背景下，德國對中國出口（占比 19.62%）的波動可能對其整體出口產生較大影響。但數據僅涵蓋 62 個夥伴群組，需確認是否為 API 限制。
   *依據：bilateral_trade_flows/market_concentration/276-hhi-2024.md*
   *（趨勢判斷為推測，建議人工審核）*

7. **台灣出口數據缺口** — UN Comtrade API 未回傳台灣（158）出口記錄，此為長期存在的資料限制。建議評估替代數據源（如台灣財政部關務署統計資料庫）以補足此缺口。
   *依據：bilateral_trade_flows/export_flow/158-export-2024.md*

8. **海關總署第 61、62 號公告內容待確認** — 兩份與稀土管制同日發布的海關公告因 WebFetch 失敗僅有標題，推測包含稀土出口管制的海關實施細則。建議人工補充擷取。
   *依據：cn_export_control/customs-announcement-2025-61.md、customs-announcement-2025-62.md（均標記 [REVIEW_NEEDED]）*

---

## 免責聲明

本報告由自動化系統產出，數據來自 UN Comtrade、US Census Bureau 及中國商務部公開資訊。
報告內容僅供參考，不構成投資、法律或商業決策建議。
政策解讀為系統推測，可能與實際情況有差異，建議諮詢專業人士。
數據可能因來源更新而發生回溯修正。

**數據期間與限制：**
- bilateral_trade_flows 數據為 UN Comtrade 2023-2024 年累計值（Preview API），非本週即時數據
- us_trade_census 數據為 US Census Bureau 2025 年度前 10 個月累計，截至資料擷取日（2026-01-27）
- cn_export_control 資料涵蓋 2020-2025 年間的法規更新，共 84 筆萃取結果，本報告擇取 13 筆最新重要政策分析
- 德國（276）的進口數據量級明顯偏低、出口夥伴群組數僅 62 個，可能受 API 回傳範圍限制
- 台灣（158）在 UN Comtrade 中無出口數據回傳，為已知長期限制
- 所有標註「推測」、「speculative」或「建議人工審核」的內容為系統分析，需專業人員確認
- 本報告不含 YoY 變化數據，因現有數據為多年度彙總而非逐年拆分

---

## 資料來源

- UN Comtrade Database (https://comtradeplus.un.org/) — bilateral_trade_flows Layer
  - `docs/Extractor/bilateral_trade_flows/export_flow/`: 842, 156, 392, 410, 276, 158 export 檔案
  - `docs/Extractor/bilateral_trade_flows/import_flow/`: 842, 156, 392, 410, 276 import 檔案
  - `docs/Extractor/bilateral_trade_flows/trade_balance/`: 842, 156, 392, 410, 276 balance 檔案
  - `docs/Extractor/bilateral_trade_flows/market_concentration/`: 842, 156, 392, 410, 276 HHI 檔案
  - `docs/Extractor/bilateral_trade_flows/commodity_structure/`: 842, 156, 392, 410, 276 commodity 檔案
- U.S. Census Bureau Foreign Trade (https://www.census.gov/foreign-trade/) — us_trade_census Layer
  - `docs/Extractor/us_trade_census/monthly_export/`: us-export-4280, 5700, 5800, 5830, 5880 (2026)
  - `docs/Extractor/us_trade_census/monthly_import/`: us-import-4280, 5700, 5800, 5830, 5880 (2026)
  - `docs/Extractor/us_trade_census/trade_balance/`: us-balance-4280, 5700, 5800, 5830, 5880 (2026)
  - `docs/Extractor/us_trade_census/country_detail/`: us-detail-5700, 5830 (2026)
- 中國商務部出口管制資訊網 (http://exportcontrol.mofcom.gov.cn/) — cn_export_control Layer
  - 共 84 筆萃取結果，本報告引用 13 筆（詳見「政策更新」章節各項來源標註）
  - 2 筆標記 [REVIEW_NEEDED]（customs-announcement-2025-61.md、customs-announcement-2025-62.md）
