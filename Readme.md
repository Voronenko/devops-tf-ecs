

Provisioning user recommended to have:

arn:aws:iam::aws:policy/AmazonECS_FullAccess


Example ecs config for private images

```sh
#!/bin/bash
cat > /etc/ecs/ecs.config << EOF
ECS_CLUSTER=test-cluster
ECS_ENGINE_AUTH_TYPE=dockercfg
ECS_ENGINE_AUTH_DATA={"https://index.docker.io/v1/":{"auth":"SOME TOKEN","email":"SOME DOCKER HUB EMAIL"}}
EOF
```

most simple case

```sh
#!/bin/bash
echo ECS_CLUSTER=${ecs_cluster_name} >> /etc/ecs/ecs.config
```

## Using aws cli

Get information about clusters  running

```sh
aws ecs describe-clusters
CLUSTERS        0       arn:aws:ecs:us-east-1:XXX:cluster/default      default 0       0       0       ACTIVE

```
or

```
aws ecs list-clusters
CLUSTERARNS     arn:aws:ecs:us-east-1:XXX:cluster/ecs-default
```

Get information about instances serving the cluster

```
aws ecs list-container-instances --cluster ecs-default
CONTAINERINSTANCEARNS   arn:aws:ecs:us-east-1:XXX:container-instance/3716fa63-0e9b-42b0-b10c-ebc7842580ca
CONTAINERINSTANCEARNS   arn:aws:ecs:us-east-1:XXX:container-instance/5360ccef-4478-4b2c-9ac0-9d8bf76200f2

```
