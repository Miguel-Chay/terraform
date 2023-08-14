# main con logica para el modulo
 
# LOAD BALANCER PUBLICO CON DOS INSTANCIAS
resource "aws_lb" "alb" {
  load_balancer_type = "application"
  name               = "terraform-alb-${var.entorno}"
  security_groups    = [aws_security_group.alb.id]
#   subnets            = [data.aws_subnet.az_a.id, data.aws_subnet.az_b.id]
  subnets            = var.subnet_ids
}

# SECURITY GROUP PARA EL LOAD BALANCER
resource "aws_security_group" "alb" {
  name = "alb-sg-${var.entorno}"
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
  name     = "terraform-alb-${var.entorno}"
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
resource "aws_lb_target_group_attachment" "servidor" {
  count = length(var.instancia_ids)


  target_group_arn = aws_lb_target_group.this.arn
  target_id        = element(var.instancia_ids, count.index)
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