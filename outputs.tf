output "dns_publica_serv_1" {
    description = "DNS publica del servidor"
    value = "http://${aws_instance.mi_servidor_1.public_dns}:${var.puerto_servidor}"   
}

output "dns_publica_serv_2" {
    description = "DNS publica del servidor"
    value = "http://${aws_instance.mi_servidor_2.public_dns}:${var.puerto_servidor}"
}

output "dns_load_balancee" {
    description = "DNS publica del load balancer"
    value = "http://${aws_lb.alb.dns_name}:${var.puerto_lb}"
}


# output "ipv4_del_servidor" {
#     description = "ipv4 del servidor"
#     value = aws_instance.mi_servidor.public_ip
# }