variable "app_port_traefik_http" {
  description = "Port exposed by the traefik image to route http traffic"
  default     = 80
}

variable "app_port_traefik_https" {
  description = "Port exposed by the traefik image to route https traffic"
  default     = 443
}

variable "app_port_traefik_dashboard" {
  description = "Port exposed by the traefik image to serve admin dashboard"
  default     = 8080
}

// not used debuging only
variable "app_port_traefik_debug" {
  description = "Port exposed by the traefik image to route traffic"
  default     = 81
}
