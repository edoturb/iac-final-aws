output "vpc_id" {
  value = module.network.vpc_id
}

output "instance_public_ip" {
  description = "IP publica fija (Elastic IP) de la instancia demo."
  value       = aws_eip.demo.public_ip
}
