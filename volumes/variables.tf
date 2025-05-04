variable "volumes" {
  description = "Configuration of the volumes to be created"
  type = list(object({
    provider   = string
    volume_for = string
  }))
  default = [
    {
      provider   = "docker"
      volume_for = "spawn-it-s3"
    },
    {
      provider   = "docker"
      volume_for = "spawn-it-authentik-db"
    }
  ]
}