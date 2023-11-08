// creating subnet group for our mysql db

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db_subnet_group"
  subnet_ids = [aws_subnet.production.id,aws_subnet.DR.id]
}

// creating security group for our mysql db

resource "aws_security_group" "DB_security_group"{
    name = "DB_security_group"
    description = "allow mysql traffic"
    vpc_id = aws_vpc.myVPC.id
    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        security_groups = [aws_security_group.instance_security_group.id]
    }
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

}

// creating mysql db.refer values of var(variables) in variable.tf and terraform.tfvars

resource "aws_db_instance" "mysql_db" {
   depends_on = [ aws_security_group.DB_security_group ]
   allocated_storage    = 20
   db_name              = "production"
   identifier           = "production-db"     
   engine               = "mysql"
   engine_version       = "8.0.33"
   instance_class       = var.db_instance_type
   username             = var.db_username
   password             = var.db_password
   db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
   vpc_security_group_ids = [aws_security_group.DB_security_group.id]
   auto_minor_version_upgrade = false
   skip_final_snapshot  = true
}
