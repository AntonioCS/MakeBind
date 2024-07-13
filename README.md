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

To install MakeBind, run the appropriate command for your operating system in your terminal:

### Linux and macOS:
```bash
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
- You will be prompted to create missing important files, which are the `mb_config.mk` and `mb_project.mk`. Just say `y` and press `Enter`. A `bind-hub` folder will be created where these files will reside.
- Afterward, you will see a list of available targets, and you can start using MakeBind.

## Usage
MakeBind is designed to be simple to use and easy to configure. Here are some common commands you can use with MakeBind:
- `make`
  The simplest way to run the default target which will just list all the available targets.
- `make <target>`
  Run a specific target.

## Configuration
As mentioned, when you run MakeBind for the first time, you will be prompted to create the `mb_config.mk` and `mb_project.mk` files. These files are used to configure MakeBind for your project.
- In `mb_config.mk`, you can set all variables that are used by MakeBind modules. You can create a local version named `mb_config.local.mk` to override the default values (do not commit this file to your repository).
- In `mb_project.mk`, you can add all targets that are specific to your project. You can create a local version named `mb_project.local.mk` to override the default values (do not commit this file to your repository).
- In the `bind-hub` folder, you can add all your custom modules in `bind-hub/modules`.




## Upgrading Make

### On Linux (Debian)

Many Linux distributions come with `make` versions 4.2.1 or 4.3. We need to upgrade to the latest version.
The following script will install the latest version (specified in `SELECTED_MAKE_VERSION`):

```shell
#!/bin/bash
export SELECTED_MAKE_VERSION="4.4.1" && \
sudo apt-get update && \
sudo apt-get install build-essential && \
cd /tmp && \
wget "https://ftp.gnu.org/gnu/make/make-${SELECTED_MAKE_VERSION}.tar.gz" && \
tar -xvzf "make-${SELECTED_MAKE_VERSION}.tar.gz" && \
cd "make-${SELECTED_MAKE_VERSION}" && \
./configure && \
make && \
sudo make install
make --version
```

This script will:
- Update your package list
- Install essential build packages for `make` compilation
- Navigate to the `/tmp` directory
- Download and extract the specified version of `make`
- Configure and install the new version
- Confirm the installation

<ADD link to automatically run this script, the code will have to be somewhere.. maybe a gist or just a file here>

You can find all available `make` versions at [GNU's FTP site](https://ftp.gnu.org/gnu/make/).  
If version `4.4.1` is no longer the latest, simply update the `SELECTED_MAKE_VERSION` variable in the script and re-run it.


### On Mac

The default installed version of `make` on Mac is 3.81, which is outdated.  
To upgrade your `make` version, we will use `homebrew`.  
If you do not have `homebrew`, you can find the installation instructions [here](https://docs.brew.sh/Installation).

If you are not using `Z shell`, replace `~/.zshrc` with the path to the appropriate configuration file for your shell.

To upgrade run the following script:
```bash
#!/bin/bash

brew install make
echo -e 'export PATH="$HOMEBREW_PREFIX/opt/make/libexec/gnubin:$PATH"' | cat - ~/.zshrc > temp && mv temp ~/.zshrc
source ~/.zshrc
make -v
```
This script will:
- Install `make` using Homebrew:
- Add the new `make` path to your shell configuration file: 
  - This command adds the new path to the top of your `~/.zshrc` file.
  - Note: `$HOMEBREW_PREFIX` is an environment variable set during the installation of Homebrew. You can verify it using `echo $HOMEBREW_PREFIX`.
- Reload your shell configuration:
- Confirm the installation
  
This process should upgrade `make` to a more recent version.

