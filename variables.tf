variable "project"{
    description = "Plataforma de Participacion Ciudadana"
    type = string
    default = "ppc"
}

variable "environment"{
    description = "Entorno de desarrollo de la plataforma de participacion ciudadana"
    type = string
    default = "dev"
}

variable "location"{
    description = "Ubicacion de los recursos de Azure"
    type = string
    default = "East US 2"
}

variable "password"{
    description = "sqlserver password"
    type = string
    sensitive = true
}

variable "tags"{
    description = "all tags used"
    default = {
        environment = "dev"
        project = "ppc"
        created_by = "terraform"
    }
}