resource "aws_lb" "tf_alb" {
 name               = "terraform-alb"
 internal           = false
 load_balancer_type = "application"
 security_groups    = [aws_security_group.my-sg.id]
 subnets            = ["subnet-063e85e7348b28d71", "subnet-018ed65445f0e21b7", "subnet-02cd7696bfee1a7df"]

 tags = {
   app = "terraform"
 }
}

resource "aws_lb_target_group" "tf_tg" { 
 name     = "terraform-tg"
 port     = 80
 protocol = "HTTP"
 vpc_id   = aws_security_group.my-sg.vpc_id
}

resource "aws_lb_listener" "tf_alb_listener" {
 load_balancer_arn = aws_lb.tf_alb.arn
 port              = "80"
 protocol          = "HTTP"

 default_action {
   type             = "forward"
   target_group_arn = aws_lb_target_group.tf_tg.arn
 }
}

resource "aws_lb_target_group_attachment" "tf_tg_attachment" {
 target_group_arn = aws_lb_target_group.tf_tg.arn
 target_id        = aws_instance.instance_1b.id
 port             = 80
}

output "lb_name" {
    value = aws_lb.tf_alb.dns_name
}