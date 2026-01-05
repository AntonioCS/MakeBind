# MakeBind Core

This folder contains the core functionality of MakeBind. These files are loaded automatically and provide the foundation for the module system.

## Core Files

| File | Description |
|------|-------------|
| `functions.mk` | Core utility functions (`mb_invoke`, `mb_shell_capture`, `mb_user_confirm`, etc.) |
| `modules_manager.mk` | Module discovery, loading, and dependency resolution |
| `targets.mk` | Target listing and help system (`mb/targets-list`, `mb/help`) |
| `util.mk` | Loads all utility files from `util/` |
| `init_project.mk` | Project initialization (creates `bind-hub` folder) |
| `deprecation.mk` | Handles deprecated function warnings |

## Utility Files (util/)

| File | Description |
|------|-------------|
| `variables.mk` | Common constants (`mb_true`, `mb_false`, `mb_on`, `mb_off`, `mb_empty`) |
| `colours.mk` | Terminal color output helpers |
| `os_detection.mk` | Cross-platform OS detection (`mb_os_is_linux`, `mb_os_is_mac`, `mb_os_is_windows`) |
| `cache.mk` | File-based caching system with TTL support |
| `debug.mk` | Debug output utilities |
| `git.mk` | Git utilities (`mb_staged_files`, etc.) |

## Loading Order

Understanding the loading order is important when extending MakeBind:

1. `Makefile` includes `main.mk`
2. `main.mk` loads project config (`config.mk`, `config.local.mk`)
3. Core utilities loaded (`util.mk` → all util files)
4. Core functions loaded (`functions.mk`)
5. Module database built (`modules_manager.mk` → `mb_modules_build_db`)
6. Enabled modules loaded (`mb_load_modules`)
7. Project targets loaded (`project.mk`, `project.local.mk`)

## Key Functions

### Command Execution

```makefile
# Execute a command with logging
$(call mb_invoke,docker compose up -d)

# Execute and capture output
$(call mb_shell_capture,echo hello,result_var)

# Execute with exit code capture
$(call mb_shell_capture_with_exitcode,command,output_var,exitcode_var)
```

### User Interaction

```makefile
# Prompt for confirmation (y/n)
$(call mb_user_confirm,Are you sure?)

# Print formatted messages
$(call mb_printf_info,This is an info message)
$(call mb_printf_warning,This is a warning)
$(call mb_printf_error,This is an error)
$(call mb_printf_success,This is a success message)
```

### File Operations

```makefile
# Check if file/directory exists
$(call mb_exists,/path/to/file)
$(call mb_not_exists,/path/to/file)

# Check if value is a URL
$(call mb_is_url,https://example.com)
```

### OS Detection

```makefile
# Check operating system
$(if $(mb_os_is_linux),Linux-specific code)
$(if $(mb_os_is_mac),macOS-specific code)
$(if $(mb_os_is_windows),Windows-specific code)

# Run OS-specific command
$(call mb_os_call,windows_cmd,unix_cmd)
```

### Caching

```makefile
# Read from cache (sets variable if cache hit)
$(call mb_cache_read,my_cache_key,result_var)

# Write to cache with TTL (seconds)
$(call mb_cache_write,my_cache_key,$(value),3600)
```

### Module Management

```makefile
# Check if module is loaded
$(if $(call mb_module_is_loaded,docker_compose),Module is loaded)

# Get module path
$(call mb_module_get_path,docker_compose)
```

## Variables

### Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `mb_debug` | `0` | Enable debug output |
| `mb_invoke_print` | `1` | Print commands before execution |
| `mb_invoke_dry_run` | `0` | Don't execute, just print |
| `mb_invoke_silent` | `0` | Suppress all output |

### Constants (util/variables.mk)

| Variable | Value | Description |
|----------|-------|-------------|
| `mb_true` | `1` | Boolean true |
| `mb_false` | `0` | Boolean false |
| `mb_on` | `1` | Alias for true |
| `mb_off` | `0` | Alias for false |
| `mb_empty` | `` | Empty string |

## Make Flags

MakeBind sets these MAKEFLAGS:

| Flag | Purpose |
|------|---------|
| `--always-make` | Targets always rebuild (`.PHONY` is redundant) |
| `--warn-undefined-variables` | Catch undefined variable usage |
| `--no-builtin-rules` | Clean slate, no implicit rules |
| `--no-builtin-variables` | No predefined variables |
| `--no-print-directory` | Suppress directory change messages |
| `--silent` | Quiet mode (unless `mb_debug_no_silence=1`) |

## Shell Configuration

```makefile
SHELL := /bin/bash
.SHELLFLAGS := -euco pipefail  # -x added when mb_debug_show_all_commands=1
.ONESHELL:                      # Multi-line recipes run in single shell
```

## Adding Core Functionality

If you need to extend core functionality:

1. **For project-specific functions:** Add to `bind-hub/project.mk`
2. **For reusable functions:** Create a module in `modules/` or `bind-hub/modules/`
3. **For MakeBind core changes:** Submit a PR to the repository

Do not modify core files directly in your projects - they will be overwritten on updates.
