### Toggle debug for Nginx-related targets (inherits global mb_debug by default)
mb_debug_nginx ?= $(mb_debug)

### Use Docker for Nginx commands (set to $(mb_true) when using docker_compose)
nginx_use_docker ?= $(if $(value dc_invoke),$(mb_true))#

### Docker Compose service name for the Nginx container (required if nginx_use_docker is true)
nginx_dc_service ?=#

### Default shell to use inside the Nginx container
nginx_dc_default_shell ?= sh

### Path to Nginx error log (host or container path depending on nginx_use_docker)
nginx_error_log ?= /var/log/nginx/error.log

### Path to Nginx access log (host or container path depending on nginx_use_docker)
nginx_access_log ?= /var/log/nginx/access.log

### Command to restart/reload Nginx (override per distro: e.g., 'nginx -s reload' or 'systemctl reload nginx')
nginx_cmd_restart ?= service nginx restart
