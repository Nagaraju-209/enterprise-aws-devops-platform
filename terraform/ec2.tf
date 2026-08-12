data "aws_ami" "amazon_linux" {

  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "app_server" {

  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  subnet_id = aws_subnet.public.id

  vpc_security_group_ids = [
    aws_security_group.public_sg.id
  ]

  key_name = aws_key_pair.main.key_name

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  associate_public_ip_address = true

  user_data = file("${path.module}/userdata.sh")

  tags = {
    Name        = "enterprise-devops-app-server"
    Environment = "Development"
    Project     = "Enterprise-AWS-DevOps-Platform"
    ManagedBy   = "Terraform"
  }
}

resource "aws_lb_target_group_attachment" "springboot_attachment" {
  target_group_arn = aws_lb_target_group.springboot_tg.arn
  target_id        = aws_instance.app_server.id
  port             = 8083
}
