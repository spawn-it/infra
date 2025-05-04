variable "image" {
  description = "Docker image to use"
  type        = string
}

variable "container_name" {
  description = "Name of the Docker container"
  type        = string
}

variable "env_vars" {
  description = "Environment variables for the container"
  type        = map(string)
  default     = {}
}

variable "command" {
  description = "Command to run in the container"
  type        = list(string)
  default     = []
}

variable "ports" {
  description = "Ports mapping (internal -> external)"
  type        = map(string)
  default     = {}
}

variable "has_volume" {
  description = "Flag to indicate if the container has a volume"
  type        = bool
  default     = false
}

variable "volume_name" {
  type        = string
  description = "The Docker volume that must exist"
}