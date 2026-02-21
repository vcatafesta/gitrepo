# GitRepo 문서

GitRepo는 Chililinux 프로젝트의 패키지 빌드 및 ISO 생성을 관리하기 위해 설계된 포괄적인 도구입니다. 이는 `build-package`와 `build-iso`라는 두 가지 주요 구성 요소로 구성됩니다.

## 목차

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

## 개요

GitRepo는 Chililinux 프로젝트용 패키지 및 ISO 구축 프로세스를 단순화합니다. 대화형 인터페이스와 명령줄 인터페이스를 모두 제공하므로 다양한 개발 시나리오에서 유연성을 발휘할 수 있습니다.

## 설치

GitRepo 도구는 일반적으로 다음 위치에 설치됩니다.

- 공용 라이브러리(`gitlib.sh`): `/usr/share/chililinux/gitrepo/shell/gitlib.sh`
- 실행 가능한 스크립트(`build-package`, `build-iso`): `/usr/bin/`

이러한 위치가 시스템의 PATH에 있는지 확인하십시오.

## 빌드 패키지

`build-package`는 패키지 빌드를 관리하는 데 사용됩니다. 두 가지 모드로 실행할 수 있습니다.

### 빌드-패키지 대화형 모드

대화형 모드를 사용하려면 AUR이 아닌 패키지의 복제된 저장소 디렉터리로 이동합니다. AUR 패키지의 경우 모든 디렉터리에서 실행할 수 있습니다.

달리다:
```
build-package
```

그러면 패키지 구축 프로세스를 안내하는 대화형 세션이 시작됩니다.

### 빌드 패키지 명령줄 모드

비대화형 사용의 경우 `build-package`는 다음 옵션을 허용합니다.

```
build-package [options]

Options:
  -o, --org, --organization <name>  Configure GitHub organization (default: chililinux)
  -c, --commit <message>            Commit and push changes
  -b, --build <branch>              Commit, push, and generate package (testing, stable, or extra)
  -a, --aur <package>               Build an AUR package
```

## 빌드 ISO

`build-iso`는 ISO 이미지를 만드는 데 사용됩니다. `build-package`와 마찬가지로 두 가지 모드로 실행될 수 있습니다.

### build-iso 대화형 모드

달리다:
```
build-iso
```

그러면 ISO 구축 과정을 안내하는 대화형 세션이 시작됩니다.

### build-iso 명령줄 모드

비대화형 사용의 경우 `build-iso`는 다음 옵션을 허용합니다:

```
build-iso [options]

Options:
  -o, --org, --organization <name>  Configure GitHub organization (default: talesam)
  -a, --auto, --automatic           Use automatic configuration for ISO build
```

## 공통 옵션

`build-package`와 `build-iso`는 모두 다음과 같은 일반적인 옵션을 지원합니다.

```
  -n, --nocolor                     Suppress color output
  -V, --version                     Print version information
  -h, --help                        Show help message
```

## 사용 예

### 대화형으로 패키지 빌드
```bash
cd /path/to/package/repo
build-package
```

### 모든 디렉터리에서 AUR 패키지 빌드
```bash
build-package
# Then select "Construir pacote do AUR" in the interactive menu
```

### 명령줄 옵션을 사용하여 패키지 빌드
```bash
build-package -o chiililinux -c "Update package version" -b testing
```

### ISO를 대화형으로 구축하기
```bash
build-iso
```

### 자동 구성으로 ISO 구축
```bash
build-iso -a
```

## 문제 해결

문제가 발생하는 경우:

1. AUR이 아닌 패키지에 대해 `build-package`를 실행할 때 올바른 디렉터리에 있는지 확인하세요.
2. `$HOME/.GITHUB_TOKEN`에 `GITHUB_TOKEN`이 올바르게 설정되어 있는지 확인하세요.
3. GitHub API 상호 작용을 위해 인터넷 연결을 확인하세요.
4. 오류 메시지는 `/tmp/<script_name>/<repo_name>/`의 로그를 확인하세요.

특정 기능 및 고급 사용법에 대한 자세한 내용은 스크립트 파일의 인라인 주석을 참조하세요.
