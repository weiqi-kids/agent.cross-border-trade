# cn_export_control — 中國出口管制政策 Layer

## Layer 定義表

| 項目 | 內容 |
|------|------|
| **Layer name** | cn_export_control（中國出口管制政策） |
| **Layer type** | Type B（政策型） |
| **Engineering function** | 擷取中國出口管制政策更新，NLP 萃取結構化事實 |
| **Collectable data** | 中國商務部出口管制資訊網 — 政策公告、管制清單變更、執法案例 |
| **Automation level** | 70% — 自動擷取 + NLP 萃取，政策解讀需人工確認 |
| **Output value** | 管制政策動態、受控物項變更、執法趨勢、對供應鏈的潛在影響 |
| **Risk type** | 政策解讀偏差、翻譯失真、時效性（政策可能即時生效） |
| **Reviewer persona** | 政策解讀審核員、法規與責任審核員 |
| **Category enum** | 見下方分類規則 |
| **WebFetch 策略** | 必用（文章列表頁無完整內容） |

## 資料源

- **網站**: 中國商務部出口管制資訊網
- **URL**: http://exportcontrol.mofcom.gov.cn
- **語言**: 中文（需翻譯關鍵術語為英文）
- **更新頻率**: 不定期，通常每週數則

## 分類規則（Category Enum）

| 英文 key | 中文 | 判定條件 |
|----------|------|----------|
| `regulation_update` | 法規更新 | 新法規發布、既有法規修訂、實施細則 |
| `controlled_item_change` | 管制物項變更 | 管制清單新增/移除/調整品項 |
| `enforcement_action` | 執法行動 | 違規處罰案例、調查公告 |
| `policy_guidance` | 政策指導 | 政策解讀、企業合規指南、問答 |
| `international_cooperation` | 國際合作 | 多邊出口管制機制、雙邊協議 |

> **嚴格限制**：category 只能使用以上 5 個值，不可自行新增。

## WebFetch 策略

- **策略**: 必用，含 curl 降級
- **原因**: 列表頁僅有標題和日期，必須取得文章全文
- **降級處理**: WebFetch 失敗時，使用 Bash curl 降級抓取（見萃取步驟）
- **最終降級**: curl 也失敗時，僅基於標題萃取，並標記 `[REVIEW_NEEDED]`

## 萃取指令

### 輸入

每行 JSONL 包含：
```json
{
  "title": "文章標題（中文）",
  "url": "文章連結",
  "date": "發布日期",
  "source_page": "來源列表頁 URL"
}
```

### 萃取步驟

1. **嘗試 WebFetch** 取得文章全文（中文）
2. **若 WebFetch 失敗，改用 Bash curl 降級**：
   ```bash
   curl -sS "$url" --max-time 30 | sed -n 's/<p[^>]*>\(.*\)<\/p>/\1/gp' | sed 's/<[^>]*>//g'
   ```
   - 此指令解析 MOFCOM HTML 的 `<p>` 標籤內容
   - 若 curl 成功取得內容，在 Notes 標註「via curl fallback」
3. **若 curl 也失敗**，才標記 `[REVIEW_NEEDED]` 並僅基於標題萃取
4. **分類判定**：根據標題和內容，匹配 category enum
5. **結構化萃取**：
   - 政策名稱（中英文）
   - 發布機構
   - 生效日期
   - 影響範圍（哪些產業/物項/國家受影響）
   - 關鍵條款摘要
   - 對供應鏈的潛在影響評估
4. **翻譯規則**：
   - 法規名稱保留中文原文，附加英文翻譯
   - 專業術語使用國際通用英文（如：兩用物項 = dual-use items）
   - 機構名稱使用官方英文名稱

## `[REVIEW_NEEDED]` 觸發規則

以下情況**必須**標記 `[REVIEW_NEEDED]`：
1. WebFetch 和 curl 降級都失敗，僅基於標題萃取（內容不完整）
2. 無法判斷 category（標題模糊，未能分類）
3. 政策涉及立即生效的重大管制變更（需緊急人工確認）
4. 文章內容與標題不符（可能是網站結構變更）

以下情況**不觸發** `[REVIEW_NEEDED]`：
- WebFetch 失敗但 curl 降級成功取得全文
- 政策為常規性更新（例行公告）
- 中文翻譯的細微差異（這是結構性限制）
- 缺少具體生效日期（部分政策不公布明確日期）

## 輸出格式

```markdown
# {policy_title_cn}（{policy_title_en}）

- **Source**: exportcontrol.mofcom.gov.cn
- **URL**: {article_url}
- **Date**: {publish_date}
- **Category**: {category}
- **Fetched**: {fetched_at}
- **confidence**: {高/中/低}

## Summary

{2-3 sentence summary in English}

## Key Details

- **Issuing Authority**: {機構名稱（英文）}
- **Effective Date**: {生效日期}
- **Scope**: {影響範圍}

## Key Provisions

{結構化條款摘要}

## Supply Chain Impact Assessment

{對供應鏈的潛在影響，標註為推測性分析}

## Notes

{補充說明，包含 WebFetch 狀態}

---

*Source: China Ministry of Commerce Export Control Information Network*
```

## 已知限制

- **WebFetch 工具解析 MOFCOM HTML 不穩定**：`exportcontrol.mofcom.gov.cn` 的文章內容實際存在於靜態 HTML 的 `<p>` 標籤中（非 JS 動態渲染），但 WebFetch 工具偶爾無法正確解析。
- **當前影響**：少數文章 WebFetch 失敗時觸發 `[REVIEW_NEEDED]`。
- **降級策略**：WebFetch 失敗時，改用 `curl` 抓取 HTML 並以 `sed` 解析 `<p>` 標籤內容，可取得完整文章文本。

## 自我審核 Checklist

輸出前必須逐項確認：

- [ ] category 為 5 個 enum 值之一
- [ ] 中文法規名稱完整保留
- [ ] 英文翻譯使用國際通用術語
- [ ] 推測性內容明確標註（如 Supply Chain Impact Assessment）
- [ ] 發布日期格式正確（YYYY-MM-DD）
- [ ] 內容取得方式在 Notes 中記錄（WebFetch / curl fallback / 僅標題）
- [ ] 未超出 REVIEW_NEEDED 觸發範圍
- [ ] 免責聲明：政策解讀僅供參考，不構成法律意見
