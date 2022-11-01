resource "aws_iam_role" "panw_eks_iam_role" {
 name = "panw-eks-iam-role"

 path = "/"

 assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
  {
   "Effect": "Allow",
   "Principal": {
    "Service": "eks.amazonaws.com"
   },
   "Action": "sts:AssumeRole"
  }
 ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
 role    = aws_iam_role.panw_eks_iam_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly-EKS" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
 role    = aws_iam_role.panw_eks_iam_role.name
}

resource "aws_eks_cluster" "panw_eks_cluster" {
 name = var.eks_cluster_name
 role_arn = aws_iam_role.panw_eks_iam_role.arn

 vpc_config {
  subnet_ids = aws_subnet.panw_eks_sub[*].id
  endpoint_public_access = true
  public_access_cidrs = ["0.0.0.0/0"]
 }

#  depends_on = [
#   aws_iam_role.eks-iam-role,
#  ]
}

resource "aws_iam_role" "panw_workernodes_role" {
  name = "panw-workernode-group-role"
 
  assume_role_policy = jsonencode({
   Statement = [{
    Action = "sts:AssumeRole"
    Effect = "Allow"
    Principal = {
     Service = "ec2.amazonaws.com"
    }
   }]
   Version = "2012-10-17"
  })
 }
 
 resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role    = aws_iam_role.panw_workernodes_role.name
 }
 
 resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role    = aws_iam_role.panw_workernodes_role.name
 }
 
 resource "aws_iam_role_policy_attachment" "EC2InstanceProfileForImageBuilderECRContainerBuilds" {
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
  role    = aws_iam_role.panw_workernodes_role.name
 }
 
 resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role    = aws_iam_role.panw_workernodes_role.name
 }


 resource "aws_eks_node_group" "worker_node_group" {
  cluster_name      = aws_eks_cluster.panw_eks_cluster.name
  node_group_name   = "panw-workernodes"
  node_role_arn     = aws_iam_role.panw_workernodes_role.arn
  subnet_ids        = aws_subnet.panw_eks_sub[*].id
  instance_types    = ["t3.xlarge"]

    tags = {
    Name   = "${var.unique_prefix}-panw-eks-worker"
    DND = "DND"
    StatusDND = "DND"
  }
 
  scaling_config {
   desired_size = 1
   max_size   = 1
   min_size   = 1
  }

  
 
  depends_on = [
   aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
   aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
   aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]


 }