variable "app_image" {
  description = "Image to run"
  default     = "voronenko/docker-sample-image:7777"
}

// on fargate below to should match
variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 7777
}

variable "app_port_host" {
  description = "Port exposed on host for this container"
  default     = 7777
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 1
}

variable "app_port_public" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 8080
}

# Fargate constants
// memory options depend on cpu options, and cpu options are fixed set.

variable "fargate_cpu_min" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "256"
}

variable "fargate_memory_min" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "512"
}

# /Fargate constants
