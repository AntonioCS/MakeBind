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