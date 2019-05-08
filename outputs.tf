locals {

  aws_commons_yml = <<YAML

ecsServiceRole_arn: "${aws_iam_role.ecs_service_role.arn}"
ecsInstanceRole_arn: "${aws_iam_role.ecs_instance_role.arn}"

aws_region: "${local.region}"

default_autoscaling_min_size: 1
default_autoscaling_desired_capacity: 1
default_autoscaling_max_size: 4


ec2_key: "${var.ec2_key}"

ecs_cluster_name: "${aws_ecs_cluster.ecs_cluster.name}" # ALLOWED TO BE SET EXTERNALLY
# ecs_engine_auth_data_token: "SPECIFY"  # todo: SET IT FROM SECURE VARS , cat ~/.docker/config.json
# ecs_engine_auth_data_email: "SPECIFY"  # todo:  SET IT FROM SECURE VARS


option_use_auto_scaling_group: ${var.option_use_auto_scaling_group}
option_use_yml_config: false  # set true for coreos - causes /etc/ecs/ecs.config creation
option_use_manual_cluster_instances: ${var.option_use_manual_cluster_instances}

YAML

}