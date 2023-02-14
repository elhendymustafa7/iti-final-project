### SECURITY 

resource "aws_security_group" "eks-cluster-sg" {
  name        = "eks-cluster-sg"
  description = "Security Group for Control Plane"
  vpc_id      = aws_vpc.eks_vpc.id

  tags = {
    Name = "eks-cluster-sg"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "eks-cluster-ingress-https" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow Inbound HTTPS Traffic to Control Plane"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.eks-cluster-sg.id
  to_port           = 443
  type              = "ingress"
}
resource "aws_security_group_rule" "eks-cluster-ingress-http" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow Inbound HTTP Traffic to Control Plane"
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.eks-cluster-sg.id
  to_port           = 80
  type              = "ingress"
}

resource "aws_security_group" "eks-node-sg" {
  name        = "eks-node-sg"
  description = "Security Group for Worker Nodes"
  vpc_id      = aws_vpc.eks_vpc.id

  tags = {
    Name                                        = "eks-node-sg"
    "kubernetes.io/cluster/eks-cluster" = "owned"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "eks-node-ingress-self" {
  description              = "Allow worker nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks-node-sg.id
  source_security_group_id = aws_security_group.eks-node-sg.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks-node-ingress-cluster" {
  description              = "Allow worker nodes to receive inbound traffic from control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks-node-sg.id
  source_security_group_id = aws_security_group.eks-cluster-sg.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks-node-ingress-https" {
  description              = "Allow Control Plane to receive inbound traffic from Worker Nodes"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks-cluster-sg.id
  source_security_group_id = aws_security_group.eks-node-sg.id
  to_port                  = 443
  type                     = "ingress"
}