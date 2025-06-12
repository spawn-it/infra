variable "host_aws_access_key_id" {
  description = "AWS Access Key ID from the host, to be passed to the backend container."
  type        = string
  sensitive   = true
  default     = ""
}

variable "host_aws_secret_access_key" {
  description = "AWS Secret Access Key from the host, to be passed to the backend container."
  type        = string
  sensitive   = true
  default     = ""
}

variable "host_aws_default_region" {
  description = "AWS Default Region from the host."
  type        = string
  default     = "eu-central-1"
}

variable "instances" {
  description = "Map of container instance configurations"
  type = map(object({
    provider       = string
    container_name = string
    image          = string
    ports          = map(string)
    env_vars       = map(string)
    command        = list(string)
    has_volume     = optional(bool, false)
    network_name   = string
    acces_to_docker = optional(bool, false)
  }))
}
