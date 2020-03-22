.PHONY: env lint validate launch delete status clean help check-stack
.DEFAULT_GOAL := help

env: ## Install local dependencies (requires pipenv)
	pipenv sync

mapping: ## Generate a CloudFormation AMI Mapping
	scripts/mapping.sh

lint: env ## Run linter on CloudFormation templates
	pipenv run cfn-lint --info **/templates/**/**/*.yaml

validate: check-stack env lint ## Validate CloudFormation Template(s)
	pipenv run sceptre --dir cfn validate $(stack)

launch: check-stack env lint ## Create/update CloudFormation Template(s)
	pipenv run sceptre --dir cfn launch --yes $(stack)

delete: check-stack env ## Terminate CloudFormation Stack(s)
	pipenv run sceptre --dir cfn delete --yes $(stack)

status: check-stack env ## Show deployment status of the CloudFormation Stack(s)
	pipenv run sceptre --dir cfn status $(stack)

clean: ## Delete local virtualenv
	pipenv --rm || true

help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-18s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

check-stack:
ifndef stack
	$(error 'stack' is undefined)
endif
