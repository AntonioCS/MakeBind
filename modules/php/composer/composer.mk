ifndef __MB_MODULES_PHP_COMPOSER__
__MB_MODULES_PHP_COMPOSER__ := 1

ifndef __MB_MODULES_PHP_COMPOSER_FUNCTIONS__
__MB_MODULES_PHP_COMPOSER_FUNCTIONS__ := 1

php_composer_bin ?= /usr/bin/composer

define php_composer_invoke
$(strip
	$(eval $0_prms_cmd := $(if $(value 1),$(strip $1),$(error ERROR: $0 - You must pass a commad)))
	$(call php_invoke,$(php_composer_bin) $($0_prms_cmd))
)
endef

endif # __MB_MODULES_PHP_COMPOSER_FUNCTIONS__

ifndef __MB_MODULES_PHP_COMPOSER_TARGETS__
__MB_MODULES_PHP_COMPOSER_TARGETS__ := 1

php/composer/run/%: ## Run composer <command>. Use variable cargs to pass extra parameters
	$(eval $@_cmd := $*)
	$(eval $@_args := $(if $(value cargs),$(cargs)))
	$(call mb_printf_info, Running composer $($@_cmd) $(if $(value cargs), with arguments $(cargs)))
	$(call php_composer_invoke,$($@_cmd) $($@_args))

php/composer/install: php/composer/run/install
php/composer/install: ## Run composer install. Use variable cargs to pass extra parameters

php/composer/update: php/composer/run/update
php/composer/update: ## Run composer install. Use variable cargs to pass extra parameters

php/composer/require: php/composer/run/require
php/composer/require: ## Run composer require. Use variable cargs to pass extra parameters


.PHONY: php/composer/run/% php/composer/install php/composer/update php/composer/require

endif # __MB_MODULES_PHP_COMPOSER_TARGETS__

endif # __MB_MODULES_PHP_COMPOSER__