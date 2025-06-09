variable "volumes" {
  description = "Configuration of the volumes to be created"
  type = list(object({
    provider   = string
    volume_for = string
  }))
}