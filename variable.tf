variable "unique_prefix" {
  description = "Name that will be used as prefix for all the resources deployed"
  default     = "bechong"
}

provider "aws" {
    #profile = "default"
    region  = var.region
}

data "aws_caller_identity" "current" {}

variable "region" {
  default = "ap-southeast-1"
}

data "aws_availability_zones" "azs" {
}

variable "panw_eks_vpc" {
  description = "PANW EKS VPC"
  default     = "10.100.0.0/16"
}

variable "panw_docker_vpc" {
  description = "PANW Docker VPC"
  default     = "10.101.0.0/16"
}

variable "attacker_vpc" {
  description = "Attacker VPC"
  default     = "10.102.0.0/16"
}

variable "kubeconfig_aws_authenticator_command" {
  description = "Command to use to fetch AWS EKS credentials."
  type        = string
  default     = "aws-iam-authenticator"
}

variable "kubeconfig_aws_authenticator_command_args" {
  description = "Default arguments passed to the authenticator command. Defaults to [token -i $cluster_name]."
  type        = list(string)
  default     = []
}


variable "kubeconfig_aws_authenticator_additional_args" {
  description = "Any additional arguments to pass to the authenticator such as the role to assume. e.g. [\"-r\", \"MyEksRole\"]."
  type        = list(string)
  default     = []
}

variable "kubeconfig_aws_authenticator_env_variables" {
  description = "Environment variables that should be used when executing the authenticator. e.g. { AWS_PROFILE = \"eks\"}."
  type        = map(string)
  default     = {}
}

variable "kubeconfig_name" {
  description = "Kubeconfig file name"
  type        = string
  default     = "KUBECOFIG"
}

variable "config_output_path" {
  description = "Where to save the Kubectl config file (if `write_kubeconfig = true`). Assumed to be a directory if the value ends with a forward slash `/`."
  type        = string
  default     = "./output/"
}

variable "vulapp_path" {
  description = "Path for vulnerable app"
  type        = string
  default     = "./vuln_app/"
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster. Also used as a prefix in names of related resources."
  type        = string
  default     = "panw_eks_cluster"
}

variable "ecr_repo_name" {
  description = "ECR Repository Name"
  default     = "panw-webserver"
}

variable "github_url" {
  description = "Github URL"
  default     = "https://github.com/chiangyaw/samplenginx.git"
}