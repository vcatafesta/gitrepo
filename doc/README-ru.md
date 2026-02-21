# Документация GitRepo

GitRepo — это комплексный инструмент, предназначенный для управления сборками пакетов и созданием ISO для проекта Chililinux. Он состоит из двух основных компонентов: build-package и build-iso.

## Оглавление

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

## Обзор

GitRepo упрощает процесс создания пакетов и ISO для проекта Chililinux. Он предлагает как интерактивный интерфейс, так и интерфейс командной строки, что обеспечивает гибкость в различных сценариях разработки.

## Установка

Инструменты GitRepo обычно устанавливаются в следующих местах:

- Общая библиотека (gitlib.sh): `/usr/share/chililinux/gitrepo/shell/gitlib.sh`
- Исполняемые скрипты (`build-package`, `build-iso`): `/usr/bin/`

Убедитесь, что эти местоположения находятся в PATH вашей системы.

## сборочный пакет

`build-package` используется для управления сборками пакетов. Его можно запустить в двух режимах:

### Интерактивный режим сборки пакета

Чтобы использовать интерактивный режим, перейдите в каталог клонированного репозитория для пакетов, отличных от AUR. Пакеты AUR можно запускать из любого каталога.

Бегать:
```
build-package
```

Это запустит интерактивный сеанс, который проведет вас через процесс сборки пакета.

### build-package Режим командной строки

Для неинтерактивного использования `build-package` принимает следующие параметры:

```
build-package [options]

Options:
  -o, --org, --organization <name>  Configure GitHub organization (default: chililinux)
  -c, --commit <message>            Commit and push changes
  -b, --build <branch>              Commit, push, and generate package (testing, stable, or extra)
  -a, --aur <package>               Build an AUR package
```

## сборка-iso

`build-iso` используется для создания ISO-образов. Как и `build-package`, его можно запустить в двух режимах:

### build-iso интерактивный режим

Бегать:
```
build-iso
```

После этого начнется интерактивный сеанс, который проведет вас через процесс создания ISO.

### build-iso Режим командной строки

Для неинтерактивного использования `build-iso` принимает следующие параметры:

```
build-iso [options]

Options:
  -o, --org, --organization <name>  Configure GitHub organization (default: talesam)
  -a, --auto, --automatic           Use automatic configuration for ISO build
```

## Общие параметры

И `build-package`, и `build-iso` поддерживают следующие общие параметры:

```
  -n, --nocolor                     Suppress color output
  -V, --version                     Print version information
  -h, --help                        Show help message
```

## Примеры использования

### Создание пакета в интерактивном режиме
```bash
cd /path/to/package/repo
build-package
```

### Сборка пакета AUR из любого каталога
```bash
build-package
# Then select "Construir pacote do AUR" in the interactive menu
```

### Сборка пакета с параметрами командной строки
```bash
build-package -o chiililinux -c "Update package version" -b testing
```

### Создание ISO в интерактивном режиме
```bash
build-iso
```

### Создание ISO с автоматической настройкой
```bash
build-iso -a
```

## Поиск неисправностей

Если у вас возникли проблемы:

1. Убедитесь, что вы находитесь в правильном каталоге при запуске `build-package` для пакетов, отличных от AUR.
2. Убедитесь, что `GITHUB_TOKEN` правильно установлен в `$HOME/.GITHUB_TOKEN`.
3. Проверьте подключение к Интернету для взаимодействия с API GitHub.
4. Проверьте журналы `/tmp/<script_name>/<repo_name>/` на наличие сообщений об ошибках.

Более подробную информацию о конкретных функциях и расширенном использовании см. во встроенных комментариях в файлах сценариев.
