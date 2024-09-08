#########################################
# Internal LB Target Group
#########################################

resource "aws_lb_target_group" "appTier" {
  name     = "AppTierTargetGroup"
  port     = 4000
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  health_check {
    path     = "/health"
    protocol = "HTTP"
  }
}

#########################################
# Internal LB
#########################################
resource "aws_lb" "internal" {
  name               = "app-tier-internal-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.internal_lb_sg.id]
  subnets            = module.vpc.private_subnets

  enable_deletion_protection = false

}

resource "aws_lb_listener" "internal" {
  load_balancer_arn = aws_lb.internal.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.appTier.arn
  }
}

#########################################
# External LB Target Group
#########################################
resource "aws_lb_target_group" "webTier" {
  name     = "WebTierTargetGroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  health_check {
    path     = "/health"
    protocol = "HTTP"
  }
}

#########################################
# External LB
#########################################
resource "aws_lb" "external" {
  name               = "app-tier-external-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.internet_loadbalancer.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false

}

resource "aws_lb_listener" "external" {
  load_balancer_arn = aws_lb.external.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webTier.arn
  }
}
