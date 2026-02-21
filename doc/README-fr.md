# Documentation GitRepo

GitRepo est un outil complet conçu pour gérer les builds de packages et la création ISO pour le projet Chililinux. Il se compose de deux composants principaux : `build-package` et `build-iso`.

## Table des matières

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

## Aperçu

GitRepo simplifie le processus de création de packages et d'ISO pour le projet Chililinux. Il offre des interfaces à la fois interactives et en ligne de commande, permettant une flexibilité dans divers scénarios de développement.

## Installation

Les outils GitRepo sont généralement installés aux emplacements suivants :

- Bibliothèque commune (`gitlib.sh`) : `/usr/share/chililinux/gitrepo/shell/gitlib.sh`
- Scripts exécutables (`build-package`, `build-iso`) : `/usr/bin/`

Assurez-vous que ces emplacements se trouvent dans le PATH de votre système.

## package de construction

`build-package` est utilisé pour gérer les builds de packages. Il peut être exécuté selon deux modes :

### Mode interactif du build-package

Pour utiliser le mode interactif, accédez au répertoire du référentiel cloné pour les packages non-AUR. Pour les packages AUR, il peut être exécuté à partir de n’importe quel répertoire.

Courir:
```
build-package
```

Cela lancera une session interactive vous guidant tout au long du processus de création de packages.

### mode ligne de commande build-package

Pour une utilisation non interactive, `build-package` accepte les options suivantes :

```
build-package [options]

Options:
  -o, --org, --organization <name>  Configure GitHub organization (default: chililinux)
  -c, --commit <message>            Commit and push changes
  -b, --build <branch>              Commit, push, and generate package (testing, stable, or extra)
  -a, --aur <package>               Build an AUR package
```

## construire-iso

`build-iso` est utilisé pour créer des images ISO. Comme `build-package`, il peut être exécuté dans deux modes :

### Mode interactif build-iso

Courir:
```
build-iso
```

Cela lancera une session interactive vous guidant tout au long du processus de création de l’ISO.

### mode ligne de commande build-iso

Pour une utilisation non interactive, `build-iso` accepte les options suivantes :

```
build-iso [options]

Options:
  -o, --org, --organization <name>  Configure GitHub organization (default: talesam)
  -a, --auto, --automatic           Use automatic configuration for ISO build
```

## Options communes

`build-package` et `build-iso` prennent en charge ces options courantes :

```
  -n, --nocolor                     Suppress color output
  -V, --version                     Print version information
  -h, --help                        Show help message
```

## Exemples d'utilisation

### Construire un package de manière interactive
```bash
cd /path/to/package/repo
build-package
```

### Construire un package AUR à partir de n'importe quel répertoire
```bash
build-package
# Then select "Construir pacote do AUR" in the interactive menu
```

### Construire un package avec des options de ligne de commande
```bash
build-package -o chiililinux -c "Update package version" -b testing
```

### Construire une ISO de manière interactive
```bash
build-iso
```

### Construire une ISO avec configuration automatique
```bash
build-iso -a
```

## Dépannage

Si vous rencontrez des problèmes :

1. Assurez-vous que vous êtes dans le bon répertoire lorsque vous exécutez `build-package` pour les packages non-AUR.
2. Vérifiez que `GITHUB_TOKEN` est correctement défini dans `$HOME/.GITHUB_TOKEN`.
3. Vérifiez votre connexion Internet pour les interactions avec l'API GitHub.
4. Vérifiez les journaux dans `/tmp/<script_name>/<repo_name>/` pour les messages d'erreur.

Pour des informations plus détaillées sur des fonctions spécifiques et une utilisation avancée, reportez-vous aux commentaires en ligne dans les fichiers de script.
