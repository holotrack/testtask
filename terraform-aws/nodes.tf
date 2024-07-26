resource "aws_iam_role" "hello-node" {
  name = "terraform-eks-hello-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "hello-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.hello-node.name
}

resource "aws_iam_role_policy_attachment" "hello-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.hello-node.name
}

resource "aws_iam_role_policy_attachment" "hello-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.hello-node.name
}

resource "aws_eks_node_group" "hello" {
  cluster_name    = aws_eks_cluster.hello.name
  node_group_name = "hello"
  node_role_arn   = aws_iam_role.hello-node.arn
  subnet_ids      = aws_subnet.hello[*].id

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.hello-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.hello-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.hello-node-AmazonEC2ContainerRegistryReadOnly,
  ]
}