variable "networks" {
  description = "Configuration of the networks to be created"
  type = list(object({
    provider     = string
    network_name = string
  }))
}