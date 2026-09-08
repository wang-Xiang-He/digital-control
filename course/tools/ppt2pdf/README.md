# ppt2pdf

把 `course/` 底下所有 `.ppt` / `.pptx` 轉成 PDF，輸出到與原檔相同的資料夾，檔名相同（副檔名改為 `.pdf`）。

需求：本機需安裝 Microsoft PowerPoint（透過 COM 自動化呼叫，非 headless，執行時會短暫開啟 PowerPoint）。

## 使用方式

```powershell
powershell -ExecutionPolicy Bypass -File .\convert.ps1
```

指定其他資料夾：

```powershell
powershell -ExecutionPolicy Bypass -File .\convert.ps1 -Path "C:\path\to\course"
```

已存在同名 PDF 預設會跳過，若要強制覆蓋重轉：

```powershell
powershell -ExecutionPolicy Bypass -File .\convert.ps1 -Force
```
