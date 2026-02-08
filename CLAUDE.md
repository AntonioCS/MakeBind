# CLAUDE.md

MakeBind is a modular Makefile project manager providing a plugin/module system for GNU Make 4.4+.

For code conventions and patterns, invoke the `/makebind` skill.
For architecture details, see @docs/architecture.md

## Key Commands

```bash
# Tests
make -C tests                                    # All core tests
make -C tests filter=test_name                   # Specific test
make -C tests run_module_tests module=docker_compose  # Module tests
make -C tests run_all_tests                      # Core + module tests

# Modules
make mb/modules/list                             # List available
make mb/modules/add/<name>                       # Add module
make mb/modules/create/<name>                    # Create new module

# Targets
make                                             # List all targets
make mb/help-<keyword>                           # Help on topic

# Debugging
# Set in environment or config.mk:
# mb_debug=1  mb_debug_modules=1  mb_debug_targets=1  mb_debug_show_all_commands=1
```

## main.mk Flags (Know Before Writing Code)

- `--always-make` - `.PHONY` is redundant, do not add it
- `--warn-undefined-variables` - guard variable access with `$(value VAR)` or `$(if ...)`
- `.ONESHELL:` - entire recipe runs in single shell invocation
- `.SHELLFLAGS := -euco pipefail` - strict error handling
- `--silent` - quiet mode (unless `mb_debug_no_silence=1`)

## Contributor Workflow

### Changelog
**IMPORTANT**: Update `CHANGELOG.md` for significant changes (new modules, features, breaking changes, bug fixes).

Rules:
- Follow [Keep a Changelog](https://keepachangelog.com/) format
- Group under: Added, Changed, Deprecated, Removed, Fixed, Security
- Bump minor version (e.g., 2.1.0 → 2.2.0) for new features/modules
- Bump patch version (e.g., 2.1.0 → 2.1.1) for bug fixes

### README Files
Keep README files up to date when making changes:

| File | Update When |
|------|-------------|
| `README.md` | Adding commands, changing installation, new user-facing features |
| `modules/README.md` | Changes to module structure, new module conventions |
| `core/README.md` | New core functions, changes to loading order, new utilities |
| `tests/README.md` | Changes to test framework, new assertions, test conventions |

When adding a new module, update the "Available Modules" table in `README.md`.

### Trello Board
**Board ID: `vBmmD6it`** - Configured via `.kelux.toml` (local config).

**Always use `klx` CLI for Trello operations.** Invoke `/kelux` skill for correct syntax.

Feature proposals go as cards in the Trello "Proposals" list.
