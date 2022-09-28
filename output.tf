output "panw_docker_public_ip" {
  value       = aws_instance.panw_instance.public_ip
}

output "attacker_kali_public_ip" {
  value       = aws_instance.attacker_kali.public_ip
}
output "panw_docker_role_arn" {
  value       = aws_iam_role.panw_docker_role.arn
}

output "panw_s3_bucket_name" {
  value       = aws_s3_bucket.panw_eks_flow_logs_s3.bucket
}