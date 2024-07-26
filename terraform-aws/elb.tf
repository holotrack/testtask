resource "aws_security_group" "ingress-sg" {
  name        = "ingress-sg"
  description = "Port 80 and 443 from all world"
  vpc_id      = aws_vpc.hello.id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    description ="worldwide"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    description ="worldwide"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "ingress" {
  name               = "${var.cluster_name}-ingress"
  load_balancer_type = "application"

  subnets         = aws_subnet.hello[*].id
  security_groups = [aws_security_group.ingress-sg.id]

  ## check alb.ingress.kubernetes.io/scheme (internal: true, internet-facing: false)
  internal = false

  ## check alb.ingress.kubernetes.io/ip-address-type (ipv4, dualstack)
  ip_address_type = "ipv4"

  preserve_host_header = false

  ## All tags must be the same as created by aws-load-balancer-controller

  tags = {
    ManagedBy                                   = "AWS Load Balancer Controller"
    "elbv2.k8s.aws/cluster"                     = var.cluster_name
    "ingress.k8s.aws/resource"                  = "LoadBalancer"
    "ingress.k8s.aws/stack"                     = "${var.cluster_name}-ingress"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  ## Security groups are managed by AWS Load Balancer Controller
  ## then must be ignored by Terraform.

  lifecycle {
    ignore_changes = [security_groups]
  }
}

resource "aws_lb_listener" "http-80" {
  load_balancer_arn = aws_lb.ingress.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    order = 1
    type  = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      status_code  = "404"
    }
  }

  tags = {
    ManagedBy                                   = "AWS Load Balancer Controller"
    "elbv2.k8s.aws/cluster"                     = var.cluster_name
    "ingress.k8s.aws/resource"                  = "80"
    "ingress.k8s.aws/stack"                     = "${var.cluster_name}-ingress"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

output "alb_ingress_arn" {
  description = "ARN of ALB"
  value       = aws_lb.ingress.arn
}

## Target Group makes ALB persistent: it cannot be removed until the target
## registered.

resource "aws_lb_target_group" "ingress" {
  name        = aws_lb.ingress.name
  target_type = "alb"
  port        = aws_lb_listener.http-80.port
  protocol    = "TCP"
  vpc_id      = aws_lb.ingress.vpc_id
}

resource "aws_lb_target_group_attachment" "ingress" {
  target_group_arn = aws_lb_target_group.ingress.arn
  target_id        = aws_lb.ingress.arn
  port             = aws_lb_listener.http-80.port
}