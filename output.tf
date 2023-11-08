//we are export our dns_name of our load balancer and endpoint of our mysql db

output "production_server_ip" {
  value = aws_instance.Production.public_ip
}

output "DR_server_ip" {
  value = aws_instance.DR.public_ip
}

output "production_loadbalancer_DNS" {
  value = aws_lb.Production_LB.dns_name
}

output "DR_loadbalancer_DNS" {
  value = aws_lb.DR_LB.dns_name
}

output "mysql_server_endpoint" {
  value = aws_db_instance.mysql_db.endpoint
}