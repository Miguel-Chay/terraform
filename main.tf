provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "mi_servidor" {
    # Ubuntu Server 22.04 LTS (HVM), SSD Volume Type
    ami             = "ami-053b0d53c279acc90"
    instance_type   = "t2.micro"  
    vpc_security_group_ids = [aws_security_group.mi_grupo_de_seguridad.id]
    
    user_data = <<-EOF
                #!/bin/bash
                echo "Hola Mundo!" > index.html 
                nohup busybox httpd -f -p 8080 & 
                EOF

    tags = {
        Name = "mi-servidor"
    }
}

resource "aws_security_group" "mi_grupo_de_seguridad" {
    name = "primer-servidor-sg"

    ingress{
        cidr_blocks = [ "0.0.0.0/0" ]
        description = "Acceso al puerto 8080 desde el exterior"
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
    }
  
}
