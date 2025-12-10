# bind-hub

This folder contains your project's MakeBind configuration and customizations.

## Files

### User-Editable Files

| File | Purpose |
|------|---------|
| `config.mk` | Project configuration variables (name, prefix, settings) |
| `config.local.mk` | Local overrides for config.mk (gitignored, optional) |
| `project.mk` | Custom project targets and rules |
| `project.local.mk` | Local target overrides (gitignored, optional) |

### Auto-Generated (Do Not Edit)

| Folder/File | Purpose |
|-------------|---------|
| `internal/modules.mk` | List of enabled modules - managed via `mb/modules/add` and `mb/modules/remove` |

## Folders

| Folder | Purpose | Created |
|--------|---------|---------|
| `configs/` | Module configuration overrides (e.g., `docker_config.mk`) | When first module with config is added |
| `modules/` | Project-specific custom modules | When you run `mb/modules/create/<name>` |
| `internal/` | MakeBind internal files | Automatically on project init |

## Managing Modules

```bash
# List available modules
make mb/modules/list

# Add a module
make mb/modules/add/<module_name>

# Remove a module
make mb/modules/remove/<module_name>

# Create a custom module
make mb/modules/create/<module_name>
```

## Configuration Override Pattern

To override a module's default configuration:
1. Add the module: `make mb/modules/add/<module>`
2. Edit `configs/<module>_config.mk` with your values

The override file is automatically created when you add a module that has configurable options.
