puerto_lb = 80
puerto_servidor = 8080
tipo_instancia = "t2.medium"

# COMANDO PARA COLOCAR ESTAS VARIABLES
# terraform plan -var-file="t2medium.tfvars"
# SI EL FICHERO SE LLAMA terraform.tfvars o tiene la terninacion .auto.tfvars/.auto.tfvars.json TOMARA LAS VARIABLES SIN TENER QUE PASAR EL FLAG -var-file