
# If you duplicate application load balancer creation in ansible
# Make sure for properites to match, to prevent infrastructure drift

resource "aws_alb" "alb_main" {
  name            = local.ecs_cluster_name
  subnets         = [aws_subnet.pub_subnet1.id, aws_subnet.pub_subnet2.id]
  security_groups = [aws_security_group.vpc_security_groups_elb.id]
  enable_http2    = "true"
  idle_timeout    = 600
  tags = {
    Name = local.readable_env_name
    env = local.env
  }
}
