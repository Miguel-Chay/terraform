# Terraform se basa en plugins, de los cuales los más importantes son los providers
# Un resource es un bloque de código que describe uno o más objetos en nuestra infraestructura

provider "aws" {
  region = local.region
}

locals {
  region = "us-east-1"
  ami    = var.ubuntu_ami[local.region]
  entorno = "prod"
}


# DATA SOURCE QUE OBTIENE EL ID DEL AZ US-EAST-1A
data "aws_subnet" "public_subnet" {
  for_each          = var.servidores
  availability_zone = "${local.region}${each.value.az}"
}


module "servidores_ec2" {
  source = "../../modulos/instancias-ec2"

  puerto_servidor = 8080
  tipo_instancia  = "t2.micro"
  ami_id          = local.ami
  servidores = {
    for id_ser, datos in var.servidores :
    id_ser => { nombre = datos.nombre, subnet_id = data.aws_subnet.public_subnet[id_ser].id }
  }
  entorno = local.entorno
}

module "loadbalancer" {
  source          = "../../modulos/loadbalancer"
  subnet_ids      = [for subnet in data.aws_subnet.public_subnet : subnet.id]
  instancia_ids   = module.servidores_ec2.instancia_ids
  puerto_lb       = 80
  puerto_servidor = 8080
  entorno = local.entorno

}
