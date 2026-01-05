### Configuration file for Project
### Do not put anything that should not be committed to git here
### Useful variables:
### - mb_makebind_path: Path to the MakeBind project
### - mb_modules_path: Path to MakeBind modules folder (not needed in mb_project_modules, if the module doesn't have a path this variable is used)
### - mb_project_makefile: Path to the Makefile of the project
### - mb_project_bindhub_path: Path to the bind.hub folder of the project
### - mb_project_bindhub_modules_path: Path to the modules folder in the bind-hub folder of the project
### - mb_project_path: Path of your project

mb_project_name := project-name### Please replace project-name with the name of your project
mb_project_prefix := project-prefix### Please replace project-prefix with the prefix of your project

### Optional settings (uncomment to enable):
### Show only project targets (hides MakeBind core AND enabled module targets)
#mb_targets_only_project := $(mb_true)

### Strip prefix from staged file paths to match container paths
### Example: git shows 'app/src/Foo.php' but container expects 'src/Foo.php' → set to 'app/'
#mb_staged_strip_prefix := app/
