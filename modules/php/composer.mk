

define php_composer_invoke
$(strip
	$(if $(value 1),,$(error ERROR: You must pass a commad))
	$(eval
		php_composer_invoke_bin := $(if $(value php_composer_bin),$(php_composer_bin),composer)
		php_composer_invoke_cmd := $(if $(value 1),$1)
	)
	$(strip $(php_invoke_bin) $(php_invoke_cmd)))
)
endef