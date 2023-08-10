# Terraform se basa en plugins, de los cuales los más importantes son los providers
# Un resource es un bloque de código que describe uno o más objetos en nuestra infraestructura

provider "aws" {
  region = "us-east-1"
}
# DATA SOURCE QUE OBTIENE EL ID DEL AZ US-EAST-1A
data "aws_subnet" "az_a" {
  availability_zone = "us-east-1a"
}

data "aws_subnet" "az_b" {
  availability_zone = "us-east-1b"
}
# DEFINE UNA INSTANCIA EC2 CON AMI UBUNTU
resource "aws_instance" "mi_servidor_1" {
  # Ubuntu Server 22.04 LTS (HVM), SSD Volume Type
  ami                    = "ami-053b0d53c279acc90"
  instance_type          = var.tipo_instancia
  vpc_security_group_ids = [aws_security_group.mi_grupo_de_seguridad.id]
  subnet_id              = data.aws_subnet.az_a.id

  user_data = <<-EOF
                #!/bin/bash
                echo "Hola Mundo!" > index.html 
                nohup busybox httpd -f -p 8080 & 
                EOF

  tags = {
    Name = "servidor-1"
  }
}
# DEFINE UNA INSTANCIA EC2 CON AMI UBUNTU
resource "aws_instance" "mi_servidor_2" {
  # Ubuntu Server 22.04 LTS (HVM), SSD Volume Type
  ami                    = "ami-053b0d53c279acc90"
  instance_type          = var.tipo_instancia
  vpc_security_group_ids = [aws_security_group.mi_grupo_de_seguridad.id]
  subnet_id              = data.aws_subnet.az_b.id

  user_data = <<-EOF
                #!/bin/bash
                echo "Hola Pichula!" > index.html 
                nohup busybox httpd -f -p ${var.puerto_servidor} & 
                EOF

  tags = {
    Name = "servidor-2"
  }
}

# DEFINE UN GRUPO DE SEGURIDAD CON ACCESO AL PUERTO var.puerto_servidor (8080)
resource "aws_security_group" "mi_grupo_de_seguridad" {
  name = "primer-servidor-sg"

  ingress {
    security_groups = [aws_security_group.alb.id]
    description     = "Acceso al puerto 8080 desde el exterior"
    from_port       = var.puerto_servidor
    to_port         = var.puerto_servidor
    protocol        = "tcp"
  }

}

# LOAD BALANCER PUBLICO CON DOS INSTANCIAS
resource "aws_lb" "alb" {
  load_balancer_type = "application"
  name               = "terraform-alb"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [data.aws_subnet.az_a.id, data.aws_subnet.az_b.id]
}

# SECURITY GROUP PARA EL LOAD BALANCER
resource "aws_security_group" "alb" {
  name = "alb-sg"
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Acceso al puerto ${var.puerto_lb} desde el exterior"
    from_port   = var.puerto_lb
    to_port     = var.puerto_lb
    protocol    = "tcp"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Acceso al puerto ${var.puerto_servidor} desde nuestros servidore"
    from_port   = var.puerto_servidor
    to_port     = var.puerto_servidor
    protocol    = "tcp"
  }
}

# DATA SOURCE PARA OBTENER EL ID DE LA VPC POR DEFECTO
data "aws_vpc" "default" {
  default = true
}

# TARGET GROUP PARA EL LOAD BALANCER
resource "aws_lb_target_group" "this" {
  name     = "terraform-alb-target-group"
  port     = var.puerto_lb
  vpc_id   = data.aws_vpc.default.id
  protocol = "HTTP"

  health_check {
    enabled  = true
    matcher  = "200"
    path     = "/"
    port     = var.puerto_servidor
    protocol = "HTTP"
  }
}

# ATTACHMENT PARA EL SERVIDOR 1
resource "aws_lb_target_group_attachment" "servidor_1" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = aws_instance.mi_servidor_1.id
  port             = var.puerto_servidor
}

# ATTACHMENT PARA EL SERVIDOR 2
resource "aws_lb_target_group_attachment" "servidor_2" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = aws_instance.mi_servidor_2.id
  port             = var.puerto_servidor
}

# LISTENER PARA NUESTRO SERVIDOR
resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.puerto_lb
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.this.arn
    type             = "forward"
  }

}
