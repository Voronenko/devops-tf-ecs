resource "aws_ecs_cluster" "main" {
  name = local.ecs_cluster_name
}