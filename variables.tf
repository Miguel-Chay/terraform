variable "puerto_servidor" {
  description = "Puerto para las instancias EC2"
  type        = number
  default     = 8080

  validation {
    condition = var.puerto_servidor>0 && var.puerto_servidor<=65536
    error_message = "El valor del puerto debe de estar comprendido enter 1 y 65536"
  }
}

variable "puerto_lb" {
  description = "Puerto para el Load Balancer"
  type        = number
  default     = 80
}

variable "tipo_instancia" {
  description = "Tipo las instancias EC2"
  type        = string
  default     = "t2.micro"
}


variable "ubuntu_ami" {
    description = "AMI por region"
    type = map(string)
    
    default = {
        us-east-1 = "ami-053b0d53c279acc90" #oregon
        us-east-2= "ami-024e6efaf93d85776"  #ohio
    }
  
}


variable "servidores" {
  description = "Mapa de servidores con nombres y AZs"

  type = map(object({
        nombre = string
        az=string
    })
  )

    default = {
        "ser-1" = {nombre = "servidor-1", az = "a"}
        "ser-2" = {nombre = "servidor-2", az = "b"}
        "ser-3" = {nombre = "servidor-3", az = "c"}
    }

}