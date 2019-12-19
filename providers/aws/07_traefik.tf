#https://docs.traefik.io/v1.7/configuration/backends/ecs/

data "aws_iam_policy_document" "traefik_ecs_read_policy_document" {
  statement {
    sid = "TraefikECSReadAccess"

    effect = "Allow"

    actions = [
      "ecs:ListClusters",
      "ecs:DescribeClusters",
      "ecs:ListTasks",
      "ecs:DescribeTasks",
      "ecs:DescribeContainerInstances",
      "ecs:DescribeTaskDefinition",
      "ec2:DescribeInstances",
    ]

    resources = ["*"]
  }

}

resource "aws_iam_policy" "traefik_ecs_read_policy" {
  name   = "traefik_ecs_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.traefik_ecs_read_policy_document.json
}


resource "aws_iam_role" "traefik_task_role" {
  name               = "traefik_task_role"
  //todo replace with smth useful
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "traefik_task_role_policy_attachment" {
  role       = aws_iam_role.traefik_task_role.name
  policy_arn = aws_iam_policy.traefik_ecs_read_policy.arn
}

# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
resource "aws_ecs_task_definition" "traefik_definition" {
  family                   = "${local.app_name}-traefik"
#  network_mode             = "awsvpc"
  cpu                      = 512  # Should be as minimum sum of CPU values of children
  memory                   = 1024 # Should be as minimum sum of Memory values  of children
  task_role_arn            = aws_iam_role.traefik_task_role.arn
#  execution_role_arn = "${aws_iam_role.traefik_execution_role.arn}"

  container_definitions = <<DEFINITION
[
    {
        "name": "traefik-proxy",
        "image": "traefik:v1.7-alpine",
        "command": [
          "--ping",
          "--ping.entrypoint=http",
          "--ecs",
          "--ecs.clusters=${aws_ecs_cluster.main.name}",
          "--ecs.exposedbydefault=false",
          "--ecs.region=${local.aws_region}",
          "--defaultentrypoints=http",
          "--entryPoints=Name:http Address::${var.app_port_traefik_http}",
          "--entryPoints=Name:traefik Address::${var.app_port_traefik_https}",
          "--loglevel=DEBUG"
        ],
        "essential": true,
        "environment": [
            {
              "name": "AWS_REGION",
              "value": "${local.aws_region}"
            }
        ],
        "portMappings": [
            {
                "protocol": "tcp",
                "containerPort": ${var.app_port_traefik_http},
                "hostPort": ${var.app_port_traefik_http}
            },
            {
                "protocol": "tcp",
                "containerPort": ${var.app_port_traefik_https},
                "hostPort": ${var.app_port_traefik_https}
            }
        ],
        "cpu": 256,
        "memoryReservation": 512
    },
    {
        "name": "traefik-dashboard",
        "image": "traefik:v1.7-alpine",
        "command": [
          "--api",
          "--api.dashboard",
          "--ecs",
          "--ecs.clusters=${aws_ecs_cluster.main.name}",
          "--ecs.exposedbydefault=false",
          "--loglevel=DEBUG"
        ],
        "essential": true,
        "environment": [
            {
              "name": "AWS_REGION",
              "value": "${local.aws_region}"
            }
        ],
        "dockerLabels": {
          "traefik.frontend.rule": "Host:traefik.domain.local",
          "traefik.enable": "true"
        },
        "portMappings": [
            {
                "protocol": "tcp",
                "containerPort": ${var.app_port_traefik_dashboard},
                "hostPort": ${var.app_port_traefik_dashboard}
            }
        ],
        "cpu": 256,
        "memoryReservation": 512
    }
]
DEFINITION
}


resource "aws_ecs_service" "traefikservice" {
  name            = "traefik-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.traefik_definition.arn
  desired_count   = 1
  launch_type     = "EC2"

  load_balancer {
    target_group_arn = aws_alb_target_group.traefik_public_http.id
    container_name   = "traefik-proxy"
    container_port   = var.app_port_traefik_http
  }

  depends_on = [
    "aws_alb_listener.traefik_listener_alb_http",
  ]
}



resource "aws_alb_target_group" "traefik_public_http" {
  name            = "${local.ecs_cluster_name}-traefik"
  port        = var.app_port_traefik_http
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"
  tags = {
    Name = "${local.readable_env_name}-traefik"
    env = local.env
  }
  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 60
    interval            = 300
    matcher             = "200-299,401-404"
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "traefik_listener_alb_http" {
  load_balancer_arn = aws_alb.alb_main.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.traefik_public_http.id
    type             = "forward"
  }

  depends_on = ["aws_alb_target_group.traefik_public_http"]
}
