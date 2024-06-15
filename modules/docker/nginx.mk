#####################################################################################
# Project: MakeBind
# File: modules/docker/nginx.mk
# Description: Docker nginx module for MakeBind
# Author: AntonioCS
# License: MIT License
#####################################################################################

dc_include_before_error_msg := ERROR: You must include docker_compose.mk module before including nginx.mk
ifndef dc_shellc
$(error $(dc_include_before_error_msg))
endif

ifndef dc_invoke
$(error $(dc_include_before_error_msg))
endif

mb_debug_dc_nginx ?= $(mb_debug)
dc_service_nginx ?= $(error ERROR: dc_service_nginx is not set, please set it to the nginx docker compose service name in your mb_config.mk file)
dc_nginx_default_shell ?= sh
dc_nginx_error_log ?= /var/log/nginx/error.log
dc_nginx_access_log ?= /var/log/nginx/access.log

$(call mb_debug_print, dc_service_nginx: $(dc_service_nginx),$(mb_debug_dc_nginx))
$(call mb_debug_print, dc_nginx_error_log: $(dc_nginx_error_log),$(mb_debug_dc_nginx))
$(call mb_debug_print, dc_nginx_access_log: $(dc_nginx_access_log),$(mb_debug_dc_nginx))
$(call mb_debug_print, dc_nginx_default_shell: $(dc_nginx_default_shell),$(mb_debug_dc_nginx))

dc/nginx/tail-error-log: ## Tail the error log
	$(call dc_shellc,$(dc_service_nginx),tail -f $(dc_nginx_error_log))

dc/nginx/tail-access-log: ## Tail the access log
	$(call dc_shellc,$(dc_service_nginx),tail -f $(dc_nginx_access_log))

dc/nginx/tail-dc-logs: ## Tail nginx docker logs
	$(call dc_invoke,logs,-f,$(dc_service_nginx))

dc/nginx/shell: ## Start a shell in the nginx container
	$(call dc_invoke,exec,,$(dc_service_nginx),$(dc_nginx_default_shell))

dc/nginx/restart: dc_cmd_services_stop := $(dc_service_nginx)
dc/nginx/restart: dc_cmd_services_up := $(dc_service_nginx)
dc/nginx/restart: dc/restart
dc/nginx/restart: ## Restart the nginx container service
