# Terraform se basa en plugins, de los cuales los más importantes son los providers
provider "aws" {
    region = "us-east-1"
}

data "aws_subnet" "az_a" {
    availability_zone = "us-east-1a"
}

data "aws_subnet" "az_b" {
    availability_zone = "us-east-1b"
}
# Un resource es un bloque de código que describe uno o más objetos en nuestra infraestructura
resource "aws_instance" "mi_servidor_1" {
    # Ubuntu Server 22.04 LTS (HVM), SSD Volume Type
    ami             = "ami-053b0d53c279acc90"
    instance_type   = "t2.micro"  
    vpc_security_group_ids = [aws_security_group.mi_grupo_de_seguridad.id]
    subnet_id = data.aws_subnet.az_a.id

    user_data = <<-EOF
                #!/bin/bash
                echo "Hola Mundo!" > index.html 
                nohup busybox httpd -f -p 8080 & 
                EOF

    tags = {
        Name = "servidor-1"
    }
}

resource "aws_instance" "mi_servidor_2" {
    # Ubuntu Server 22.04 LTS (HVM), SSD Volume Type
    ami             = "ami-053b0d53c279acc90"
    instance_type   = "t2.micro"  
    vpc_security_group_ids = [aws_security_group.mi_grupo_de_seguridad.id]
    subnet_id = data.aws_subnet.az_b.id

    user_data = <<-EOF
                #!/bin/bash
                echo "Hola Pichula!" > index.html 
                nohup busybox httpd -f -p 8080 & 
                EOF

    tags = {
        Name = "servidor-2"
    }
}

resource "aws_security_group" "mi_grupo_de_seguridad" {
    name = "primer-servidor-sg"

    ingress{
        security_groups = [aws_security_group.alb.id]
        description = "Acceso al puerto 8080 desde el exterior"
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
    }
  
}

resource "aws_lb" "alb" {
    load_balancer_type = "application"
    name = "terraform-alb"
    security_groups = [aws_security_group.alb.id]
    subnets = [data.aws_subnet.az_a.id,data.aws_subnet.az_b.id]
}


resource "aws_security_group" "alb" {
    name = "alb-sg"
    ingress{
        cidr_blocks = [ "0.0.0.0/0" ]
        description = "Acceso al puerto 80 desde el exterior"
        from_port = 80
        to_port = 80
        protocol = "tcp"
    }
    egress{
        cidr_blocks = [ "0.0.0.0/0" ]
        description = "Acceso al puerto 8080 desde nuestros servidore"
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
    }
}

data "aws_vpc" "default" {
    default = true
}
resource "aws_lb_target_group" "this" {
    name = "terraform-alb-target-group"
    port = 80
    vpc_id = data.aws_vpc.default.id   
    protocol = "HTTP"

    health_check {
      enabled = true
      matcher = "200"
      path ="/"
      port = "8080"
      protocol = "HTTP"
    }
}

resource "aws_lb_target_group_attachment" "servidor_1" {
    target_group_arn = aws_lb_target_group.this.arn
    target_id = aws_instance.mi_servidor_1.id
    port = 8080
}

resource "aws_lb_target_group_attachment" "servidor_2" {
    target_group_arn = aws_lb_target_group.this.arn
    target_id = aws_instance.mi_servidor_2.id
    port = 8080
}

resource "aws_lb_listener" "this" {
    load_balancer_arn = aws_lb.alb.arn
    port = 80
    protocol = "HTTP"
    
    default_action {
      target_group_arn = aws_lb_target_group.this.arn
      type = "forward"
    }
  
}