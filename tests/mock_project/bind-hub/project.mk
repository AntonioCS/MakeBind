### Custom Project targets

setup: mb_info_msg := Running setup
setup: mb/info-setup
setup: ## Setup project
	$(call mb_printf_info,Finished setup)