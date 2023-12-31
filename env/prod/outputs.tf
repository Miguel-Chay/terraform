# output "dns_publica_servidores" {
#     description = "DNS publica del servidor"
#     value = [for servidor in aws_instance.servidor : "http://${servidor.public_dns}:${var.puerto_servidor}"]
# }

output "dns_load_balancer" {
    description = "DNS publica del load balancer"
    value = module.loadbalancer.dns_load_balancee
}


# output "ipv4_del_servidor" {
#     description = "ipv4 del servidor"
#     value = aws_instance.mi_servidor.public_ip
# }