#####################################################################################
# Project: MakeBind
# File: modules/docker/php/composer.mk
# Description: Docker php composer module for MakeBind
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_MODULES_DOCKER_PHP_COMPOSER__
__MB_MODULES_DOCKER_PHP_COMPOSER__ := 1

include $(mb_modules_path)/docker/php.mk

define php_composer_invoke
$(strip
	$(if $(value 1),,$(error ERROR: You must pass a commad))
	$(eval
		php_composer_invoke_bin := $(if $(value php_composer_bin),$(php_composer_bin),composer)
		php_composer_invoke_cmd := $1
	)
	$(call dc_shellc,$(dc_service_php),$(php_composer_invoke_bin) $(php_composer_invoke_cmd))
)
endef

dc/php/internal-composer-%:
	$(call php_composer_invoke,$* $(if $(value CPARAMS),$(CPARAMS)))

dc/php/composer-install: mb_info_msg := Running composer install
dc/php/composer-install: mb/info-composer-install
dc/php/composer-install: dc/php/internal-composer-install
dc/php/composer-install: ## Run composer install in container. Use variable CPARAMS to pass extra parameters

dc/php/composer-update: mb_info_msg := Running composer update
dc/php/composer-update: mb/info-composer-update
dc/php/composer-update: dc/php/internal-composer-update
dc/php/composer-update: ## Run composer install in container. Use variable CPARAMS to pass extra parameters

dc/php/composer-require: mb_info_msg := Running composer require
dc/php/composer-require: mb/info-composer-require
dc/php/composer-require: dc/php/internal-composer-require
dc/php/composer-require: ## Run composer require in container. Use variable CPARAMS to pass extra parameters

endif # __MB_MODULES_DOCKER_PHP_COMPOSER__
