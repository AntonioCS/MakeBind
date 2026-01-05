# MakeBind Modules

This folder contains all system modules provided by MakeBind. This document explains how modules work and how to create your own.

## Module Structure

Every module is a folder containing at least two files:

```
mymodule/
├── mod_info.mk      # Required: Module metadata
├── mymodule.mk      # Required: Implementation
└── mod_config.mk    # Optional: Default configuration
```

### mod_info.mk (Required)

Defines module metadata used by the module manager:

```makefile
mb_module_name := mymodule
mb_module_version := 1.0.0
mb_module_description := Brief description of what this module does
mb_module_depends := docker  # Space-separated list of dependencies (optional)
mb_module_filename := mymodule.mk  # Optional: defaults to <module_name>.mk
```

| Variable | Required | Description |
|----------|----------|-------------|
| `mb_module_name` | Yes | Unique identifier for the module |
| `mb_module_version` | Yes | Semantic version (e.g., 1.0.0) |
| `mb_module_description` | Yes | Short description shown in `mb/modules/list` |
| `mb_module_depends` | No | Space-separated module dependencies |
| `mb_module_filename` | No | Custom implementation filename |

### mod_config.mk (Optional)

Default configuration variables for the module. Users can override these in `bind-hub/configs/<module>_config.mk`.

```makefile
# Default values - users can override in bind-hub/configs/mymodule_config.mk
mymodule_bin := /usr/local/bin/mytool
mymodule_config_file := config.yml
mymodule_verbose := 0
```

**Naming convention:** Prefix all variables with the module name to avoid conflicts.

### Implementation File (Required)

The main module file containing targets and functions. Must use an include guard.

```makefile
ifndef __MB_MODULES_MYMODULE__
__MB_MODULES_MYMODULE__ := 1

# Targets use ## comments for descriptions (shown in target list)
mymodule/run: ## Run the tool
	$(call mb_invoke,$(mymodule_bin) --config=$(mymodule_config_file))

mymodule/status: ## Show status
	$(call mb_invoke,$(mymodule_bin) status)

endif
```

**Key points:**
- Use include guard: `ifndef __MB_MODULES_<NAME>__`
- Prefix targets with module name: `mymodule/target`
- Use `## comment` for target descriptions (shown in `make`)
- Use `$(call mb_invoke,...)` for command execution

## Creating a New Module

### Option 1: Use the module creator

```shell
make mb/modules/create/mymodule
```

This creates a skeleton module in `modules/mymodule/`.

### Option 2: Create manually

1. Create folder: `modules/mymodule/` (system) or `bind-hub/modules/mymodule/` (project)
2. Create `mod_info.mk` with required metadata
3. Create `mymodule.mk` with targets
4. Optionally create `mod_config.mk` for configurable defaults

## System vs Project Modules

| Type | Location | Use Case |
|------|----------|----------|
| System | `modules/` (in MakeBind) | Reusable across all projects |
| Project | `bind-hub/modules/` | Specific to one project |

Project modules are loaded after system modules and can override system module targets.

## Module Categories

| Folder | Description |
|--------|-------------|
| `containers/` | Docker, Docker Compose |
| `php/` | PHP, Composer, PHPUnit, PHPCS, PHPStan, Psalm |
| `php/frameworks/` | Symfony, Laravel |
| `webservers/` | Nginx |
| `cloud_providers/aws/` | S3, SQS, SNS, LocalStack |
| `infrastructure/` | Terraform |
| `databases/` | PostgreSQL |
| `project_builder/` | Project scaffolding |

## Example: docker_compose Module

A real-world example from this repository:

**mod_info.mk:**
```makefile
mb_module_name := docker_compose
mb_module_version := 1.0.0
mb_module_description := Docker Compose targets for container orchestration
mb_module_depends := docker
```

**mod_config.mk:**
```makefile
dc_bin := docker compose
dc_file := docker-compose.yml
dc_project_name :=
```

**docker_compose.mk:** (simplified)
```makefile
ifndef __MB_MODULES_DOCKER_COMPOSE__
__MB_MODULES_DOCKER_COMPOSE__ := 1

dc/up: ## Start containers
	$(call mb_invoke,$(dc_bin) -f $(dc_file) up -d)

dc/down: ## Stop containers
	$(call mb_invoke,$(dc_bin) -f $(dc_file) down)

dc/logs: ## View container logs
	$(call mb_invoke,$(dc_bin) -f $(dc_file) logs -f)

endif
```

## Best Practices

1. **Naming:** Use clear, descriptive names. Prefix all variables and targets with module name.
2. **Dependencies:** Declare all dependencies in `mod_info.mk`. They're auto-loaded.
3. **Configuration:** Put all tunables in `mod_config.mk` with sensible defaults.
4. **Documentation:** Every target should have a `## description` comment.
5. **Include guards:** Always use them to prevent double-loading.
6. **Use mb_invoke:** For consistent command execution and logging.
