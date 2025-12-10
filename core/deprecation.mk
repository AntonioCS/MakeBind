#####################################################################################
# Project: MakeBind
# File: core/deprecation.mk
# Description: Deprecation checks for MakeBind
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_CORE_DEPRECATION_MK__
__MB_CORE_DEPRECATION_MK__ := 1

## Check for deprecated bind-hub structure (pre-2.1.1)
## Returns $(mb_true) if old structure detected, $(mb_false) otherwise
define mb_check_deprecated_bindhub
$(strip
    $(if $(wildcard $(mb_project_bindhub_path)/mb_config.mk),$(mb_true),
    $(if $(wildcard $(mb_project_bindhub_path)/mb_project.mk),$(mb_true),
    $(if $(wildcard $(mb_project_bindhub_path)/mb_modules.mk),$(mb_true),
    $(mb_false))))
)
endef

## Error message for deprecated bind-hub structure
define mb_deprecated_bindhub_error_msg

================================================================================
ERROR: Deprecated bind-hub structure detected (MakeBind 2.1.1+)
================================================================================

Your project uses the old bind-hub file naming convention.
Please migrate to the new structure:

  1. Rename files:
     mv bind-hub/mb_config.mk bind-hub/config.mk
     mv bind-hub/mb_project.mk bind-hub/project.mk

  2. If you have local overrides, rename them too:
     mv bind-hub/mb_config.local.mk bind-hub/config.local.mk
     mv bind-hub/mb_project.local.mk bind-hub/project.local.mk

  3. Move modules file to internal folder:
     mkdir -p bind-hub/internal
     mv bind-hub/mb_modules.mk bind-hub/internal/modules.mk

After migration, your bind-hub/ folder should look like:
  bind-hub/
  ├── config.mk
  ├── config.local.mk (optional)
  ├── project.mk
  ├── project.local.mk (optional)
  └── internal/
      └── modules.mk

Note: configs/ and modules/ folders are created automatically when needed.
================================================================================

endef

endif # __MB_CORE_DEPRECATION_MK__
