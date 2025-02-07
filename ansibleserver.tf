provider "aws" {
    region = "us-east-1"
}


resource "aws_instance" "main" {
        ami = "ami-0b4f379183e5706b9"
        instance_type = "t2.micro"
        #security_groups = [ sg-0857cf95e6d82697c ]
        vpc_security_group_ids = [ "sg-0857cf95e6d82697c" ]
        iam_instance_profile = "roboshop"
        #iam_instance_profile = null


        user_data = <<-EOF
          #!/bin/bash
          sudo su 
          yum install ansible -y
          EOF
}