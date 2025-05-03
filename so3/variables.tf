variable "config" {
  type = object({
    image         = string
    root_user     = string
    root_password = string
    api_port      = number
    console_port  = number
    volume_path   = string
  })
}
