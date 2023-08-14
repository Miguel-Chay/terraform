# main con logica para el modulo


# DEFINE UNA INSTANCIA EC2 CON AMI UBUNTU
resource "aws_instance" "servidor" {
  # Ubuntu Server 22.04 LTS (HVM), SSD Volume Type
  for_each = var.servidores

  ami                    = var.ami_id
  instance_type          = var.tipo_instancia
  subnet_id              = each.value.subnet_id //each.key es ser-1 p ser-2
  vpc_security_group_ids = [aws_security_group.mi_grupo_de_seguridad.id]

  user_data = <<-EOF
                #!/bin/bash
                echo "Hola soy! ${each.value.nombre}" > index.html 
                nohup busybox httpd -f -p 8080 & 
                EOF

  tags = {
    Name = "servidor-1"
  }
} 

# DEFINE UN GRUPO DE SEGURIDAD CON ACCESO AL PUERTO var.puerto_servidor (8080)
resource "aws_security_group" "mi_grupo_de_seguridad" {
  name = "servidores-sg-${var.entorno}"

  ingress {
    cidr_blocks     = ["0.0.0.0/0"]
    description     = "Acceso al puerto 8080 desde el exterior"
    from_port       = var.puerto_servidor
    to_port         = var.puerto_servidor
    protocol        = "tcp"
  }

}
