# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MakeBind is a modular Makefile project manager that simplifies and customizes Makefile workflows. It provides a plugin/module system for GNU Make, allowing users to compose reusable Makefile functionality and manage project-specific build configurations.

**Key Requirement**: GNU Make 4.4 or higher is required.

## Development Commands

### Running Tests
```bash
# Run all core tests
make -C tests

# Run specific test
make -C tests filter=test_name

# Exclude specific tests
make -C tests exclude=test_name

# Run module tests only
make -C tests run_module_tests

# Run specific module tests
make -C tests run_module_tests module=docker_compose

# Run all tests (core + modules)
make -C tests run_all_tests
```

### Module Management
```bash
# List all available modules
make mb/modules/list

# Add module(s) to project
make mb/modules/add/<module_name>
make mb/modules/add/<module1>/<module2>  # Add multiple

# Remove module from project
make mb/modules/remove/<module_name>

# Create new module
make mb/modules/create/<module_name>
```

### Target Management
```bash
# List all available targets (default)
make
make mb/targets-list

# Get help on specific topic
make mb/help
make mb/help-<keyword>
```

### Debugging
Set debug flags in your environment or config.mk:
- `mb_debug=1` - Enable general debugging
- `mb_debug_modules=1` - Debug module loading
- `mb_debug_targets=1` - Debug target listing
- `mb_debug_show_all_commands=1` - Show all shell commands

## Architecture

### Core System Structure

**Entry Points**:
- `main.mk` - Main entry point that orchestrates the entire system
- `Makefile.tpl.mk` (template) - Project-level Makefile that references main.mk

**Core Components** (in `core/`):
1. **modules_manager.mk** - Module discovery, loading, and dependency resolution
2. **functions.mk** - Core utility functions (mb_invoke, mb_shell_capture, mb_user_confirm)
3. **targets.mk** - Target listing and help system
4. **util.mk** - Utility functions and helper includes
5. **init_project.mk** - Project initialization when bind-hub folder is missing

**Utility Components** (in `core/util/`):
- `os_detection.mk` - Cross-platform OS detection (Linux/macOS/Windows)
- `colours.mk` - Terminal color output helpers
- `cache.mk` - File-based caching system with TTL support
- `debug.mk` - Debug output utilities
- `variables.mk` - Common variable definitions (mb_true, mb_false, mb_on, mb_off, etc.)

### Module System

**Module Structure**: Each module must have:
- `mod_info.mk` - Metadata file defining:
  - `mb_module_name` - Module identifier
  - `mb_module_version` - Version string
  - `mb_module_description` - Human-readable description
  - `mb_module_depends` - Space-separated list of dependency modules
  - `mb_module_filename` (optional) - Custom .mk filename (defaults to `<module_name>.mk`)
- `<module_name>.mk` - Implementation file with actual targets/functions
- `mod_config.mk` (optional) - Module configuration variables

**Module Discovery**:
- System modules: `modules/` directory (searched recursively)
- Project modules: `bind-hub/modules/` directory (searched recursively)
- Database built at startup by `mb_modules_build_db` function

**Module Loading Process**:
1. Build module database from all mod_info.mk files
2. Read `bind-hub/internal/modules.mk` for enabled modules
3. For each enabled module:
   - Load module's `mod_config.mk` (if exists)
   - Load project override: `bind-hub/configs/<module>_config.mk` (if exists)
   - Load module implementation file
4. Dependencies are automatically loaded when adding modules

**Available Modules** (in `modules/`):
- `php/` - PHP ecosystem (php, composer, phpunit)
- `php/frameworks/` - Framework support (symfony, laravel)
- `containers/` - Container tools (docker, docker_compose)
- `webservers/` - Web servers (nginx)
- `cloud_providers/aws/` - AWS services (s3, sqs, sns)
- `project_builder/` - Project scaffolding

### Project Configuration

**Configuration Hierarchy** (bind-hub folder):
1. `config.mk` - Project configuration (committed)
2. `config.local.mk` - Local overrides (gitignored)
3. `project.mk` - Project-specific targets (committed)
4. `project.local.mk` - Local target overrides (gitignored)
5. `internal/modules.mk` - Auto-generated list of enabled modules (DO NOT EDIT)
6. `configs/` - Module configuration overrides (created on-demand)
7. `modules/` - Project-specific custom modules (created on-demand)

**Important Variables** (in config.mk):
- `mb_project_path` - Absolute path to project root (REQUIRED)
- `mb_makebind_path` - Path to MakeBind installation
- `mb_default_target` - Default target (default: mb/targets-list)
- `mb_target_spacing` - Column spacing for target listing (default: 40)
- `mb_targets_only_project` - Show only project/module targets, hide MakeBind core (default: false)

**Environment Variables**:
- `MB_MAKEBIND_GLOBAL_PATH_ENV` - Global path to MakeBind installation. Set this in your shell profile (e.g., `.bashrc`) to avoid hardcoding the path in each project's Makefile.

### Loading Order

Understanding the load order is critical:
1. `Makefile` includes `main.mk`
2. `main.mk` loads `config.mk` and `config.local.mk`
3. Core utilities loaded (util.mk, functions.mk)
4. Module database built (`mb_modules_build_db`)
5. Modules loaded (`mb_load_modules`)
6. Project targets loaded (`project.mk`, `project.local.mk`)

This order ensures:
- Module targets can be overridden by project targets
- Pre-hooks run before module targets
- Post-hooks can be defined after module targets

### Make Flags and Shell Configuration

MakeBind sets specific Make behavior:
- `.ONESHELL:` - Multi-line recipes run in single shell
- `.POSIX:` - POSIX compliance
- `.SECONDEXPANSION:` - Enables `$$@` in prerequisites
- Shell: `/bin/bash` (configurable via `mb_default_shell_not_windows`)
- Shell flags: `-euc[x]o pipefail` (strict error handling)
- `--no-builtin-rules` and `--no-builtin-variables` - Clean slate
- `--silent` mode (unless `mb_debug_no_silence=1`)

## Writing Tests

Tests use a custom test framework in `tests/make_testing.mk`:

**Test Structure**:
```makefile
# Define test as a variable containing commands
define test_<feature_name>
    $(call mb_assert,<condition>,<error_message>)
    $(call mb_assert_eq,<expected>,<actual>,<error_message>)
    $(call mb_assert_neq,<not_expected>,<actual>,<error_message>)
endef
```

**Running Tests**: Tests are discovered by the `test_` prefix and executed via `mb_run_tests`.

**Assertion Functions**:
- `mb_assert` - Assert truthy condition
- `mb_assert_eq` - Assert equality
- `mb_assert_neq` - Assert inequality
- `mb_assert_was_called` - Track function invocations

## Writing Modules

**Minimal Module Example**:
```makefile
# modules/mymodule/mod_info.mk
mb_module_name := mymodule
mb_module_version := 1.0.0
mb_module_description := My custom module
mb_module_depends := # Optional dependencies

# modules/mymodule/mymodule.mk
ifndef __MB_MODULES_MYMODULE__
__MB_MODULES_MYMODULE__ := 1

mymodule/target: ## Description shown in target list
    $(call mb_printf_info,Running mymodule target)

endif
```

**Module Best Practices**:
- Use include guard pattern: `ifndef __MB_MODULES_<NAME>__`
- Prefix all targets with module name (e.g., `docker/up`, `symfony/cache-clear`)
- Use `##` comments for target descriptions (shown in `make` output)
- Store configuration in `mod_config.mk` with sensible defaults
- Document dependencies in `mb_module_depends`

## Common Patterns

### Invoking Commands
Use `mb_invoke` for consistent command execution with logging:
```makefile
target:
    $(call mb_invoke,docker compose up -d)
```

Variables control behavior:
- `mb_invoke_print` - Show command before execution
- `mb_invoke_dry_run` - Don't execute, just print
- `mb_invoke_run_in_shell` - Capture output/exit code

### Cross-Platform Compatibility
Use `mb_os_call` for OS-specific commands:
```makefile
$(call mb_os_call,<windows_command>,<unix_command>)
```

Check OS: `mb_os_is_windows`, `mb_os_is_linux`, `mb_os_is_mac`

### File Operations
- `mb_exists` / `mb_not_exists` - Check file existence
- `mb_is_url` - Validate URL format
- `mb_timestamp` - Get current Unix timestamp

### Caching
Use the cache system for expensive operations:
```makefile
$(call mb_cache_read,<key>,<output_var>)
$(call mb_cache_write,<key>,<value>,<ttl_seconds>)
```

Cache files stored in `tmp/cache/` with TTL support.

## Common Pitfalls

1. **Variable Assignment**: Use `:=` for immediate assignment, `=` for deferred
2. **Function Calls**: Always use `$(call func,args)` not `$(func args)`
3. **Recursive Variables**: The module loading uses recursion - be careful with variable naming to avoid collisions (pattern: `$0_prm_<name>_$1`)
4. **Windows Support**: Test PowerShell commands - some Make features differ on Windows
5. **Module Dependencies**: Circular dependencies are not detected - avoid them
6. **Include Guards**: Always use unique include guards in .mk files
7. **Comments in define blocks**: `##` comments inside `define...endef` are NOT comments - they become literal output text. Only use comments OUTSIDE define blocks or use `$(info ...)` for debug output

## Code Style

- Prefix internal variables with `mb_` or function name (e.g., `$0_var`)
- Use descriptive function/variable names
- Document complex functions with comment headers
- Keep lines under 120 characters where possible
- Use consistent indentation (tabs for recipes, spaces for variable definitions)

### Function Argument Naming Convention

Use `$0_arg<N>_<name>` pattern for function arguments to match `@arg N` in docblocks:

```makefile
## @function my_function
## @arg 1: command (required) - Command to execute
## @arg 2: prefix (required) - Variable prefix
## @arg 3: shell (optional) - Shell to use (default: /bin/sh)
define my_function
$(strip
    ## Required args: inline check is safe because $(if $(value N),...) guards access
    $(eval $0_arg1_cmd := $(if $(value 1),$(strip $1),$(call mb_printf_error,$0: command required)))
    $(eval $0_arg2_prefix := $(if $(value 2),$(strip $2),$(call mb_printf_error,$0: prefix required)))

    ## Optional arg with default
    $(eval $0_arg3_shell := $(if $(value 3),$(strip $3),/bin/sh))

    ## Complex validation (e.g., mb_require_var): check BEFORE assignment
    $(eval $0_bin := $(call mb_require_var,$($0_arg2_prefix)_bin,$0: $($0_arg2_prefix)_bin not defined))
)
endef
```

**Rules:**
1. **Simple required arg**: inline check in assignment using `$(if $(value N),...)`
2. **Optional arg with default**: `$(if $(value N),$(strip $N),default)` - no error needed
3. **Complex validation**: validate before assignment to avoid `--warn-undefined-variables` warnings

## Important Reminders

### Check main.mk Flags and Directives
Before writing module code, review `main.mk` for active settings:

**MAKEFLAGS:**
- `--always-make` - all targets always rebuild, so `.PHONY` is **redundant** - do not add it
- `--warn-undefined-variables` - guard variable access with `$(value VAR)` or `$(if ...)`
- `--no-builtin-rules` and `--no-builtin-variables` - clean slate, no implicit rules
- `--no-print-directory` - suppress directory change messages
- `--silent` - quiet mode (unless `mb_debug_no_silence=1`)

**Shell Configuration:**
- `SHELL := /bin/bash` (via `mb_default_shell_not_windows`)
- `.SHELLFLAGS := -euc[x]o pipefail` - strict error handling (`-x` added when `mb_debug_show_all_commands=1`)
- `MAKESHELL := $(SHELL)`

**Special Directives:**
- `.ONESHELL:` - entire recipe runs in single shell invocation (multi-line commands share state)
- `.POSIX:` - POSIX compliance mode
- `.SECONDEXPANSION:` - enables `$$@` and `$$*` in prerequisites for dynamic expansion

### Changelog
**IMPORTANT**: When making significant changes, you MUST update `CHANGELOG.md`. This includes:
- New modules
- New features or targets
- Breaking changes
- Bug fixes

Rules:
- Follow [Keep a Changelog](https://keepachangelog.com/) format
- Group changes under: Added, Changed, Deprecated, Removed, Fixed, Security
- Include version number and date for releases
- Bump minor version (e.g., 2.1.0 → 2.2.0) for new features/modules
- Bump patch version (e.g., 2.1.0 → 2.1.1) for bug fixes

### Trello Board
**Board ID: `vBmmD6it`** - Must be set at the start of each session using `mcp__trello__set_active_board`.

Feature proposals should be added as cards in the Trello "Proposals" list instead of markdown files.