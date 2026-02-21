# Documentación de GitRepo

GitRepo es una herramienta integral diseñada para gestionar la compilación de paquetes y la creación de ISO para el proyecto Chililinux. Consta de dos componentes principales: "build-package" y "build-iso".

## Tabla de contenido

1. CHILE_REF_0_CHILI
2. CHILE_REF_0_CHILI
3. CHILE_REF_0_CHILI
   - CHILE_REF_0_CHILI
   - CHILE_REF_0_CHILI
4. CHILE_REF_0_CHILI
   - CHILE_REF_0_CHILI
   - CHILE_REF_0_CHILI
5. CHILE_REF_0_CHILI
6. CHILE_REF_0_CHILI
7. CHILE_REF_0_CHILI

## Descripción general

GitRepo simplifica el proceso de creación de paquetes e ISO para el proyecto Chililinux. Ofrece interfaces interactivas y de línea de comandos, lo que permite flexibilidad en varios escenarios de desarrollo.

## Instalación

Las herramientas GitRepo normalmente se instalan en las siguientes ubicaciones:

- Biblioteca común (`gitlib.sh`): `/usr/share/chililinux/gitrepo/shell/gitlib.sh`
- Scripts ejecutables (`build-package`, `build-iso`): `/usr/bin/`

Asegúrese de que estas ubicaciones estén en la RUTA de su sistema.

## paquete de construcción

`build-package` se utiliza para gestionar compilaciones de paquetes. Se puede ejecutar en dos modos:

### Modo interactivo del paquete de compilación

Para utilizar el modo interactivo, navegue hasta el directorio del repositorio clonado para paquetes que no sean AUR. Para los paquetes AUR, se puede ejecutar desde cualquier directorio.

Correr:
```
build-package
```

Esto iniciará una sesión interactiva que lo guiará a través del proceso de creación del paquete.

### Modo de línea de comandos de paquete de compilación

Para uso no interactivo, `build-package` acepta las siguientes opciones:

```
build-package [options]

Options:
  -o, --org, --organization <name>  Configure GitHub organization (default: chililinux)
  -c, --commit <message>            Commit and push changes
  -b, --build <branch>              Commit, push, and generate package (testing, stable, or extra)
  -a, --aur <package>               Build an AUR package
```

## construir-iso

`build-iso` se utiliza para crear imágenes ISO. Al igual que "build-package", se puede ejecutar en dos modos:

### Modo interactivo build-iso

Correr:
```
build-iso
```

Esto iniciará una sesión interactiva que lo guiará a través del proceso de creación de ISO.

### Modo de línea de comandos build-iso

Para uso no interactivo, `build-iso` acepta las siguientes opciones:

```
build-iso [options]

Options:
  -o, --org, --organization <name>  Configure GitHub organization (default: talesam)
  -a, --auto, --automatic           Use automatic configuration for ISO build
```

## Opciones comunes

Tanto `build-package` como `build-iso` admiten estas opciones comunes:

```
  -n, --nocolor                     Suppress color output
  -V, --version                     Print version information
  -h, --help                        Show help message
```

## Ejemplos de uso

### Construyendo un paquete de forma interactiva
```bash
cd /path/to/package/repo
build-package
```

### Construyendo un paquete AUR desde cualquier directorio
```bash
build-package
# Then select "Construir pacote do AUR" in the interactive menu
```

### Construyendo un paquete con opciones de línea de comandos
```bash
build-package -o chiililinux -c "Update package version" -b testing
```

### Construyendo una ISO de forma interactiva
```bash
build-iso
```

### Construyendo una ISO con configuración automática
```bash
build-iso -a
```

## Solución de problemas

Si tiene problemas:

1. Asegúrese de estar en el directorio correcto cuando ejecute `build-package` para paquetes que no sean AUR.
2. Verifique que `GITHUB_TOKEN` esté configurado correctamente en `$HOME/.GITHUB_TOKEN`.
3. Verifique su conexión a Internet para interacciones con la API de GitHub.
4. Verifique los registros en `/tmp/<script_name>/<repo_name>/` para ver si hay mensajes de error.

Para obtener información más detallada sobre funciones específicas y uso avanzado, consulte los comentarios en línea en los archivos de script.
