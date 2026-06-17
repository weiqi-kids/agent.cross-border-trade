---
last_modified_at: 2026-06-17
layout: default
title: 網站健檢報告 2026-06-17
parent: 網站健檢
nav_order: 1
nav_exclude: true
description: "2026-06-17 全球貿易情報系統網站健檢：Core Web Vitals 全綠、W3C 零錯誤、待補安全標頭"
---

# 網站健檢報告 - 2026-06-17

> 工具：`revamp/tools/site-audit.sh`（本地 Lighthouse via npx + curl/W3C/SEO 檢測）
> 受測網址：https://trade.weiqi.kids
> 執行時間：2026-06-17（緊接 2026-W25 完整流程部署後）

## 健檢摘要

| 指標 | 數值 | 評價 | 變化 |
|------|------|------|------|
| LCP（最大內容繪製） | 1.3 s | ✅ 良好（< 2.5s） | → |
| CLS（累積版面位移） | 0 | ✅ 完美 | → |
| TBT（總阻塞時間） | 180 ms | ✅ 良好（< 200ms） | → |
| Speed Index | 3.3 s | ⚠️ 尚可 | → |
| TTI（可互動時間） | 2.2 s | ✅ 良好 | → |
| W3C HTML 驗證 | 0 錯誤 / 0 警告 | ✅ | → |
| robots.txt | 存在 | ✅ | → |
| sitemap.xml | 存在（38 URL） | ✅ | → |

> 註：sitemap 為部署完成前快照（38 URL）；本次新增 6 篇報告 + 31 篇政策萃取頁將於 GitHub Actions 重建 sitemap 後納入。

## 安全性檢測

| 項目 | 狀態 | 說明 |
|------|------|------|
| HSTS | ❌ 缺 | GitHub Pages 預設不送 `Strict-Transport-Security` |
| X-Frame-Options | ❌ 缺 | 同上，靜態 Pages 無法自訂回應標頭 |
| X-Content-Type-Options | ❌ 缺 | 同上 |
| CSP | ❌ 缺 | 同上 |
| Server | GitHub.com | GitHub Pages 託管 |
| SSL Labs | 掃描進行中 | API 回 IN_PROGRESS，建議稍後重測 |
| Mozilla Observatory | 暫時不可用 | API 端暫時無回應，建議稍後重測 |

## 優化建議

| 優先級 | 問題 | 建議行動 |
|--------|------|----------|
| P2 | 缺少 HTTP 安全標頭（HSTS/CSP/X-Frame-Options/X-Content-Type-Options） | GitHub Pages 靜態託管無法直接設定回應標頭；若需強化，評估改用 Cloudflare（免費方案可注入 HSTS/CSP）或自架反向代理 |
| P2 | Speed Index 3.3 s 偏高 | 檢視首頁 Mermaid 圖表與大型表格的渲染成本，考慮延遲載入 Mermaid 或改為靜態圖 |
| P3 | SSL Labs / Observatory 本次未取得結果 | 非網站問題（第三方 API 暫時不可用 / 掃描排隊）；下次健檢重測即可 |

## 結論

- **無 P0／P1 問題**：效能（Core Web Vitals 全綠）、可及性與 SEO 基礎結構（robots/sitemap/W3C）皆健康，無需觸發完整 revamp 流程。
- 唯一結構性限制為 GitHub Pages 無法自訂安全標頭（P2，需平台層方案）。

## 下次健檢追蹤

- [ ] 部署完成後重測，確認 sitemap URL 數已含本次 6 篇新報告
- [ ] 重測 SSL Labs 與 Mozilla Observatory（本次第三方 API 不可用）
- [ ] 評估首頁 Speed Index 優化（Mermaid 延遲載入）
</content>
</invoke>
