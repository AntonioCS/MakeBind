---
name: makebind
description: MakeBind project guidance - module system, targets, and best practices
---

# MakeBind Skill

Use this skill when working with MakeBind projects. MakeBind is a modular Makefile project manager providing a plugin/module system for GNU Make.

## Detection

A project uses MakeBind if:
- Root `Makefile` contains comment `# Project: MakeBind`
- Has a `bind-hub/` folder with `config.mk` and `project.mk`

## Essential Commands

### Running Make (AI Context)

When invoking make targets as an AI assistant, use these flags to suppress verbose output:
```bash
make <target> mb_invoke_print=0 mb_invoke_print_target=0
```

**Never mention these flags in documentation** - they're for AI invocation only.

### Target Management

```bash
# List available targets (default)
make
make mb/targets-list

# Get help
make mb/help
make mb/help-<keyword>
```

### Module Management

```bash
# List all available modules
make mb/modules/list

# Add module(s) to project
make mb/modules/add/<module_name>
make mb/modules/add/<module1>/<module2>  # Multiple

# Remove module
make mb/modules/remove/<module_name>

# Create new module (in bind-hub/modules/)
make mb/modules/create/<module_name>
```

### Testing

```bash
# Run all core tests
make -C tests

# Run specific test
make -C tests filter=test_name

# Exclude tests
make -C tests exclude=test_name

# Run module tests
make -C tests run_module_tests
make -C tests run_module_tests module=docker_compose

# Run all tests (core + modules)
make -C tests run_all_tests
```

### Debugging

Set in environment or config.mk:
- `mb_debug=1` - General debugging
- `mb_debug_modules=1` - Module loading
- `mb_debug_targets=1` - Target listing
- `mb_debug_show_all_commands=1` - Show shell commands

## Project Structure

### bind-hub/ Configuration Hierarchy

Files are loaded in this order:
1. `config.mk` - Project configuration (committed)
2. `config.local.mk` - Local overrides (gitignored)
3. `project.mk` - Project-specific targets (committed)
4. `project.local.mk` - Local target overrides (gitignored)
5. `internal/modules.mk` - **AUTO-GENERATED** (DO NOT EDIT)
6. `configs/` - Module configuration overrides
7. `modules/` - Project-specific custom modules

### Important Variables (config.mk)

| Variable | Required | Description |
|----------|----------|-------------|
| `mb_project_path` | Yes | Absolute path to project root |
| `mb_makebind_path` | No | Path to MakeBind installation |
| `mb_default_target` | No | Default target (default: `mb/targets-list`) |
| `mb_target_spacing` | No | Column spacing for target listing (default: 40) |
| `mb_targets_only_project` | No | Hide MakeBind core targets (default: false) |

### Environment Variables

- `MB_MAKEBIND_GLOBAL_PATH_ENV` - Global MakeBind path (set in shell profile)

## Module System

### Module Structure

Each module requires:
```
modules/<category>/<module_name>/
├── mod_info.mk      # Metadata (required)
├── <module_name>.mk # Implementation (required)
└── mod_config.mk    # Configuration defaults (optional)
```

### mod_info.mk Format

```makefile
mb_module_name := mymodule
mb_module_version := 1.0.0
mb_module_description := My custom module
mb_module_depends := # Space-separated dependencies
mb_module_filename := # Optional custom .mk filename
```

### Module Implementation Pattern

```makefile
# modules/mymodule/mymodule.mk
ifndef __MB_MODULES_MYMODULE__
__MB_MODULES_MYMODULE__ := 1

mymodule/target: ## Description shown in target list
    $(call mb_printf_info,Running mymodule target)

mymodule/another: ## Another target
    $(call mb_invoke,some-command)

endif
```

### Module Discovery

- System modules: `modules/` (searched recursively)
- Project modules: `bind-hub/modules/` (searched recursively)

## Writing Targets

### Target with Description

```makefile
my-target: ## This description appears in `make`
    $(call mb_invoke,command here)
```

Use `##` (double hash) for the description to appear in target listings.

### Using mb_invoke

```makefile
target:
    $(call mb_invoke,docker compose up -d)
```

Control variables:
- `mb_invoke_print` - Show command before execution
- `mb_invoke_dry_run` - Print without executing
- `mb_invoke_run_in_shell` - Capture output/exit code

### OS-Specific Commands

```makefile
$(call mb_os_call,<linux_command>,<mac_command>)
```

Check OS: `mb_os_is_linux`, `mb_os_is_osx`, `mb_os_is_linux_or_osx`

## Core Utility Functions

### File Operations
- `mb_exists` / `mb_not_exists` - Check file existence
- `mb_is_url` - Validate URL format
- `mb_timestamp` - Current Unix timestamp

### Output Functions
- `mb_printf_info` - Blue info message
- `mb_printf_warn` - Yellow warning
- `mb_printf_error` - Red error (exits)
- `mb_printf_success` - Green success

### User Interaction
- `mb_user_confirm` - Yes/No prompt
- `mb_shell_capture` - Capture command output

### Caching
```makefile
$(call mb_cache_read,<key>,<output_var>)
$(call mb_cache_write,<key>,<value>,<ttl_seconds>)
```

## Make Behavior (main.mk)

MakeBind sets these Make behaviors - understand them before writing code:

### MAKEFLAGS
- `--always-make` - All targets rebuild (`.PHONY` is redundant)
- `--warn-undefined-variables` - Guard variable access
- `--no-builtin-rules` / `--no-builtin-variables` - Clean slate
- `--silent` - Quiet mode (unless `mb_debug_no_silence=1`)

### Shell Configuration
- `SHELL := /bin/bash`
- `.SHELLFLAGS := -euco pipefail` (strict error handling)
- Add `-x` when `mb_debug_show_all_commands=1`

### Special Directives
- `.ONESHELL:` - Multi-line recipes in single shell
- `.POSIX:` - POSIX compliance
- `.SECONDEXPANSION:` - Enables `$$@` in prerequisites

## Common Pitfalls

### 1. Variable Assignment
- `:=` for immediate assignment (evaluated once)
- `=` for deferred assignment (evaluated each use)

### 2. Function Calls
```makefile
# Correct
$(call func,arg1,arg2)

# Wrong
$(func arg1 arg2)
```

### 3. Include Guards
Always use unique include guards:
```makefile
ifndef __MB_MODULES_MYMODULE__
__MB_MODULES_MYMODULE__ := 1
# ... content ...
endif
```

### 4. Comments in define Blocks
`##` inside `define...endef` becomes literal output, NOT comments.
```makefile
# Wrong - this prints "## Comment"
define my_var
## Comment
endef

# Use comments OUTSIDE define blocks
```

### 5. Guard Undefined Variables
With `--warn-undefined-variables`, guard access:
```makefile
$(if $(value VAR),$(VAR),default)
```

### 6. Circular Dependencies
Module dependencies are not cycle-detected. Avoid circular `mb_module_depends`.

## Function Argument Convention

Use `$0_arg<N>_<name>` pattern:

```makefile
## @function my_function
## @arg 1: command (required)
## @arg 2: prefix (required)
## @arg 3: shell (optional)
define my_function
$(strip
    $(eval $0_arg1_cmd := $(if $(value 1),$(strip $1),$(call mb_printf_error,$0: command required)))
    $(eval $0_arg2_prefix := $(if $(value 2),$(strip $2),$(call mb_printf_error,$0: prefix required)))
    $(eval $0_arg3_shell := $(if $(value 3),$(strip $3),/bin/sh))
)
endef
```

## Writing Tests

Tests use `tests/make_testing.mk`:

```makefile
define test_my_feature
    $(call mb_assert,<condition>,<error_message>)
    $(call mb_assert_eq,<expected>,<actual>,<error_message>)
    $(call mb_assert_neq,<not_expected>,<actual>,<error_message>)
endef
```

Tests are discovered by `test_` prefix.

## Code Style

- Prefix internal variables with `mb_` or function name (`$0_var`)
- Tabs for recipes, spaces for variable definitions
- Keep lines under 120 characters
- Use descriptive function/variable names
- Document complex functions with comment headers

### `$(if)` Formatting

**Never write `$(if)` as one-liners.** Use multi-line format:

```makefile
## Correct
$(if $(call mb_not_exists,$(path)),\
    $(error Path not found)\
)

## Wrong
$(if $(call mb_not_exists,$(path)),$(error Path not found))
```

**Exception:** Simple variable assignments can use inline `$(if)`:
```makefile
$0_arg := $(if $(value 1),$(strip $1),default)
```

### Define Blocks

Always wrap `define` content in `$(strip ...)`:

```makefile
define my_function
$(strip
    $(eval $0_arg1 := ...)
    ...
)
endef
```

### File Headers

Every `.mk` file needs this header:

```makefile
#####################################################################################
# Project: MakeBind
# File: <path>
# Description: <Brief description>
# Author: <Author>
# License: MIT License
#####################################################################################
```

### Debug Logging

```makefile
$(call mb_debug_print,Message,$(mb_debug_modules))
```

### Nested Includes

```makefile
__mb_mymod_dir := $(dir $(lastword $(MAKEFILE_LIST)))
include $(__mb_mymod_dir)functions.mk
```

## Available Modules

| Category | Modules |
|----------|---------|
| `php/` | php, composer, phpunit |
| `php/frameworks/` | symfony, laravel |
| `containers/` | docker, docker_compose |
| `webservers/` | nginx |
| `cloud_providers/aws/` | s3, sqs, sns |
| `project_builder/` | project scaffolding |

## Quick Reference

| Action | Command |
|--------|---------|
| List targets | `make` |
| Add module | `make mb/modules/add/<name>` |
| Create module | `make mb/modules/create/<name>` |
| List modules | `make mb/modules/list` |
| Run tests | `make -C tests` |
| Debug mode | `make mb_debug=1 <target>` |
