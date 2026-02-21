# GitRepo-Dokumentation

GitRepo ist ein umfassendes Tool zur Verwaltung von Paketerstellungen und ISO-Erstellung für das Chililinux-Projekt. Es besteht aus zwei Hauptkomponenten: „build-package“ und „build-iso“.

## Inhaltsverzeichnis

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

## Überblick

GitRepo vereinfacht den Prozess der Erstellung von Paketen und ISOs für das Chililinux-Projekt. Es bietet sowohl interaktive als auch Befehlszeilenschnittstellen und ermöglicht so Flexibilität in verschiedenen Entwicklungsszenarien.

## Installation

Die GitRepo-Tools werden normalerweise an den folgenden Orten installiert:

- Gemeinsame Bibliothek (`gitlib.sh`): `/usr/share/chililinux/gitrepo/shell/gitlib.sh`
- Ausführbare Skripte („build-package“, „build-iso“): „/usr/bin/“.

Stellen Sie sicher, dass sich diese Speicherorte im PATH Ihres Systems befinden.

## Build-Paket

„build-package“ wird zum Verwalten von Paket-Builds verwendet. Es kann in zwei Modi ausgeführt werden:

### Build-Paket Interaktiver Modus

Um den interaktiven Modus zu verwenden, navigieren Sie zum geklonten Repository-Verzeichnis für Nicht-AUR-Pakete. Für AUR-Pakete kann es von jedem Verzeichnis aus ausgeführt werden.

Laufen:
```
build-package
```

Dadurch wird eine interaktive Sitzung gestartet, die Sie durch den Paketerstellungsprozess führt.

### build-package-Befehlszeilenmodus

Für die nicht interaktive Nutzung akzeptiert „build-package“ die folgenden Optionen:

```
build-package [options]

Options:
  -o, --org, --organization <name>  Configure GitHub organization (default: chililinux)
  -c, --commit <message>            Commit and push changes
  -b, --build <branch>              Commit, push, and generate package (testing, stable, or extra)
  -a, --aur <package>               Build an AUR package
```

## build-iso

„build-iso“ wird zum Erstellen von ISO-Images verwendet. Wie „build-package“ kann es in zwei Modi ausgeführt werden:

### build-iso interaktiver Modus

Laufen:
```
build-iso
```

Dadurch wird eine interaktive Sitzung gestartet, die Sie durch den ISO-Erstellungsprozess führt.

### build-iso-Befehlszeilenmodus

Für die nicht interaktive Nutzung akzeptiert „build-iso“ die folgenden Optionen:

```
build-iso [options]

Options:
  -o, --org, --organization <name>  Configure GitHub organization (default: talesam)
  -a, --auto, --automatic           Use automatic configuration for ISO build
```

## Allgemeine Optionen

Sowohl „build-package“ als auch „build-iso“ unterstützen diese allgemeinen Optionen:

```
  -n, --nocolor                     Suppress color output
  -V, --version                     Print version information
  -h, --help                        Show help message
```

## Anwendungsbeispiele

### Interaktiv ein Paket erstellen
```bash
cd /path/to/package/repo
build-package
```

### Erstellen eines AUR-Pakets aus einem beliebigen Verzeichnis
```bash
build-package
# Then select "Construir pacote do AUR" in the interactive menu
```

### Erstellen eines Pakets mit Befehlszeilenoptionen
```bash
build-package -o chiililinux -c "Update package version" -b testing
```

### Interaktiv eine ISO erstellen
```bash
build-iso
```

### Erstellen einer ISO mit automatischer Konfiguration
```bash
build-iso -a
```

## Fehlerbehebung

Wenn Sie auf Probleme stoßen:

1. Stellen Sie sicher, dass Sie sich im richtigen Verzeichnis befinden, wenn Sie „build-package“ für Nicht-AUR-Pakete ausführen.
2. Überprüfen Sie, ob „GITHUB_TOKEN“ in „$HOME/.GITHUB_TOKEN“ korrekt eingestellt ist.
3. Überprüfen Sie Ihre Internetverbindung für GitHub-API-Interaktionen.
4. Überprüfen Sie die Protokolle in „/tmp/<script_name>/<repo_name>/“ auf Fehlermeldungen.

Ausführlichere Informationen zu bestimmten Funktionen und zur erweiterten Verwendung finden Sie in den Inline-Kommentaren in den Skriptdateien.
