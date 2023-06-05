# AWS Playground

Welcome to the AWS Playground repository! This repository is the result of my initial experiments with Terraform and infrastructure provisioning on AWS. Feel free to use them in any way you want.
However, I caution that not all playgrounds may work, and I do not provide detailed requirements for individual directories or explanations regarding their intended purpose.

## Table of Contents

- [Getting Started](#getting-started)
- [Directory Structure](#directory-structure)
- [License](#license)

## Getting Started

To get started with the AWS Playground, follow these steps:

1. Clone the repository: `git clone https://github.com/your-username/aws-playground.git`
2. Install Terraform: Follow the official [Terraform installation guide](https://learn.hashicorp.com/tutorials/terraform/install-cli) to install Terraform on your local machine.
3. Navigate to the specific directory for the infrastructure you want to provision.
4. Initialize Terraform: Run `terraform init` to initialize the Terraform configuration for the selected infrastructure.
5. Modify the Terraform variables: If necessary, update the variables in the respective `.tfvars` file or pass them via command line.
6. Provision the infrastructure: Execute `terraform apply` to provision the infrastructure on AWS.
7. Explore and experiment: Once the infrastructure is provisioned, feel free to explore and experiment with different configurations and resources.

**Note:** Be cautious when provisioning resources, as it may incur costs on your AWS account. Make sure to review the code and understand the implications before running Terraform apply.

## Directory Structure

The repository is organized into directories, each representing a specific AWS infrastructure provisioned using Terraform. Here's an overview of the directory structure:

```
/aws-playground
├── /directory1
│   ├── main.tf
│   ├── variables.tf
│   └── ...
├── /directory2
│   ├── main.tf
│   ├── variables.tf
│   └── ...
└── /directory3
    ├── main.tf
    ├── variables.tf
    └── ...
```

Each directory contains a `main.tf` file, which contains the Terraform configuration code for provisioning the infrastructure, and a `variables.tf` file, which defines the input variables used in the configuration. Some may contain custom modules created by me, which are located in the `modules` directory.

Feel free to explore the different directories and their contents to understand the provisioned infrastructure.

## License

The AWS Playground repository is licensed under the [MIT License](LICENSE). Feel free to modify and distribute the code within the bounds of this license.
