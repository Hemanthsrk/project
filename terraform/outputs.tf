output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "minikube_instance_ip" {
  value = aws_instance.minikube.public_ip
}

