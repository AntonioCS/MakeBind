#####################################################################################
# Project: MakeBind
# File: mb_config.tpl.mk
# Description: This is the template for the configuration file. Copy this file to your project folder into BindHub and rename it to mb_config.mk
# Also note that if MakeBind does not encounter mb_config.mk in your project it will ask if you want to create it automatically
# Author: AntonioCS
# License: MIT License
#####################################################################################

mb_project_name := project-name

### List of modules to include in the project
### This can be MakeBind modules or custom modules located in the modules folder in <your_project>/BindHub/modules
mb_project_modules := docker/docker_compose.mk