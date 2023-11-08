
resource "aws_vpc" "myVPC" {
  cidr_block = var.vpc-cidr-block
  instance_tenancy = "default"
  tags = {
    Name = "myVPC"
  }
}



resource "aws_internet_gateway" "myIGW" {
  tags = {
    Name = "myIGW"
  }
}

// attach our internet gateway and vpc

resource "aws_internet_gateway_attachment" "IGW_attachment" {
  vpc_id = aws_vpc.myVPC.id
  internet_gateway_id = aws_internet_gateway.myIGW.id
}

// creating two public subnet with name production and DR  

resource "aws_subnet" "production" {                                
    availability_zone = var.production_AZ
    cidr_block = var.production-cidr-block
    vpc_id = aws_vpc.myVPC.id
    tags = {
        Name = "Production_subnet"
    }
}

resource "aws_subnet" "DR" {                                
    availability_zone = var.DR_AZ
    cidr_block = var.DR-cidr-block
    vpc_id = aws_vpc.myVPC.id
    tags = {
        Name = "DR_subnet"
    }
}


resource "aws_route_table" "production_route_table"{
    depends_on = [aws_subnet.production]
    vpc_id = aws_vpc.myVPC.id
    route  {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myIGW.id
    }

    tags = {
        Name = "Production_route_table"
    }
} 


resource "aws_route_table" "DR_route_table"{
    depends_on = [aws_subnet.DR]
    vpc_id = aws_vpc.myVPC.id
    route  {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myIGW.id
    }

    tags = {
        Name = "DR_route_table"
    }
    
} 




resource "aws_route_table_association" "production_routetable_asso" {       
  subnet_id      = aws_subnet.production.id
  route_table_id = aws_route_table.production_route_table.id
}

resource "aws_route_table_association" "DR_routetable_asso" {
    subnet_id      = aws_subnet.DR.id
    route_table_id = aws_route_table.DR_route_table.id
}

resource "aws_security_group" "instance_security_group"{
    name = "instance_security_group"
    description = "allow ssh traffic and http traffic"
    vpc_id = aws_vpc.myVPC.id
    ingress{
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

}

//creating custom keypair.make sure use the pem key in the folder to create ppk file and use it to open ec2 

resource "aws_key_pair" "key_name" {
  key_name = "mykey"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCJuKD5pdNLieahD3Fl/yv4/xQy7Zu8TU8Z/Kbj9JJHJHsK0X/P01k+eWlvGEvbYNUO73/i3YE75XXOjOaGNulhzP9+8/+7nw0YB5num1mbHc096F3sNPi3bD1itoBmued/B9BYdcMmctgYKAQBgSpRFdgp1waOg2oFxUgZxa7oR0xsWhuHJA0kgjIEF5uLfOekcUCpRCt4vp8eFBiMb2pL9vkHExHUUftb29jZf0NucmXRST1qVw1/Vc7AiO/qulgHbxskTKkQuw0QclhlXk3seUlDX8ZUqG/GitkUIV0dGMAcZnDtuQPc6gSb0QUe2iaqNqDVl1eZUjT8UWNG9sD9 Vishnu"
}


//creating role 

resource "aws_iam_role" "ec2_rds_fullacess" {
  name = "ec2_rds_fullacess"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

//attaching our existing aws policy to our role

resource "aws_iam_role_policy_attachment" "rds_policy_role_attachment" {
  role       = aws_iam_role.ec2_rds_fullacess.name
  policy_arn = data.aws_iam_policy.policy_rds_fullaccess.arn
}

resource "aws_iam_role_policy_attachment" "s3_policy_role_attachment" {
  role       = aws_iam_role.ec2_rds_fullacess.name
  policy_arn = data.aws_iam_policy.policy_s3_fullaccess.arn
}

// we cant directly attach our role to our ec2.we have to create iam_instance_profile
resource "aws_iam_instance_profile" "ec2_role_attachment" {
  name = "ec2_role_attachment"
  role = aws_iam_role.ec2_rds_fullacess.name
}


// creating production instance
resource "aws_instance" "Production" {
  
  ami = data.aws_ami.myami.id
  availability_zone = var.production_AZ
  instance_type  = var.instance_type
  key_name  = aws_key_pair.key_name.key_name
  vpc_security_group_ids = [aws_security_group.instance_security_group.id]
  subnet_id = aws_subnet.production.id
  associate_public_ip_address = "true"
  iam_instance_profile = aws_iam_instance_profile.ec2_role_attachment.name //attaching our role 
  tags = {
    Name = "Production"
  }

  provisioner "remote-exec" {                   // this block will execute below command to remote server 
    inline = [
      "#!/bin/bash",
      "sudo apt update -y",
      "sudo apt install apache2 -y",
      "sudo apt install php -y",
      "sudo apt install php-mysql -y",
      "sudo apt install awscli -y",
      "sudo chmod -R 777 /var/www/wordpress",
      "sudo wget https://wordpress.org/latest.tar.gz",
      "sudo tar -xzf latest.tar.gz",
      "sudo mkdir /var/www/wordpress/",
      "sudo cp -r wordpress/* /var/www/wordpress/",
      "sudo rm -rf wordpress",
      "sudo rm -rf latest.tar.gz",
      "sudo chown -R www-data:www-data /var/www/wordpress",
      "sudo chmod -R 777 /etc/apache2/sites-available"
    ]
  }
  
    provisioner "file" {
    source = "wordpress.conf"   // conf file for our wordpress site.check wordpress file in the folder.
    destination = "/etc/apache2/sites-available/wordpress.conf" 
  }
   
   provisioner "remote-exec" {                 
    inline = [
      "#!/bin/bash",
      "sudo echo */2 * * * * aws s3 sync --delete /var/www/wordpress s3://${var.bucket_name} > mycron", // creating cronjob to achieve DR strategy
      "sudo crontab -u ubuntu mycron",
      "sudo rm mycron",
      "sudo a2ensite wordpress",
      "sudo a2enmod rewrite",
      "sudo a2dissite 000-default",
      "sudo service apache2 reload",
    ]
  }

  connection {
    type = "ssh"
    user = "ubuntu"
    host = self.public_ip
    private_key = file("mykey.pem")
    timeout = "3m"
  }

}

//////////////////////////////////////////////////////////////////////////////

// creating DR instance like above

resource "aws_instance" "DR" {
  
  ami = data.aws_ami.myami.id
  availability_zone = var.DR_AZ
  instance_type  = var.instance_type
  key_name  = aws_key_pair.key_name.key_name
  vpc_security_group_ids = [aws_security_group.instance_security_group.id]
  subnet_id = aws_subnet.DR.id
  associate_public_ip_address = "true"
  iam_instance_profile = aws_iam_instance_profile.ec2_role_attachment.name
  tags = {
    Name = "DR"
  }

  provisioner "remote-exec" {                 
    inline = [
      "#!/bin/bash",
      "sudo apt update -y",
      "sudo apt install apache2 -y",
      "sudo apt install php -y",
      "sudo apt install php-mysql -y",
      "sudo apt install awscli -y",
      "sudo chmod -R 777 /var/www/wordpress",
      "sudo wget https://wordpress.org/latest.tar.gz",
      "sudo tar -xzf latest.tar.gz",
      "sudo mkdir /var/www/wordpress/",
      "sudo cp -r wordpress/* /var/www/wordpress/",
      "sudo rm -rf wordpress",
      "sudo rm -rf latest.tar.gz",
      "sudo chown -R www-data:www-data /var/www/wordpress",
      "sudo chmod -R 777 /etc/apache2/sites-available"
    ]
  }
  
    provisioner "file" {
    source = "wordpress.conf"
    destination = "/etc/apache2/sites-available/wordpress.conf"
  }
   
   provisioner "remote-exec" {                 
    inline = [
      "#!/bin/bash",
      "sudo echo */2 * * * * aws s3 sync --delete s3://${var.bucket_name} /var/www/wordpress  > mycron",
      "sudo crontab -u ubuntu mycron",
      "sudo rm mycron",
      "sudo a2ensite wordpress",
      "sudo a2enmod rewrite",
      "sudo a2dissite 000-default",
      "sudo service apache2 reload",
    ]
  }

  connection {
    type = "ssh"
    user = "ubuntu"
    host = self.public_ip
    private_key = file("mykey.pem")
    timeout = "3m"
  }

}
