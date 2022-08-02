terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}


resource "aws_security_group" "allow_SSH" {
  name        = "allow_SSH"
  description = "Allow SSH inbound traffic"
  #   vpc_id      = aws_vpc.main.id


  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    # description      = "SSH from VPC"
    # from_port        = 22
    # to_port          = 22
    # protocol         = "tcp"
    # cidr_blocks      = ["61.6.14.46/32"]
    # # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_key_pair" "deployer1" {
  key_name   = "deployer-key1"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBSalr7ZWvYxAzYEZ8AWi6BMlopSFCE4rRAl3WqCX1m6vdG8TOu2w88EOYetvs5DzwJJzFVB0SxUq1N58sMNSOCUe5YySe6cFKVMkutweDzafmMzBqqpQyB4NULT95xiBAj6C3Nutlf2XE+dnUEoK4Vyq+K35ZGJi73z8HcrLNj9uwMJf/sDPOn/hpjcWi0NjM6OzL2d+xvnWGSE9vqmkyxJuJy0jhCTaEWMrdy10c9TnhoVtpoBJDK+io8mlJVaToOyl6v+Kf1HW4U4nIserGWgsXUpPffgCHW1ti1zfZcU51t8pmDV02Y6Wujzm7Sieo7XjgTnrkcdrmnQKspa2DNEycuSu/7+XAyYcm+KveF8WiXrs1w7QPlo6XjFRMSqO23WScDjDFwY0/t6P0To/MckYrv8187b3vh5uz9NklgInW95zaZxzXop3QAp0sk3eHrHsV9jnppXssXQ84b66j6CalLo3JVvpOs/6LU+mc64ZHul1aWHnSw1yqRa02JSM= sauravsinghrain@ip-172-31-25-133"
}

resource "aws_instance" "linux" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer1.key_name
  # count         = 1 
  vpc_security_group_ids = ["${aws_security_group.allow_SSH.id}"]
  tags = {
    "Name" = "Linux-Node"
    "ENV"  = "Dev"
  }

  depends_on = [aws_key_pair.deployer1]

}

####### Ubuntu VM #####


resource "aws_instance" "ubuntu" {
  ami           = "ami-04505e74c0741db8d"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer1.key_name
  vpc_security_group_ids = ["${aws_security_group.allow_SSH.id}"]
  tags = {
    "Name" = "UBUNTU-Node"
    "ENV"  = "Dev"
  }

  depends_on = [aws_key_pair.deployer1]

}
