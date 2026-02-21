# GitRepo 文檔

GitRepo 是一個綜合工具，旨在管理 Chililinux 專案的套件建置和 ISO 建立。它由兩個主要組件組成：“build-package”和“build-iso”。

## 目錄

1. 辣椒_REF_0_辣椒
2. 辣椒_REF_0_辣椒
3. 辣椒_REF_0_辣椒
   - 辣椒_REF_0_辣椒
   - 辣椒_REF_0_辣椒
4. 辣椒_REF_0_辣椒
   - 辣椒_REF_0_辣椒
   - 辣椒_REF_0_辣椒
5. 辣椒_REF_0_辣椒
6. 辣椒_REF_0_辣椒
7. 辣椒_REF_0_辣椒

## 概述

GitRepo 簡化了為 Chililinux 專案建立軟體包和 ISO 的過程。它提供互動式和命令列介面，允許在各種開發場景中靈活地使用。

## 安裝

GitRepo 工具通常安裝在下列位置：

- 公用函式庫（`gitlib.sh`）：`/usr/share/chililinux/gitrepo/shell/gitlib.sh`
- 可執行腳本（`build-package`、`build-iso`）：`/usr/bin/`

確保這些位置位於系統的路徑中。

## 建置包

`build-package` 用於管理套件建置。它可以以兩種模式運作：

### 建構包互動模式

若要使用互動模式，請導覽至非 AUR 套件的克隆儲存庫目錄。對於 AUR 包，它可以從任何目錄運行。

跑步：
```
build-package
```

這將啟動一個互動式會話，指導您完成套件建置流程。

### 命令列模式

對於非互動式使用，「build-package」接受以下選項：

```
build-package [options]

Options:
  -o, --org, --organization <name>  Configure GitHub organization (default: chililinux)
  -c, --commit <message>            Commit and push changes
  -b, --build <branch>              Commit, push, and generate package (testing, stable, or extra)
  -a, --aur <package>               Build an AUR package
```

## 建構 ISO

`build-iso` 用於建立 ISO 映像。與“build-package”一樣，它可以以兩種模式運行：

### build-iso 互動模式

跑步：
```
build-iso
```

這將啟動一個互動式會話，指導您完成 ISO 建置流程。

### build-iso 命令列模式

對於非互動式使用，「build-iso」接受以下選項：

```
build-iso [options]

Options:
  -o, --org, --organization <name>  Configure GitHub organization (default: talesam)
  -a, --auto, --automatic           Use automatic configuration for ISO build
```

## 常用選項

`build-package` 和 `build-iso` 都支援這些常見選項：

```
  -n, --nocolor                     Suppress color output
  -V, --version                     Print version information
  -h, --help                        Show help message
```

## 使用範例

### 互動式建置包
```bash
cd /path/to/package/repo
build-package
```

### 從任何目錄建立 AUR 包
```bash
build-package
# Then select "Construir pacote do AUR" in the interactive menu
```

### 使用命令列選項建構包
```bash
build-package -o chiililinux -c "Update package version" -b testing
```

### 互動式建構 ISO
```bash
build-iso
```

### 建置具有自動配置的 ISO
```bash
build-iso -a
```

## 故障排除

如果您遇到問題：

1. 對非 AUR 套件執行「build-package」時，請確保您位於正確的目錄中。
2. 檢查「$HOME/.GITHUB_TOKEN」中的「GITHUB_TOKEN」是否已正確設定。
3. 驗證 GitHub API 互動的網路連線。
4. 檢查“/tmp/<script_name>/<repo_name>/”中的日誌以取得錯誤訊息。

有關特定功能和高級用法的更多詳細信息，請參閱腳本文件中的內聯註釋。
