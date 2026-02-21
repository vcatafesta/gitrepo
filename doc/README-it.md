# Documentazione GitRepo

GitRepo è uno strumento completo progettato per la gestione della creazione di pacchetti e della creazione ISO per il progetto Chililinux. È costituito da due componenti principali: `build-package` e `build-iso`.

## Sommario

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

## Panoramica

GitRepo semplifica il processo di creazione di pacchetti e ISO per il progetto Chililinux. Offre interfacce sia interattive che a riga di comando, consentendo flessibilità in vari scenari di sviluppo.

## Installazione

Gli strumenti GitRepo vengono generalmente installati nelle seguenti posizioni:

- Libreria comune (`gitlib.sh`): `/usr/share/chililinux/gitrepo/shell/gitlib.sh`
- Script eseguibili (`build-package`, `build-iso`): `/usr/bin/`

Assicurati che queste posizioni siano nel PERCORSO del tuo sistema.

## pacchetto di build

`build-package` viene utilizzato per gestire la compilazione dei pacchetti. Può essere eseguito in due modalità:

### Modalità interattiva del pacchetto build

Per utilizzare la modalità interattiva, accedere alla directory del repository clonato per i pacchetti non AUR. Per i pacchetti AUR, può essere eseguito da qualsiasi directory.

Correre:
```
build-package
```

Verrà avviata una sessione interattiva che ti guiderà attraverso il processo di creazione del pacchetto.

### Modalità riga di comando del pacchetto build

Per l'uso non interattivo, `build-package` accetta le seguenti opzioni:

```
build-package [options]

Options:
  -o, --org, --organization <name>  Configure GitHub organization (default: chililinux)
  -c, --commit <message>            Commit and push changes
  -b, --build <branch>              Commit, push, and generate package (testing, stable, or extra)
  -a, --aur <package>               Build an AUR package
```

## build-iso

"build-iso" viene utilizzato per creare immagini ISO. Come `build-package`, può essere eseguito in due modalità:

### Modalità interattiva build-iso

Correre:
```
build-iso
```

Verrà avviata una sessione interattiva che ti guiderà attraverso il processo di creazione dell'ISO.

### build-iso Modalità da riga di comando

Per l'uso non interattivo, `build-iso` accetta le seguenti opzioni:

```
build-iso [options]

Options:
  -o, --org, --organization <name>  Configure GitHub organization (default: talesam)
  -a, --auto, --automatic           Use automatic configuration for ISO build
```

## Opzioni comuni

Sia `build-package` che `build-iso` supportano queste opzioni comuni:

```
  -n, --nocolor                     Suppress color output
  -V, --version                     Print version information
  -h, --help                        Show help message
```

## Esempi di utilizzo

### Costruire un pacchetto in modo interattivo
```bash
cd /path/to/package/repo
build-package
```

### Costruire un pacchetto AUR da qualsiasi directory
```bash
build-package
# Then select "Construir pacote do AUR" in the interactive menu
```

### Creazione di un pacchetto con opzioni della riga di comando
```bash
build-package -o chiililinux -c "Update package version" -b testing
```

### Costruire una ISO in modo interattivo
```bash
build-iso
```

### Costruire una ISO con configurazione automatica
```bash
build-iso -a
```

## Risoluzione dei problemi

Se riscontri problemi:

1. Assicurati di essere nella directory corretta quando esegui `build-package` per pacchetti non AUR.
2. Controlla che `GITHUB_TOKEN` sia impostato correttamente in `$HOME/.GITHUB_TOKEN`.
3. Verifica la tua connessione Internet per le interazioni API GitHub.
4. Controllare i log in `/tmp/<script_name>/<repo_name>/` per eventuali messaggi di errore.

Per informazioni più dettagliate su funzioni specifiche e utilizzo avanzato, fare riferimento ai commenti in linea nei file di script.
