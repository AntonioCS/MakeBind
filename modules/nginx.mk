#####################################################################################
# Project: MakeBind
# File: modules/nginx.mk
# Description: Nginx module for MakeBind
# Author: AntonioCS
# License: MIT License
#####################################################################################

#dc_include_before_error_msg := ERROR: You must include docker_compose.mk module before including nginx.mk
#ifndef dc_shellc
#$(error $(dc_include_before_error_msg))
#endif
#
#ifndef dc_invoke
#$(error $(dc_include_before_error_msg))
#endif

mb_debug_nginx ?= $(mb_debug)
nginx_use_docker ?= $(if $(value dc_invoke),$(mb_true),$(mb_false))
nginx_dc_service ?= $(if $(nginx_use_docker),$(error ERROR: nginx_dc_service is not set, please set it to the nginx docker compose service name in your mb_config.mk file))
nginx_dc_default_shell ?= sh
nginx_error_log ?= /var/log/nginx/error.log
nginx_access_log ?= /var/log/nginx/access.log

$(call mb_debug_print, nginx_dc_service: $(nginx_dc_service),$(mb_debug_nginx))
$(call mb_debug_print, nginx_error_log: $(nginx_error_log),$(mb_debug_nginx))
$(call mb_debug_print, nginx_access_log: $(nginx_access_log),$(mb_debug_nginx))
$(call mb_debug_print, nginx_dc_default_shell: $(nginx_dc_default_shell),$(mb_debug_nginx))

define nginx_tail_logs
	$(eval $0_cmd := tail -f $1)
	$(if $(nginx_use_docker),
		$(call dc_shellc,$(nginx_dc_service),$($0_cmd))
		,
		$($0_cmd)
	)
endef


nginx/logs/tail/error: ## Tail the error log
	$(call nginx_tail_logs,$(nginx_error_log))

nginx/logs/tail/access: ## Tail the access log
	$(call nginx_tail_logs,$(nginx_access_log))

ifeq ($(nginx_use_docker),$(mb_true))

nginx/dc/logs: ## Tail nginx docker logs
	$(call dc_invoke,logs,-f,$(nginx_dc_service))

nginx/dc/shell: ## Start a shell in the nginx container
	$(call dc_invoke,exec,,$(nginx_dc_service),$(nginx_dc_default_shell))

endif

ifdef dc_invoke
nginx/restart: dc_cmd_services_stop := $(nginx_dc_service)
nginx/restart: dc_cmd_services_up := $(nginx_dc_service)
nginx/restart: dc/restart
nginx/restart: ## Restart the nginx container service

nginx_error_log ?= /var/log/nginx/error.log
nginx_access_log ?= /var/log/nginx/access.log

define nginx_invoke
$(strip
	$(if $(value 1),,$(error ERROR: You must pass a commad))
	$(call mb_invoke, $1)
)
endef


nginx/tail-error-log: ## Tail the error log
	$(call nginx_invoke,tail -f $(nginx_error_log))

nginx/tail-access-log: ## Tail the access log
	$(call nginx_invoke,-f $(nginx_access_log))

nginx/restart: ## Restart the nginx service
	$(call nginx_invoke,service nginx restart)
