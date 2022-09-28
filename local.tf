locals {
  kubeconfig = templatefile("${path.module}/templates/kubeconfig.tpl", {
    kubeconfig_name                   = var.kubeconfig_name
    endpoint                          = aws_eks_cluster.panw_eks_cluster.endpoint
    cluster_auth_base64               = aws_eks_cluster.panw_eks_cluster.certificate_authority[0].data
    aws_authenticator_command         = var.kubeconfig_aws_authenticator_command
    aws_authenticator_command_args    = length(var.kubeconfig_aws_authenticator_command_args) > 0 ? var.kubeconfig_aws_authenticator_command_args : ["token", "-i", aws_eks_cluster.panw_eks_cluster.name]
    aws_authenticator_additional_args = var.kubeconfig_aws_authenticator_additional_args
    aws_authenticator_env_variables   = var.kubeconfig_aws_authenticator_env_variables
  })

  jenkinsfile = templatefile("${path.module}/templates/jenkinsfile.tpl", {
    aws_account_id                      = data.aws_caller_identity.current.account_id
    aws_default_region                  = var.region
    image_repo_name                     = var.ecr_repo_name
    repository_uri                      = aws_ecr_repository.panw_ecr_repo.repository_url
    eks_cluster_name                    = var.eks_cluster_name
    github_url                          = var.github_url
    image_tag                           = "latest"
  })

  deployment = templatefile("${path.module}/templates/deployment.tpl", {
    image_name                          = var.ecr_repo_name
    repository_uri                      = aws_ecr_repository.panw_ecr_repo.repository_url
    image_tag                           = "latest"
  })
}