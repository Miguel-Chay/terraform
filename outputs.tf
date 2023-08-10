output "dns_publica_serv_1" {
    description = "DNS publica del servidor"
    value = "http://${aws_instance.mi_servidor_1.public_dns}:8080"   
}

output "dns_publica_serv_2" {
    description = "DNS publica del servidor"
    value = "http://${aws_instance.mi_servidor_2.public_dns}:8080"
}

output "dns_load_balancee" {
    description = "DNS publica del load balancer"
    value = "http://${aws_lb.alb.dns_name}"
}


# output "ipv4_del_servidor" {
#     description = "ipv4 del servidor"
#     value = aws_instance.mi_servidor.public_ip
# }