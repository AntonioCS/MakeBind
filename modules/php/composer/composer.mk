ifndef __MB_MODULES_PHP_COMPOSER_FUNCTIONS__
__MB_MODULES_PHP_COMPOSER_FUNCTIONS__ := 1

php_composer_bin ?= /usr/bin/composer

define php_composer_invoke
$(strip
	$(eval $0_prams_cmd := $(if $(value 1),$1,$(error ERROR: You must pass a commad)))
	$(call php_invoke,$(php_composer_bin) $($0_prams_cmd))
)
endef

endif # __MB_MODULES_PHP_COMPOSER_FUNCTIONS__

ifndef __MB_MODULES_PHP_COMPOSER_TARGETS__
__MB_MODULES_PHP_COMPOSER_TARGETS__ := 1

php/composer/run/%:
	$(eval $@_cmd := $*)
	$(eval $@_args := $(if $(value cargs),$(cargs)))
	$(call php_composer_invoke,$* $($@_args))

php/composer/install: mb_info_msg := Running composer install
php/composer/install: mb/info-composer-install
php/composer/install: php/composer/run/install
php/composer/install: ## Run composer install. Use variable cargs to pass extra parameters

php/composer/update: mb_info_msg := Running composer update
php/composer/update: mb/info-composer-update
php/composer/update: php/composer/run/update
php/composer/update: ## Run composer install. Use variable cargs to pass extra parameters

php/composer/require: mb_info_msg := Running composer require
php/composer/require: mb/info-composer-require
php/composer/require: php/composer/run/require
php/composer/require: ## Run composer require. Use variable cargs to pass extra parameters



endif # __MB_MODULES_PHP_COMPOSER_TARGETS__

endif # __MB_MODULES_PHP_COMPOSER__