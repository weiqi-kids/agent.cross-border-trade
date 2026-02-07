# 系統維護指令

本文件在操作 `core/` 目錄時由 Claude CLI 載入，提供 Layer / Mode 管理指令。

---

## Layer 管理

### 新增 Layer

觸發條件：使用者說「新增一個 {名稱} Layer」

1. 與使用者確認 Layer 定義表（含 category enum、WebFetch 策略、REVIEW_NEEDED 規則）
2. 判斷 Layer 類型：
   - **Type A（數據型）**：資料源為結構化 API → 需要 `fetch.sh` + `analyze.sh` + `update.sh`
   - **Type B（政策型）**：資料源為 RSS/HTML → 需要 `fetch.sh` + `update.sh`（Claude NLP 萃取）
3. 建立 `core/Extractor/Layers/{layer_name}/` 目錄
4. 依模板產生必要檔案
5. 建立 `docs/Extractor/{layer_name}/` 及 category 子目錄
6. 更新 `docs/explored.md`「已採用」表格

### 修改 Layer

1. 讀取 `core/Extractor/Layers/{layer_name}/CLAUDE.md` 確認現況
2. 與使用者確認修改內容
3. 若 category enum 有變動，確認不會影響既有 docs 分類
4. 列出影響範圍（哪些 Mode 引用此 Layer）

### 刪除 / 暫停 Layer

- **暫停**：`touch core/Extractor/Layers/{layer_name}/.disabled`
- **刪除**：先列出依賴此 Layer 的所有 Mode，警告影響範圍

---

## Mode 管理

### 新增 Mode

1. 與使用者確認 Mode 定義表
2. 建立 `core/Narrator/Modes/{mode_name}/CLAUDE.md`
3. 建立 `docs/Narrator/{mode_name}/` 目錄

### 修改 / 刪除 Mode

與 Layer 管理邏輯類似。

---

## 資料源管理

觸發條件：使用者說「我找到一個新的資料源 {URL}」

1. 測試連線（curl 確認可達）
2. 識別資料類型（JSON API / RSS / HTML）
3. 顯示前 5 筆樣本資料
4. 更新 `docs/explored.md`「評估中」表格
5. 詢問使用者要建立新 Layer 還是加入現有 Layer

---

## 雙路徑萃取模型

| 路徑 | 觸發條件 | 處理方式 |
|------|----------|----------|
| **Type A** | Layer 目錄含 `analyze.sh` | 執行 `analyze.sh`（純 jq 計算，不需 Claude） |
| **Type B** | Layer 目錄不含 `analyze.sh` | Claude 逐行 NLP 萃取（讀取 Layer CLAUDE.md） |

此判斷在步驟二（萃取）中執行，不影響 fetch 和 update 步驟。
