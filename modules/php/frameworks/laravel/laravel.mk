#####################################################################################
# Project: MakeBind
# File: modules/php/frameworks/laravel.mk
# Description: PHP Laravel module for MakeBind
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_MODULES_PHP_FRAMEWORKS_LARAVEL__
__MB_MODULES_PHP_FRAMEWORKS_LARAVEL__ := 1

ifndef __MB_MODULES_PHP_FRAMEWORKS_LARAVEL_FUNCTIONS__
__MB_MODULES_PHP_FRAMEWORKS_LARAVEL_FUNCTIONS__ := 1

define php_lv_artisan
$(strip
	$(eval $0_param_cmd := $(strip $(if $(value 1),$1)))
	$(call php_invoke,artisan $($0_param_cmd))
)
endef

endif # __MB_MODULES_PHP_FRAMEWORKS_LARAVEL_FUNCTIONS__

ifndef __MB_MODULES_PHP_FRAMEWORKS_LARAVEL_TARGETS__
__MB_MODULES_PHP_FRAMEWORKS_LARAVEL_TARGETS__ := 1

php/lv/ar/run/%: ## Run artisan <command>. Ex.: make php/lv/ar/run/migrate. Use ar_opts option to pass additional options. Ex.: make lv/ar/run/migrate ar_opts="--env=testing"
	$(eval cmd := $(subst /, ,$*))
	$(eval params := )
	$(if $(word 2, $(cmd)),
		$(eval cmd := $(firstword $(cmd)))
		$(eval params := $(wordlist 2, $(words $(cmd)),$(cmd)))
	)
	$(eval opts := $(if $(value ar_opts),$(ar_opts)))
	$(call php_lv_artisan, $(cmd) $(opts) $(params))

php/lv/ar/help/%: ## Get help for this artisan <command>. Ex.: make lv/ar/help/migrate
	$(MAKE) lv/ar/run/$* ar_opts=--help


php/lv/ar/list: ## List all artisan commands
	$(call lv_artisan)

php/lv/ar/list/%: ## List all artisan commands but filter by <filter>. Ex.: make lv/ar/list/migrate
	$(MAKE) php/lv/ar/list | grep $*

php/lv/ar/tinker: php/lv/ar/run/tinker
php/lv/ar/tinker: ## Run tinker


.PHONY: php/lv/ar/run/% php/lv/ar/help/% php/lv/ar/list php/lv/ar/list/% php/lv/ar/tinker

endif # __MB_MODULES_PHP_FRAMEWORKS_LARAVEL_TARGETS__

endif # __MB_MODULES_PHP_FRAMEWORKS_LARAVEL__
