

### ---- Global AWS CLI configuration options to be used with mb_aws_invoke --------------
mb_aws_bin       ?= aws# override CLI path/binary
mb_aws_profile   ?=#               # sets --profile
mb_aws_region    ?= eu-west-1# sets --region
mb_aws_endpoint  ?=# sets --endpoint-url (e.g., https://localhost:4566 for LocalStack)
mb_aws_output    ?= json# sets --output - json|text|table
mb_aws_pager_off ?= $(mb_true)# if non-empty, adds --no-cli-pager
mb_aws_flags     ?=#                     # any extra global flags you always want