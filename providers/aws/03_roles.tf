data "aws_iam_policy_document" "ecs_service_policy" {
  statement {
    actions = [
      "sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_service_role" {
  name = "ecs_service_role_${local.ecs_cluster_name}"
  path = "/"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_service_policy.json}"
}

resource "aws_iam_role_policy_attachment" "ecs_service_role_attachment" {
  role = "${aws_iam_role.ecs_service_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}


data "aws_iam_policy_document" "ecs_instance_policy" {
  statement {
    actions = [
      "sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_instance_role" {
  name = "ecs_instance_role_${local.ecs_cluster_name}"
  path = "/"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_instance_policy.json}"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_attachment" {
  role = "${aws_iam_role.ecs_instance_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecs_instance_profile_${local.ecs_cluster_name}"
  path = "/"
  role = "${aws_iam_role.ecs_instance_role.id}"
}