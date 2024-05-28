#####################################################################################
# Project: MakeBind
# File: mb_project.tpl.mk
# Description: This is the template for the project specific targets file. Copy this file to your project folder into BindHub and rename it to mb_project.mk
# Also note that if MakeBind does not encounter mb_project.mk in your project it will ask if you want to create it automatically
# Author: AntonioCS
# License: MIT License
#####################################################################################

setup: mb_info_msg := Running setup
setup: mb/info-setup
setup: ## Setup project
	$(call mb_printf_info,Finished setup)