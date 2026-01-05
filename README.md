# MakeBind

Streamline and manage your Makefile workflows with modular ease and project-specific customization.

## Table of Contents
- [Introduction](#introduction)
- [Support](#support)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Upgrading Make](#upgrading-make)
  - [On Linux (Debian)](#on-linux-debian)
  - [On Mac](#on-mac)
- [Common Commands](#common-commands)
- [Module System](#module-system)
  - [What are Modules?](#what-are-modules)
  - [Module Structure](#module-structure)
  - [System vs Project Modules](#system-vs-project-modules)
- [Project Structure](#project-structure)
  - [The bind-hub Folder](#the-bind-hub-folder)
  - [Configuration Files](#configuration-files)
- [Debug Options](#debug-options)
- [Available Modules](#available-modules)

## Introduction

MakeBind is a Makefile project manager designed to simplify and customize your Makefile workflows. It provides a plugin/module system for GNU Make, allowing you to compose reusable Makefile functionality and manage project-specific build configurations.

## Support

MakeBind is supported on:
- Linux
- macOS

Windows users can use [WSL (Windows Subsystem for Linux)](https://learn.microsoft.com/en-us/windows/wsl/install).

If you encounter any issues, please [open an issue](https://github.com/AntonioCS/MakeBind/issues).

## Prerequisites

MakeBind requires the following tools to be installed on your system:
- `make` version 4.4 or higher

## Installation

Run this command in your project's root folder:

```shell
curl -s -o ./Makefile https://raw.githubusercontent.com/AntonioCS/MakeBind/main/templates/Makefile.tpl.mk && make
```

### What happens:
1. Downloads the Makefile template to your current directory
2. Runs `make`, which checks for MakeBind in the parent directory (`../MakeBind`)
3. If not found, downloads the latest release automatically
4. Creates a `bind-hub` folder with configuration files (`config.mk`, `project.mk`) and an `internal/` subfolder
5. Displays available targets - you're ready to use MakeBind!

### Custom installation path

By default, MakeBind looks in the parent directory. For better control, you can:
- Manually clone the repo to your preferred location
- Set the `MB_MAKEBIND_GLOBAL_PATH_ENV` environment variable

To set the environment variable permanently on Linux/macOS:
```shell
cat <<'EOF' >> ~/.profile

# MakeBind: global path env used by MakeBind tooling
export MB_MAKEBIND_GLOBAL_PATH_ENV="full/path/to/MakeBind"
EOF
```
This will ensure that the environment variable is set for every session.

## Upgrading Make

### On Linux (Debian)

Many Linux distributions ship with `make` 4.2.1 or 4.3. You'll need version 4.4+ for MakeBind.

> **Note:** This script requires admin privileges (sudo).

```shell
#!/bin/bash

export SELECTED_MAKE_VERSION="4.4.1"
sudo apt-get update
sudo apt-get install build-essential
cd /tmp
wget "https://ftp.gnu.org/gnu/make/make-${SELECTED_MAKE_VERSION}.tar.gz"
tar -xvzf "make-${SELECTED_MAKE_VERSION}.tar.gz"
cd "make-${SELECTED_MAKE_VERSION}"
./configure
make
sudo make install
```

This script will:
- Update your package list
- Install essential build packages for `make` compilation
- Navigate to the `/tmp` directory
- Download and extract the specified version of `make`
- Configure and install the new version

To run this, copy and paste to a file (for example `update_make.sh`), then do:
```shell
chmod +x update_make.sh && ./update_make.sh
```

You can find all available `make` versions at [GNU's FTP site](https://ftp.gnu.org/gnu/make/).
If version `4.4.1` is no longer the latest, update the `SELECTED_MAKE_VERSION` variable and re-run.

Verify the installation:
```shell
make --version
```

### On Mac

macOS ships with `make` 3.81, which is too old. Use Homebrew to install a newer version.

> **Prerequisites:** [Homebrew](https://docs.brew.sh/Installation) must be installed.
> If you're not using zsh, replace `~/.zshrc` with your shell's config file.

```bash
brew install make
echo 'export PATH="$HOMEBREW_PREFIX/opt/make/libexec/gnubin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

This will:
- Install `make` via Homebrew (installed as `gmake`)
- Add the GNU make binary to your PATH so `make` uses the new version
- Reload your shell configuration

Verify the installation:
```shell
make --version
```

#### Autocompletion on Mac

If you want to enable autocompletion, you can use the extension [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions).

## Common Commands

Here are the most commonly used commands in MakeBind:

| Command | Description |
|---------|-------------|
| `make` | List all available targets (default) |
| `make <target>` | Run a specific target |
| `make mb/modules/list` | List all available modules |
| `make mb/modules/add/<name>` | Add a module to your project |
| `make mb/modules/add/<name1>/<name2>` | Add multiple modules at once |
| `make mb/modules/remove/<name>` | Remove a module from your project |
| `make mb/help` | Get help on MakeBind |

## Module System

### What are Modules?

Modules are reusable packages of Makefile functionality. Instead of writing repetitive Makefile code for common tasks like Docker management, PHP tooling, or AWS operations, you can simply add the appropriate module and get access to pre-built targets.

For example, adding the `docker_compose` module gives you targets like:
- `dc/up` - Start containers
- `dc/down` - Stop containers
- `dc/logs` - View container logs

### Module Structure

Each module contains:
- `mod_info.mk` - Module metadata (name, version, dependencies)
- `<module>.mk` - Implementation with targets
- `mod_config.mk` - (Optional) Default configuration

For details on creating your own modules, see [modules/README.md](modules/README.md).

### System vs Project Modules

| Type | Location | Use Case |
|------|----------|----------|
| **System** | `modules/` (in MakeBind) | Reusable across all projects |
| **Project** | `bind-hub/modules/` | Specific to one project |

## Project Structure

### The bind-hub Folder

When you initialize MakeBind, it creates a `bind-hub` folder in your project with the following structure:

```
bind-hub/
├── config.mk           # Project configuration (commit this)
├── config.local.mk     # Local overrides (do NOT commit)
├── project.mk          # Project-specific targets (commit this)
├── project.local.mk    # Local target overrides (do NOT commit)
├── internal/           # Auto-generated files (do NOT edit)
│   └── modules.mk      # List of enabled modules
├── configs/            # Module configuration overrides
│   └── <module>_config.mk
└── modules/            # Project-specific custom modules
    └── <your_module>/
```

### Configuration Files

**config.mk** - Set configuration variables used by MakeBind and modules:
```makefile
mb_project_name := my-project
mb_project_path := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/..)
```

**config.local.mk** - Override settings for your local environment (gitignored):
```makefile
# Local overrides - do not commit
mb_debug := 1
```

**project.mk** - Add targets specific to your project:
```makefile
deploy: ## Deploy the application
    ./scripts/deploy.sh

test: ## Run tests
    ./scripts/test.sh
```

**project.local.mk** - Local target overrides (gitignored).

**configs/<module>_config.mk** - Override default module configuration:
```makefile
# Example: bind-hub/configs/docker_compose_config.mk
dc_file := docker/docker-compose.yml
dc_project_name := my-app
```

## Debug Options

When troubleshooting issues, you can enable various debug flags:

| Flag | Description |
|------|-------------|
| `mb_debug=1` | Enable general debugging output |
| `mb_debug_modules=1` | Debug module loading and discovery |
| `mb_debug_targets=1` | Debug target listing |
| `mb_debug_show_all_commands=1` | Show all shell commands being executed |

Usage:
```shell
make mb_debug=1
make mb_debug_modules=1 mb/modules/list
```

You can also set these in your `config.local.mk` for persistent debugging:
```makefile
mb_debug := 1
mb_debug_show_all_commands := 1
```

## Available Modules

MakeBind comes with modules organized by category:

| Category | Modules | Description |
|----------|---------|-------------|
| **Containers** | `docker`, `docker_compose` | Docker and Docker Compose management |
| **PHP** | `php`, `composer`, `phpunit`, `phpcs`, `phpstan`, `psalm` | PHP ecosystem tools |
| **PHP Frameworks** | `symfony`, `laravel` | Framework-specific targets |
| **Web Servers** | `nginx` | Web server management |
| **AWS** | `s3`, `sqs`, `sns`, `localstack` | AWS service integrations |
| **Infrastructure** | `terraform` | Infrastructure as Code |
| **Databases** | `postgresql` | Database management |
| **Project** | `project_builder` | Project scaffolding |

To see all available modules with descriptions:
```shell
make mb/modules/list
```

To add a module:
```shell
make mb/modules/add/docker_compose
```

Module dependencies are automatically resolved - if a module requires another module, it will be added automatically.
