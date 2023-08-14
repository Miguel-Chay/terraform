# variables para el modulo instancias-EC2

variable "puerto_servidor" {
  description = "Puerto para las instancias EC2"
  type        = number
  default     = 8080

  validation {
    condition     = var.puerto_servidor > 0 && var.puerto_servidor <= 65536
    error_message = "El valor del puerto debe de estar comprendido enter 1 y 65536"
  }
}

variable "tipo_instancia" {
  description = "Tipo las instancias EC2"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "identificador de la AMI"
  type        = string
}

variable "servidores" {
  description = "Mapa de servidores con nombres y AZs"

  type = map(object({
    nombre    = string
    subnet_id = string
    })
  )

}


variable "entorno" {
  description = "Entorno en el que estamos trabajando"
  type        = string
  default     = ""
}