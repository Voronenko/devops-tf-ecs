// We keen to use dynamic port allocation, i.e. hostPort: 0
// BUT
//
// Fargate only supports network mode ‘awsvpc’

resource "aws_ecs_task_definition" "app" {
  family                   = local.app_name
  cpu                      = var.fargate_cpu_min
  memory                   = var.fargate_memory_min

  container_definitions = <<DEFINITION
[
  {
    "cpu": ${var.fargate_cpu_min},
    "image": "${var.app_image}",
    "memory": ${var.fargate_memory_min},
    "name": "${local.app_name}",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "hostPort": ${var.app_port_host},
        "protocol": "tcp",
        "containerPort": ${var.app_port}
      }
    ],
    "dockerLabels": {
      "traefik.frontend.rule": "Host:app.domain.local",
      "traefik.enable": "true"
    },
    "environment": [ ]
  }
]
DEFINITION
}

resource "aws_ecs_service" "app" {
  name            = "${local.app_name}-ecs-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.app_count

  load_balancer {
    target_group_arn = aws_alb_target_group.app.id
    container_name   = local.app_name
    container_port   = var.app_port
  }

  depends_on = [
    "aws_alb_listener.front_end_app",
  ]
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end_app" {
  load_balancer_arn = aws_alb.alb_main.id
  port              = var.app_port_public
  protocol          = "HTTP"


  default_action {
    target_group_arn = aws_alb_target_group.app.id
    type             = "forward"
  }
}

//For Target type, choose Instance or IP.
//Important: If your service's task definition uses awsvpc network mode
//(required for the AWS Fargate launch type),
//you must choose IP as the target type.
//This is because tasks that use the awsvpc network mode are associated with
//an elastic network interface, not an Amazon Elastic Compute Cloud (Amazon EC2) instance.

resource "aws_alb_target_group" "app" {
  name            = "${local.app_name}-app"

//  The port on which targets receive traffic, unless overridden when registering a specific target.
//  Required when target_type is instance or ip. Does not apply when target_type is lambda.
  port        = var.app_port_host
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
  }

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 60
    interval            = 300
    matcher             = "200-299,401-404"
  }

  tags = {
    Name = "${local.readable_env_name}-app"
    env = local.env
  }
}

