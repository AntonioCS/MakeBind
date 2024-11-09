#####################################################################################
# Project: MakeBind
# File: modules/nginx.mk
# Description: Nginx module for MakeBind
# Author: AntonioCS
# License: MIT License
#####################################################################################

ifndef __MB_MODULES_NGINX_FUNCTIONS__
__MB_MODULES_NGINX_FUNCTIONS__ := 1

mb_debug_nginx ?= $(mb_debug)
nginx_use_docker ?= $(if $(value dc_invoke),$(mb_true),$(mb_false))
nginx_dc_service ?=# not defined
#$(if $(nginx_use_docker),$(error ERROR: nginx_dc_service is not set, please set it to the nginx docker compose service name in your mb_config.mk file))
nginx_dc_default_shell ?= sh
nginx_error_log ?= /var/log/nginx/error.log
nginx_access_log ?= /var/log/nginx/access.log
nginx_cmd_restart ?= service nginx restart

$(call mb_debug_print, nginx_dc_service: $(nginx_dc_service),$(mb_debug_nginx))
$(call mb_debug_print, nginx_error_log: $(nginx_error_log),$(mb_debug_nginx))
$(call mb_debug_print, nginx_access_log: $(nginx_access_log),$(mb_debug_nginx))
$(call mb_debug_print, nginx_dc_default_shell: $(nginx_dc_default_shell),$(mb_debug_nginx))

define nginx_tail_logs
	$(eval $0_cmd := tail -f $1)
	$(if $(nginx_use_docker),
		$(if $(value nginx_dc_service),
			$(call dc_shellc,$(nginx_dc_service),$($0_cmd))
			,
			$(error ERROR: nginx_dc_service is not set, please set it to the nginx docker compose service name in your mb_config.mk file)
		)
		,
		$($0_cmd)
	)
endef

endif # __MB_MODULES_NGINX_FUNCTIONS__

ifndef __MB_MODULES_NGINX_TARGETS__
__MB_MODULES_NGINX_TARGETS__ := 1

nginx/logs/tail/error: ## Tail the error log
	$(call nginx_tail_logs,$(nginx_error_log))

nginx/logs/tail/access: ## Tail the access log
	$(call nginx_tail_logs,$(nginx_access_log))

ifeq ($(nginx_use_docker),$(mb_true))

nginx/dc/check_service:
	$(if $(value nginx_dc_service),,$(error ERROR: nginx_dc_service is not set, please set it to the nginx docker compose service name in your mb_config.mk file))

nginx/dc/logs: nginx/dc/check_service
nginx/dc/logs: ## Tail nginx docker logs
	$(call dc_invoke,logs,-f,$(nginx_dc_service))

nginx/dc/shell: nginx/dc/check_service
nginx/dc/shell: ## Start a shell in the nginx container
	$(call dc_invoke,exec,,$(nginx_dc_service),$(nginx_dc_default_shell))

nginx/dc/restart: nginx/dc/check_service
nginx/dc/restart: dc_cmd_services_stop := $(nginx_dc_service)
nginx/dc/restart: dc_cmd_services_up := $(nginx_dc_service)
nginx/dc/restart: dc/restart
nginx/dc/restart: ## Restart the nginx container service

else

nginx/restart: ## Restart the nginx service
	$(call mb_invoke,$(nginx_cmd_restart))

endif # nginx_use_docker

endif # __MB_MODULES_NGINX_TARGETS__