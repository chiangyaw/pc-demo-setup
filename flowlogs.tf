resource "aws_flow_log" "panw_eks_flow_logs" {
  log_destination      = aws_s3_bucket.panw_eks_flow_logs_s3.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.panw_eks_vpc.id
}

resource "aws_s3_bucket" "panw_eks_flow_logs_s3" {
  bucket = "${var.unique_prefix}-panw-eks-fl-s3"
}