### Configuration file for Project

mb_project_name := project-name### Please replace project-name with the name of your project
mb_project_prefix := project-prefix### Please replace project-prefix with the prefix of your project

### List of modules to include in the project
### You can add MakeBind modules or custom modules located in the modules folder in <your_project>/_bind-hub/modules
### Use the variable $(mb_project_bindhub_modules_path) to reference <your_project>/_bind-hub/modules
mb_project_modules := docker/docker_compose.mk