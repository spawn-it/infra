variable "config" {
    description = "Configuration du backend Python (FastAPI)"
    type = object({
        container_name = string
        image          = string
        internal_port  = string
        external_port  = number
        env_vars       = map(string)
    })
}
