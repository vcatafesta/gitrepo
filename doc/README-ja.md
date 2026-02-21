# GitRepo ドキュメント

GitRepo は、Chililinux プロジェクトのパッケージ ビルドと ISO 作成を管理するために設計された包括的なツールです。これは、`build-package` と `build-iso` という 2 つの主要コンポーネントで構成されます。

## 目次

1. [Overview](#overview)
2. [Installation](#installation)
3. [build-package](#build-package)
   - [Interactive Mode](#build-package-interactive-mode)
   - [Command-line Mode](#build-package-command-line-mode)
4. [build-iso](#build-iso)
   - [Interactive Mode](#build-iso-interactive-mode)
   - [Command-line Mode](#build-iso-command-line-mode)
5. [Common Options](#common-options)
6. [Usage Examples](#usage-examples)
7. [Troubleshooting](#troubleshooting)

## 概要

GitRepo は、Chililinux プロジェクトのパッケージと ISO を構築するプロセスを簡素化します。インタラクティブなインターフェイスとコマンドライン インターフェイスの両方を提供し、さまざまな開発シナリオでの柔軟性を実現します。

## インストール

GitRepo ツールは通常、次の場所にインストールされます。

- 共通ライブラリ (`gitlib.sh`): `/usr/share/chililinux/gitrepo/shell/gitlib.sh`
- 実行可能スクリプト (`build-package`、`build-iso`): `/usr/bin/`

これらの場所がシステムの PATH にあることを確認してください。

## ビルドパッケージ

`build-package` はパッケージのビルドを管理するために使用されます。次の 2 つのモードで実行できます。

### ビルドパッケージ対話型モード

対話型モードを使用するには、非 AUR パッケージの複製されたリポジトリ ディレクトリに移動します。 AUR パッケージの場合は、任意のディレクトリから実行できます。

走る：
```
build-package
```

これにより、パッケージ構築プロセスをガイドする対話型セッションが開始されます。

### build-package コマンドライン モード

非対話型で使用する場合、`build-package` は次のオプションを受け入れます。

```
build-package [options]

Options:
  -o, --org, --organization <name>  Configure GitHub organization (default: chililinux)
  -c, --commit <message>            Commit and push changes
  -b, --build <branch>              Commit, push, and generate package (testing, stable, or extra)
  -a, --aur <package>               Build an AUR package
```

## ビルド ISO

ISO イメージの作成には `build-iso` が使用されます。 「build-package」と同様に、次の 2 つのモードで実行できます。

### build-iso インタラクティブモード

走る：
```
build-iso
```

これにより、ISO 構築プロセスをガイドする対話型セッションが開始されます。

### build-iso コマンドライン モード

非対話型使用の場合、`build-iso` は次のオプションを受け入れます。

```
build-iso [options]

Options:
  -o, --org, --organization <name>  Configure GitHub organization (default: talesam)
  -a, --auto, --automatic           Use automatic configuration for ISO build
```

## 共通オプション

`build-package` と `build-iso` は両方とも、次の共通オプションをサポートしています。

```
  -n, --nocolor                     Suppress color output
  -V, --version                     Print version information
  -h, --help                        Show help message
```

## 使用例

### パッケージを対話的に構築する
```bash
cd /path/to/package/repo
build-package
```

### 任意のディレクトリから AUR パッケージをビルドする
```bash
build-package
# Then select "Construir pacote do AUR" in the interactive menu
```

### コマンドラインオプションを使用してパッケージを構築する
```bash
build-package -o chiililinux -c "Update package version" -b testing
```

### ISO を対話的に構築する
```bash
build-iso
```

### 自動構成による ISO の構築
```bash
build-iso -a
```

## トラブルシューティング

問題が発生した場合:

1. 非 AUR パッケージの「build-package」を実行するときは、正しいディレクトリにいることを確認してください。
2. 「$HOME/.GITHUB_TOKEN」に「GITHUB_TOKEN」が正しく設定されていることを確認してください。
3. GitHub API インタラクションのためのインターネット接続を確認します。
4. `/tmp/<script_name>/<repo_name>/` 内のログでエラー メッセージを確認してください。

特定の機能と高度な使用方法の詳細については、スクリプト ファイルのインライン コメントを参照してください。
