# Folding@home on AWS

* [Folding@home on AWS](#foldinghome-on-aws)
  * [Prerequisites](#prerequisites)
    * [Workstation](#workstation)
    * [AWS](#aws)
  * [Usage](#usage)
    * [CLI Commands](#cli-commands)
    * [Configuration](#configuration)
    * [Manage CloudFormation Stacks](#manage-cloudformation-stacks)
      * [Create](#create)
      * [Update](#update)
      * [Status](#status)
      * [Delete](#delete)
  * [Implementation](#implementation)
    * [Deployment Tool](#deployment-tool)
    * [Directory Structure](#directory-structure)
    * [Linting](#linting)

## Prerequisites

### Workstation

Local or remote system with access to the AWS API.

* CLI environment (developed on Linux, should be portable to Mac and WSL)
* [Python](https://www.python.org/) >=3.7
* [pip3](https://pip.pypa.io/en/stable/) >=20.0.2
* [pipenv](https://github.com/pypa/pipenv) >=2018.11.26
  * `pip3 install --user pipenv==2018.11.26`

**Note:** [pipenv](https://github.com/pypa/pipenv) will install additional runtimes and dependencies in a dedicated, virtual Python environment.

### AWS

* IAM User/Role
  * With sufficient permissions to manage the AWS resources defined by [the CloudFormation templates](aws/templates/).
* AWS Access Keys, temporary or long-term, exported to environment variables
  * [Best Practices for Managing AWS Access Keys](https://docs.aws.amazon.com/general/latest/gr/aws-access-keys-best-practices.html)
  * [Environment Variables To Configure the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html)
  * Use of [aws-vault](https://github.com/99designs/aws-vault) is recommended.

## Usage

### CLI Commands

```bash
# Show all available make targets
make
```

### Configuration

1. Review the [main Sceptre configuration](cfn/config/config.yaml):

    1. `project_code`

        Project code, eg. `myproject`.

    2. `region`

        Configure the AWS Region to deploy to.

        **Note:** [Sceptre configurations may be cascaded](https://sceptre.cloudreach.com/2.3.0/docs/stack_group_config.html#stack-group-config-cascading-config) for multi-Region deployments.

2. Review and update the CloudFormation [Parameters and configuration](cfn/config/).

3. Specifically, review the following settings in [cfn/config/fah/server.yaml](cfn/config/fah/server.yaml):

     1. `KeypairName`: Name of an existing EC2 Key Pair
     2. `ManagementSourceCidrIp`: CIDR IP range to whitelist for server access.

### Manage CloudFormation Stacks

#### Create

```bash
# Deploy all stacks
make stack=fah launch
```

```bash
# Deploy the network stack
make stack=fah/network launch
```

**Note**: Sceptre figures out [dependencies](https://sceptre.cloudreach.com/2.3.0/docs/stack_config.html#dependencies) between stacks at runtime.

#### Update

**Note:** Additional to creating non-existing stacks, `launch` applies pending updates (if any) to stacks which already exists.

```bash
# Update all
make stack=fah launch
```

```bash
# Update the network stack
make stack=fah/network launch
```

#### Status

```bash
# Get status of all stacks
make stack=fah status
```

```bash
# Get status of the network stack and its dependencies
make stack=fah/network status
```

#### Delete

Destroy all AWS resources of one or many stacks:

**Note:** Stacks which depend on the targeted stacks will be deleted as well.

```bash
# Delete the network stack, as well as stacks which depend on it.
make stack=fah/network delete
```

## Implementation

### Deployment Tool

This repository implements the Sceptre tool to facilitate CloudFormation deployments.

**Tip:** To learn how to use the `config/` and `templates/` subdirectories, read up on Sceptre's online resources:

* [Sceptre documentation](https://sceptre.cloudreach.com/)
* [Sceptre GitHub](https://github.com/Sceptre/sceptre)

### Directory Structure

For context, see [Sceptre Directory Structure](https://sceptre.cloudreach.com/2.2.1/docs/get_started.html#directory-structure).

```bash
cfn/                      # Sceptre root
├── config/               # CloudFormation Parameter values, Tags
│   ├── config.yaml       # AWS Profile, AWS Region, Project Code
│   └── fah/              # StackGroup root
│       ├── network.yaml  # Configuration for eg. VPC, gateways, ...
│       └── ...
└── templates/            # CloudFormation templates
    └── fah/              # StackGroup root
│       ├── network.yaml  # Template for eg. VPC, gateways, ...
│       └── ...
```

### Linting

Sceptre resolves dependencies between stacks at runtime. If required, it will update stacks on which the targeted `stack` relies.

As a result, the `lint` step does not know beforehand which stacks will receive updates. For this reason, the `lint` step lints all CloudFormation templates and Lambda payloads regardless of the targeted `stack`.
