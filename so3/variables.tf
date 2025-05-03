variable "config" {
    description = "Configuration of the SO3 instance"
    type = object({
        container_name = string
        image          = string
        root_user      = string
        root_password  = string
        external_port  = number
        console_port   = number
        env_vars       = map(string)
    })
}
