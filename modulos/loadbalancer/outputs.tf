output "dns_load_balancee" {
    description = "DNS publica del load balancer"
    value = "http://${aws_lb.alb.dns_name}:${var.puerto_lb}"
}
