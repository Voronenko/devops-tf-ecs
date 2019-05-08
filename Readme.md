

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