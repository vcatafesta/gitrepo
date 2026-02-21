# GitRepo 文档

GitRepo 是一个综合工具，旨在管理 Chililinux 项目的包构建和 ISO 创建。它由两个主要组件组成：“build-package”和“build-iso”。

## 目录

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

GitRepo 简化了为 Chililinux 项目构建软件包和 ISO 的过程。它提供交互式和命令行界面，允许在各种开发场景中灵活地使用。

## 安装

GitRepo 工具通常安装在以下位置：

- 公共库（`gitlib.sh`）：`/usr/share/chililinux/gitrepo/shell/gitlib.sh`
- 可执行脚本（`build-package`、`build-iso`）：`/usr/bin/`

确保这些位置位于系统的路径中。

## 构建包

`build-package` 用于管理包构建。它可以以两种模式运行：

### 构建包交互模式

要使用交互模式，请导航到非 AUR 包的克隆存储库目录。对于 AUR 包，它可以从任何目录运行。

跑步：
```
build-package
```

这将启动一个交互式会话，指导您完成包构建过程。

### 命令行模式

对于非交互式使用，“build-package”接受以下选项：

```
build-package [options]

Options:
  -o, --org, --organization <name>  Configure GitHub organization (default: chililinux)
  -c, --commit <message>            Commit and push changes
  -b, --build <branch>              Commit, push, and generate package (testing, stable, or extra)
  -a, --aur <package>               Build an AUR package
```

## 构建 ISO

`build-iso` 用于创建 ISO 映像。与“build-package”一样，它可以以两种模式运行：

### build-iso 交互模式

跑步：
```
build-iso
```

这将启动一个交互式会话，指导您完成 ISO 构建过程。

### build-iso 命令行模式

对于非交互式使用，“build-iso”接受以下选项：

```
build-iso [options]

Options:
  -o, --org, --organization <name>  Configure GitHub organization (default: talesam)
  -a, --auto, --automatic           Use automatic configuration for ISO build
```

## 常用选项

`build-package` 和 `build-iso` 都支持这些常见选项：

```
  -n, --nocolor                     Suppress color output
  -V, --version                     Print version information
  -h, --help                        Show help message
```

## 使用示例

### 交互式构建包
```bash
cd /path/to/package/repo
build-package
```

### 从任何目录构建 AUR 包
```bash
build-package
# Then select "Construir pacote do AUR" in the interactive menu
```

### 使用命令行选项构建包
```bash
build-package -o chiililinux -c "Update package version" -b testing
```

### 交互式构建 ISO
```bash
build-iso
```

### 构建具有自动配置的 ISO
```bash
build-iso -a
```

## 故障排除

如果您遇到问题：

1. 对非 AUR 包运行“build-package”时，请确保您位于正确的目录中。
2. 检查“$HOME/.GITHUB_TOKEN”中的“GITHUB_TOKEN”是否正确设置。
3. 验证 GitHub API 交互的互联网连接。
4. 检查“/tmp/<script_name>/<repo_name>/”中的日志以获取错误消息。

有关特定功能和高级用法的更多详细信息，请参阅脚本文件中的内联注释。
