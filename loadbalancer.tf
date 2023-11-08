
// creating target group for our production load balancer

resource "aws_lb_target_group" "production-target-group" {
  name     = "production-target-group"
  port     = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id   = aws_vpc.myVPC.id
  health_check {
    path = "/readme.html"             // by default wordpress tar file contain readme.html so we doing health 
  }                                   // check on readme.html instead of index.html
}

// we are attaching our production_ec2 in our target group 
resource "aws_lb_target_group_attachment" "lb_target_group_attachment" {
  depends_on = [ aws_instance.Production ]                           // this resource execute only if production ec2 exist
  target_group_arn = aws_lb_target_group.production-target-group.arn
  target_id        = aws_instance.Production.id
  port             = 80
}


// creating production_ load balancer 
resource "aws_lb" "Production_LB" {
  name               = "Production-LB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.LB_security_group.id]
  subnets            = [aws_subnet.production.id,aws_subnet.DR.id]
  
}

// creating security group for our load balancer.we are using same SG for both load balancer
resource "aws_security_group" "LB_security_group"{
    name = "LB_security_group"
    description = "allow http traffic"
    vpc_id = aws_vpc.myVPC.id
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

// creating listener to forward our hhtp traffic to our production target group

resource "aws_lb_listener" "production_LB_listener" {
  load_balancer_arn = aws_lb.Production_LB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.production-target-group.arn
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////

//creating the same resources for DR.

resource "aws_lb_target_group" "DR-target-group" {
  name     = "DR-target-group"
  port     = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id   = aws_vpc.myVPC.id
  health_check {
    path = "/readme.html"
  }
}

resource "aws_lb_target_group_attachment" "DR_lb_target_group_attachment" {
  depends_on = [ aws_instance.DR ]
  target_group_arn = aws_lb_target_group.DR-target-group.arn
  target_id        = aws_instance.DR.id
  port             = 80
}

resource "aws_lb" "DR_LB" {
  name               = "DR-LB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.LB_security_group.id]
  subnets            = [aws_subnet.production.id,aws_subnet.DR.id]
  
}

resource "aws_lb_listener" "DR_LB_listener" {
  load_balancer_arn = aws_lb.DR_LB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.DR-target-group.arn
  }
}
