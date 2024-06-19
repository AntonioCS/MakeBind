#####################################################################################
# Project: MakeBind
# File: mb_config.tpl.mk
# Description: This is the template for the configuration file. Copy this file to your project folder into BindHub and rename it to mb_config.mk
# Also note that if MakeBind does not encounter mb_config.mk in your project it will ask if you want to create it automatically
# Author: AntonioCS
# License: MIT License
#####################################################################################

mb_project_name := project-name
mb_project_prefix := project-prefix

### List of modules to include in the project
### You can add MakeBind modules or custom modules located in the modules folder in <your_project>/bind-hub/modules
### Use the variable $(mb_project_bindhub_modules_path) to reference <your_project>/bind-hub/modules
mb_project_modules := docker/docker_compose.mk