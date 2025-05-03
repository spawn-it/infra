variable "so3" {
  description = "Configuration du serveur S3 compatible"
  type = map(object({
    image                = string
    root_user            = string
    root_password        = string
    api_port             = number
    console_port         = number
    volume_path          = string
  }))
}
