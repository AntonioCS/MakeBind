
dc/php/phpunit/run: ## Run phpunit in container (User ARGS to pass arguments)
	$(call dc_shellc,$(dc_service_php),./vendor/bin/phpunit $(value ARGS,$(ARGS)))