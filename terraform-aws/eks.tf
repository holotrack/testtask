resource "aws_iam_role" "hello-cluster" {
  name = "terraform-eks-hello-cluster"

  assume_role_policy = <<POLICY
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
POLICY
}

resource "aws_iam_role_policy_attachment" "hello-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.hello-cluster.name
}

resource "aws_iam_role_policy_attachment" "hello-cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.hello-cluster.name
}

resource "aws_security_group" "hello-cluster" {
  name        = "terraform-eks-hello-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.hello.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-eks-hello"
  }
}

resource "aws_eks_cluster" "hello" {
  name     = var.cluster_name
  role_arn = aws_iam_role.hello-cluster.arn

  vpc_config {
    subnet_ids         = aws_subnet.hello[*].id
  }

  depends_on = [
    aws_iam_role_policy_attachment.hello-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.hello-cluster-AmazonEKSVPCResourceController,
  ]
}
