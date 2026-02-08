# MakeBind Architecture

Internal architecture reference for MakeBind contributors.

For code conventions and best practices, invoke the `/makebind` skill.

## Entry Points

- `main.mk` - Main entry point that orchestrates the entire system
- `templates/Makefile.tpl.mk` - Project-level Makefile template that references main.mk

## Core Components (core/)

| File | Purpose |
|------|---------|
| `modules_manager.mk` | Module discovery, loading, and dependency resolution |
| `functions.mk` | Core utility functions (mb_invoke, mb_shell_capture, mb_user_confirm) |
| `targets.mk` | Target listing and help system |
| `util.mk` | Utility functions and helper includes |
| `init_project.mk` | Project initialization when bind-hub folder is missing |

## Utility Components (core/util/)

| File | Purpose |
|------|---------|
| `os_detection.mk` | OS detection (Linux/macOS), `mb_os_call` |
| `colours.mk` | Terminal color output helpers |
| `cache.mk` | File-based caching system with TTL support |
| `debug.mk` | Debug output utilities |
| `variables.mk` | Common variable definitions (mb_true, mb_false, mb_on, mb_off) |
| `git.mk` | Git utilities |

## Module Loading Process

1. Build module database from all `mod_info.mk` files (`mb_modules_build_db`)
2. Read `bind-hub/internal/modules.mk` for enabled modules
3. For each enabled module:
   - Load module's `mod_config.mk` (if exists)
   - Load project override: `bind-hub/configs/<module>_config.mk` (if exists)
   - Load module implementation file
4. Dependencies are automatically loaded when adding modules

Module discovery locations:
- System modules: `modules/` directory (searched recursively)
- Project modules: `bind-hub/modules/` directory (searched recursively)

## Loading Order

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

## Available Modules

| Category | Modules | Description |
|----------|---------|-------------|
| `php/` | php, composer, phpunit, phpcs, phpstan, psalm | PHP ecosystem |
| `php/frameworks/` | symfony, laravel | Framework support |
| `containers/` | docker, docker_compose | Container tools |
| `webservers/` | nginx | Web servers |
| `cloud_providers/aws/` | s3, sqs, sns | AWS services |
| `databases/` | postgresql | Database management |
| `infrastructure/` | terraform | Infrastructure as code |
| `project_builder/` | project_builder | Project scaffolding |

## Test Framework

Tests are in `tests/` using two framework files:
- `tests/test_runner.mk` - Test discovery and execution (`mb_run_tests`)
- `tests/asserts.mk` - Assertion functions

### Assertion Functions

| Function | Purpose |
|----------|---------|
| `mb_assert` | Assert truthy condition |
| `mb_assert_eq` | Assert equality |
| `mb_assert_neq` | Assert inequality |
| `mb_assert_empty` | Assert value is empty |
| `mb_assert_not_empty` | Assert value is not empty |
| `mb_assert_filter` | Assert value matches filter |
| `mb_assert_contains` | Assert string contains substring |
| `mb_assert_exists` | Assert file/path exists |
| `mb_assert_not_exists` | Assert file/path does not exist |
| `mb_assert_was_called` | Track function invocations (in test_runner.mk) |
