variable "so3" {
    description = "Configuration of the SO3 instance"
    type = object({
        container_name = string
        image          = string
        root_user      = string
        root_password  = string
        port           = number
        console_port   = number
        env_vars       = map(string)
    })
}

variable "backend" {
    description = "Configuration du backend Python (FastAPI)"
    type = object({
        container_name = string
        image          = string
        port           = number
        env_vars       = map(string)
    })
}
