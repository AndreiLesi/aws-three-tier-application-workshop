#########################################
# EC2 Instance Role
#########################################
resource "aws_iam_instance_profile" "ec2InstanceRole" {
  name = "ec2InstanceRole"
  role = aws_iam_role.ec2InstanceRole.name
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ec2InstanceRole" {
  name               = "ec2InstanceRole"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "SSM" {
  role       = aws_iam_role.ec2InstanceRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "S3" {
  role       = aws_iam_role.ec2InstanceRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

#########################################
# Internet Facing LB
#########################################


resource "aws_security_group" "internet_loadbalancer" {
  name        = "${local.name}-internet-lb"
  description = "Allow HTTP inbound traffic"
  vpc_id      = module.vpc.vpc_id
  tags = {
    Name = "${local.name}-internet-lb"
  }
}

resource "aws_vpc_security_group_ingress_rule" "internet_lb_allow_http" {
  security_group_id = aws_security_group.internet_loadbalancer.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}


resource "aws_vpc_security_group_egress_rule" "internet_lb_allow_outbound" {
  security_group_id = aws_security_group.internet_loadbalancer.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


#########################################
# Web Tier SG
#########################################
resource "aws_security_group" "web_tier_sg" {
  name        = "${local.name}-web-tier"
  description = "Allow HTTP inbound traffic from internet facing LB"
  vpc_id      = module.vpc.vpc_id
  tags = {
    Name = "${local.name}-web-tier"
  }
}

resource "aws_vpc_security_group_ingress_rule" "web_tier_ingress_internet_lb" {
  security_group_id            = aws_security_group.web_tier_sg.id
  referenced_security_group_id = aws_security_group.internet_loadbalancer.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

resource "aws_vpc_security_group_egress_rule" "web_tier_allow_outbound" {
  security_group_id = aws_security_group.web_tier_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
#########################################
# Internal LB SG
#########################################
resource "aws_security_group" "internal_lb_sg" {
  name        = "${local.name}-internal-lb"
  description = "Allow HTTP inbound traffic from the web tier sg"
  vpc_id      = module.vpc.vpc_id
  tags = {
    Name = "${local.name}-internal-lb"
  }
}

resource "aws_vpc_security_group_ingress_rule" "internal_lb_ingress_web_tier_sg" {
  security_group_id            = aws_security_group.internal_lb_sg.id
  referenced_security_group_id = aws_security_group.web_tier_sg.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}


resource "aws_vpc_security_group_egress_rule" "internal_lb_allow_outbound" {
  security_group_id = aws_security_group.internal_lb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
#########################################
# Private Instance SG
#########################################
resource "aws_security_group" "private_instance_sg" {
  name        = "${local.name}-private-instance-sg"
  description = "Allow HTTP inbound traffic from the web tier sg"
  vpc_id      = module.vpc.vpc_id
  tags = {
    Name = "${local.name}-private-instance-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "private_instance_sg_allow_internal_lb" {
  security_group_id            = aws_security_group.private_instance_sg.id
  referenced_security_group_id = aws_security_group.internal_lb_sg.id
  from_port                    = 4000
  ip_protocol                  = "tcp"
  to_port                      = 4000
}

resource "aws_vpc_security_group_egress_rule" "private_instance_sg_allow_outbound" {
  security_group_id = aws_security_group.private_instance_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
#########################################
# DB Security Group
#########################################
resource "aws_security_group" "db_sg" {
  name        = "${local.name}-db-sg"
  description = "Allow Aurora Traffic from private instance sg"
  vpc_id      = module.vpc.vpc_id
  tags = {
    Name = "${local.name}-db-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "db_sg_allow_internal_lb" {
  security_group_id            = aws_security_group.db_sg.id
  referenced_security_group_id = aws_security_group.private_instance_sg.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306
}
