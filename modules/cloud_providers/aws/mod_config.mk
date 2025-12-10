

### ---- Global AWS CLI configuration options to be used with mb_aws_invoke --------------

aws_bin       ?= aws# override CLI path/binary
aws_profile   ?=#               # sets --profile
aws_region    ?= eu-west-1# sets --region
aws_endpoint  ?=# sets --endpoint-url (e.g., https://localhost:4566 for LocalStack)
aws_output    ?= json# sets --output - json|text|table
aws_pager_off ?= $(mb_true)# if non-empty, adds --no-cli-pager
aws_flags     ?=#                     # any extra global flags you always want