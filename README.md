# GitRepo Documentation

GitRepo is a comprehensive tool designed for managing package builds and ISO creation for the BigCommunity project. It consists of two main components: `build-package` and `build-iso`.

## Table of Contents

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

## Overview

GitRepo simplifies the process of building packages and ISOs for the BigCommunity project. It offers both interactive and command-line interfaces, allowing for flexibility in various development scenarios.

## Installation

The GitRepo tools are typically installed in the following locations:

- Common library (`gitlib.sh`): `/usr/share/community/gitrepo/shell/gitlib.sh`
- Executable scripts (`build-package`, `build-iso`): `/usr/bin/`

Ensure these locations are in your system's PATH.

## build-package

`build-package` is used for managing package builds. It can be run in two modes:

### build-package Interactive Mode

To use the interactive mode, navigate to the cloned repository directory for non-AUR packages. For AUR packages, it can be run from any directory.

Run:
```
build-package
```

This will start an interactive session guiding you through the package building process.

### build-package Command-line Mode

For non-interactive use, `build-package` accepts the following options:

```
build-package [options]

Options:
  -o, --org, --organization <name>  Configure GitHub organization (default: communitybig)
  -c, --commit <message>            Commit and push changes
  -b, --build <branch>              Commit, push, and generate package (testing, stable, or extra)
  -a, --aur <package>               Build an AUR package
```

## build-iso

`build-iso` is used for creating ISO images. Like `build-package`, it can be run in two modes:

### build-iso Interactive Mode

Run:
```
build-iso
```

This will start an interactive session guiding you through the ISO building process.

### build-iso Command-line Mode

For non-interactive use, `build-iso` accepts the following options:

```
build-iso [options]

Options:
  -o, --org, --organization <name>  Configure GitHub organization (default: talesam)
  -a, --auto, --automatic           Use automatic configuration for ISO build
```

## Common Options

Both `build-package` and `build-iso` support these common options:

```
  -n, --nocolor                     Suppress color output
  -V, --version                     Print version information
  -h, --help                        Show help message
```

## Usage Examples

### Building a package interactively
```bash
cd /path/to/package/repo
build-package
```

### Building an AUR package from any directory
```bash
build-package
# Then select "Construir pacote do AUR" in the interactive menu
```

### Building a package with command-line options
```bash
build-package -o communitybig -c "Update package version" -b testing
```

### Building an ISO interactively
```bash
build-iso
```

### Building an ISO with automatic configuration
```bash
build-iso -a
```

## Troubleshooting

If you encounter issues:

1. Ensure you're in the correct directory when running `build-package` for non-AUR packages.
2. Check that the `GITHUB_TOKEN` is correctly set in `$HOME/.GITHUB_TOKEN`.
3. Verify your internet connection for GitHub API interactions.
4. Check the logs in `/tmp/<script_name>/<repo_name>/` for error messages.

For more detailed information on specific functions and advanced usage, refer to the inline comments in the script files.
