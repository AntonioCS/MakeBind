

mb_pb_php_symfony_run_script ?= $(mb_modules_path)/project-builder/php/symfony/build.sh

mb_pb_php_symfony_composer_packages ?= symfony/orm-pack \
  doctrine/doctrine-migrations-bundle \
  doctrine/doctrine-fixtures-bundle

mb_pb_php_symfony_composer_dev_packages ?= symfony/maker-bundle \
                                                 	symfony/debug-bundle \
                                                 	symfony/var-dumper \
                                                 	symfony/profiler-pack \
                                                 	phpunit/phpunit \
                                                 	phpstan/phpstan


mb_pb_php_symfony_replace ?= \
PROJECT_NAME|$(mb_pb_project_name):\
PHP_IDE_CONFIG_SERVER_NAME|$(mb_pb_project_name):\
POSTGRES_USER|sy_user:\
POSTGRES_PASSWORD|sy_password:\
POSTGRES_DB|$(mb_pb_project_name)

## TODO: Add filter extensions as 2nd argument
## $1 = folder path
define mb_pb_replacer
$(strip
	$(eval $0_folder := $(strip $1))
	$(eval $0_perl_replacer := $(subst :,/g$(mb_scolon)s/%_,$(strip $(mb_pb_php_symfony_replace))))
	$(eval $0_perl_replacer := $(subst |,_%/,$($0_perl_replacer)))
	$(eval $0_perl_replacer := $(subst s/%_ ,s/%_,$($0_perl_replacer)))
	find "$($0_folder)" -type f \( -name "*.yml" -o -name "*.yaml" -name "Dockerfile" \) -exec perl -pi -e 's/%_$($0_perl_replacer)/g;' {} \;
)
endef

mb_pb_php_symfony_docker_folder ?= $(mb_pb_tpl_folder)/php/symfony/docker
mb_pb_php_symfony_dockerfile_path ?= $(mb_pb_tpl_folder)/php/symfony/docker/services/app/Dockerfile
mb_pb_php_symfony_docker_image_name ?= mb_pb_php_symfony_base

define mb_pb_dc_build_image
$(strip
docker build --target base \
  -t $(mb_pb_php_symfony_docker_image_name) \
  -f "$(mb_pb_php_symfony_dockerfile_path)" \
  .
)
endef

define mb_pb_dc_run_image
$(strip
$(eval $0_project_path := $(strip $1))
docker run --rm \
  -v "$(mb_project_path)":/app \
  --user "$(shell id -u):$(shell id -g)" \
  $(mb_pb_php_symfony_docker_image_name) \
  sh -c "wget https://getcomposer.org/download/latest-stable/composer.phar -O /tmp/composer && \
         chmod +x /tmp/composer && \
         export COMPOSER_HOME=/tmp/.composer && \
         /tmp/composer create-project symfony/website-skeleton \"$($0_project_path)\" --no-interaction --prefer-dist --no-install && \
         cd \"$($0_project_path)\" && \
         /tmp/composer require --no-update $(mb_pb_php_symfony_composer_packages) && \
         /tmp/composer require --no-update --dev $(mb_pb_php_symfony_composer_dev_packages)"
)
endef

# $1 = project name
define mb_pb_build
$(strip
	$(eval mb_pb_project_name := $(strip $1))

	$(if $(wildcard $(mb_project_path)/docker),
		$(call mb_printf_info,Docker folder already exists$(mb_comma) $(mb_project_path))
	,
		$(call mb_printf_info,Creating Docker folder$(mb_comma) $(mb_project_path))
		$(call mb_invoke,cp -r "$(mb_pb_php_symfony_docker_folder)" "$(mb_project_path)" &&)
	) \
	$(call mb_pb_replacer,$(mb_project_path)) && \
	$(call mb_pb_dc_build_image) && \
    $(call mb_pb_dc_run_image,/app/$(mb_pb_project_name)) && \
    docker rmi -f $(mb_pb_php_symfony_docker_image_name)
)
endef
