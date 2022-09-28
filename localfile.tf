# resource "local_file" "kubeconfig" {
#   content              = local.kubeconfig
#   filename             = substr(var.config_output_path, -1, 1) == "/" ? "${var.config_output_path}kubeconfig_${var.cluster_name}" : var.config_output_path
#   file_permission      = "0644"
#   directory_permission = "0755"
# }

resource "local_file" "jenkinsfile" {
  content              = local.jenkinsfile
  filename             = substr(var.config_output_path, -1, 1) == "/" ? "${var.config_output_path}jenkinsfile" : var.config_output_path
  file_permission      = "0644"
  directory_permission = "0755"
}

resource "local_file" "deployment" {
  content              = local.deployment
  filename             = substr(var.vulapp_path, -1, 1) == "/" ? "${var.vulapp_path}deployment.yaml" : var.vulapp_path
  file_permission      = "0644"
  directory_permission = "0755"
}