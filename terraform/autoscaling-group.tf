#########################################
# Internal ASG
#########################################
data "aws_launch_template" "appTier" {
  name = "AppTierLaunchTemplate"
}

resource "aws_autoscaling_group" "appTier" {
  name                = "AppTierASG"
  vpc_zone_identifier = module.vpc.private_subnets
  health_check_type   = "ELB"
  desired_capacity    = 2
  max_size            = 2
  min_size            = 2
  target_group_arns   = [aws_lb_target_group.appTier.arn]
  force_delete        = true
  launch_template {
    id      = data.aws_launch_template.appTier.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "AppTier"
    propagate_at_launch = true
  }
}
#########################################
# External ASG
#########################################
data "aws_launch_template" "webTier" {
  name = "WebTierLaunchTemplate"
}

resource "aws_autoscaling_group" "webTier" {
  name                = "WebTierASG"
  vpc_zone_identifier = module.vpc.public_subnets
  health_check_type   = "ELB"
  desired_capacity    = 2
  max_size            = 2
  min_size            = 2
  target_group_arns   = [aws_lb_target_group.webTier.arn]
  force_delete        = true
  launch_template {
    id      = data.aws_launch_template.webTier.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "WebTier"
    propagate_at_launch = true
  }
}
