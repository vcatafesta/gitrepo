# :pt_BR

:pt_BR

## :pt_BR

1. :pt_BR
2. :pt_BR
3. :pt_BR
   - :pt_BR
   - :pt_BR
4. :pt_BR
   - :pt_BR
   - :pt_BR
5. :pt_BR
6. :pt_BR
7. :pt_BR

## :pt_BR

:pt_BR

## :pt_BR

:pt_BR

- :pt_BR
- :pt_BR

:pt_BR

## :pt_BR

:pt_BR

### :pt_BR

:pt_BR

:pt_BR
```
build-package
```

:pt_BR

### :pt_BR

:pt_BR

```
build-package [options]

Options:
  -o, --org, --organization <name>  Configure GitHub organization (default: chililinux)
  -c, --commit <message>            Commit and push changes
  -b, --build <branch>              Commit, push, and generate package (testing, stable, or extra)
  -a, --aur <package>               Build an AUR package
```

## :pt_BR

:pt_BR

### :pt_BR

:pt_BR
```
build-iso
```

:pt_BR

### :pt_BR

:pt_BR

```
build-iso [options]

Options:
  -o, --org, --organization <name>  Configure GitHub organization (default: talesam)
  -a, --auto, --automatic           Use automatic configuration for ISO build
```

## :pt_BR

:pt_BR

```
  -n, --nocolor                     Suppress color output
  -V, --version                     Print version information
  -h, --help                        Show help message
```

## :pt_BR

### :pt_BR
```bash
cd /path/to/package/repo
build-package
```

### :pt_BR
```bash
build-package
# Then select "Construir pacote do AUR" in the interactive menu
```

### :pt_BR
```bash
build-package -o chiililinux -c "Update package version" -b testing
```

### :pt_BR
```bash
build-iso
```

### :pt_BR
```bash
build-iso -a
```

## :pt_BR

:pt_BR

1. :pt_BR
2. :pt_BR
3. :pt_BR
4. :pt_BR

:pt_BR
