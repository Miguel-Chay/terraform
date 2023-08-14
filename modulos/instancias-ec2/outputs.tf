output "instancia_ids" {
    description = "Valores de todas los id de las instancias"
    value = [for servidor in aws_instance.servidor: servidor.id]
  
}