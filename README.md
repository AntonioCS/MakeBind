# MakeBind

Streamline and manage your Makefile workflows with modular ease and project-specific customization.

*This README is a work in progress (WIP).*

## Table of Contents
- [Introduction](#introduction)
- [Support](#support)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [Upgrading Make](#upgrading-Make)
    - [On Linux (Debian)](#on-linux-debian)
    - [On Mac](#on-mac)
        - [Autocompletion on Mac](#autocompletion-on-mac)

## Introduction
MakeBind is a Makefile project manager designed to simplify and customize your Makefile workflows. It allows you to manage projects and create modular Makefiles with ease.

## Support
MakeBind is supported on the following operating systems:
- Linux
- macOS
- Windows (not fully tested and still a work in progress)

If you encounter any issues on any of the platforms, please open an issue.

## Prerequisites
MakeBind requires the following tools to be installed on your system:
- `make` version 4.4 or higher

## Installation

To install MakeBind, run the appropriate command for your operating system in your terminal in the root folder of you project:

### Linux and macOS:
```shell
curl -s -o ./Makefile https://raw.githubusercontent.com/AntonioCS/MakeBind/main/templates/Makefile.tpl.mk && make
```

### Windows:
```powershell
powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/AntonioCS/MakeBind/main/templates/Makefile.tpl.mk' -OutFile './Makefile'; & make"
```

### Explanation:
- This command downloads the Makefile template and creates a Makefile in your current directory.
- `make` will then automatically execute and check for the existence of the `MakeBind` folder in the path specified by `mb_mb_default_path` (default is `../MakeBind`, meaning it will search in the parent directory).
- If the `MakeBind` folder does not exist, the latest release will be downloaded.
- The folder `bind-hub` will be created in the current directory, which contains important configuration files, which are the `mb_config.mk` and `mb_project.mk` and a few other files and folders.
- You will then see a list of available targets, and you can start using MakeBind.

NOTE: if you want better control of where MakeBind is installed, you can either manually clone the repo or download from Github.
But you can also specify `MB_MAKEBIND_GLOBAL_PATH_ENV` and set that to the path you want.
On Linux and macOS, you can do this by running:
```shell
cat <<'EOF' >> ~/.profile

# MakeBind: global path env used by MakeBind tooling
export MB_MAKEBIND_GLOBAL_PATH_ENV="full/path/to/MakeBind"
EOF
``` 
This will ensure that the environment variable is set for every session.

## Usage
MakeBind is designed to be simple to use and easy to configure. Here are some common commands you can use with MakeBind:
- `make`
  The simplest way to run the default target which will just list all the available targets.
- `make <target>`
  Run a specific target.

## Configuration
As mentioned, when you run MakeBind for the first time, it will create the `mb_config.mk` and `mb_project.mk` files in the folder `bind-hub`. These files are used to configure MakeBind for your project.
- In `mb_config.mk`, you can set all configuration variables that are used by MakeBind modules or your own modules. You can create a local version named `mb_config.local.mk` to override the default values (do not commit this file to your repository).
- In `mb_project.mk`, you can add all targets that are specific to your project. You can create a local version named `mb_project.local.mk` to override the default values (do not commit this file to your repository).
- In the `bind-hub` folder, you can add all your custom modules in `bind-hub/modules`.

## Upgrading Make

### On Linux (Debian)

Many Linux distributions come with `make` versions 4.2.1 or 4.3. We need to upgrade to the latest version.
The following script will install the latest version (specified in `SELECTED_MAKE_VERSION`):

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

The above script will require admin privileges.  
The script will:
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
If version `4.4.1` is no longer the latest, simply update the `SELECTED_MAKE_VERSION` variable in the script and re-run it.  
Confirm that everything has been installed by doing `make --version` and checking that the version match the one specified in `SELECTED_MAKE_VERSION`. 

### On Mac

The default installed version of `make` on Mac is 3.81, which is outdated.  
To upgrade your `make` version, we will use `homebrew`. 
If you do not have `homebrew`, you can find the installation instructions [here](https://docs.brew.sh/Installation).  
This is the package page: https://formulae.brew.sh/formula/make  
If you are not using `Z shell`, replace `~/.zshrc` with the path to the appropriate configuration file for your shell.

To upgrade run the following script:
```bash
#!/bin/sh

brew install make
echo 'export PATH="$HOMEBREW_PREFIX/opt/make/libexec/gnubin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

To run this, copy and paste to a file (for example `update_make.sh`), then do:
```shell
chmod +x update_make.sh && ./update_make.sh
```

This script will:
- Install `make` using Homebrew.
- Add the `gnubin` path to your shell configuration file: 
  - This command adds the new path to the top of your `~/.zshrc` file.
  - Note: `$HOMEBREW_PREFIX` is an environment variable set during the installation of Homebrew. You can verify it using `echo $HOMEBREW_PREFIX`.
  - This is needed to ensure that `make` is available as `brew` installs `make` as `gmake`.
- Reload your shell configuration:
  
This process should upgrade `make` to a more recent version.  
Run `make --version` and confirm that the version is the latest one.

#### Autocompletion on Mac

If you want to enable autocompletion, you can use the extension [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions).

