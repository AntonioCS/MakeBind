### Custom Project targets

project/setup: mb_info_msg := Running setup
project/setup: mb/info-setup
project/setup: ## Setup project
	$(call mb_printf_info,Finished setup)