#keypair 
resource "aws_key_pair" "my_key_pair" {
  key_name   = "my_key_pair"
  public_key = file("my_key.pub")
}


#aws vpc
resource "aws_default_vpc" "default" {

}



#aws security group
resource "aws_security_group" "my_security_group" {
  name = "mera_security_group"
  description = "this will add mera security groupin the aws ec2 instance"
  vpc_id = aws_default_vpc.default.id  #this is called interpolation and it is used to get the vpc id from the default vpc resource

#inbound rules which is known as ingress rules
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "yeh mera ingress rule hai jo ssh ke liye use hoga"
  }
ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "yeh mera ingress rule hai jo http ke liye use hoga"
  }

  #outbound rules ko hum egress rules bhi kehte hai instance main se bahr jane wala traffic hota hai 
  egress {
    from_port = 0    #0 ka matlab hai ki yeh rule sabhi ports ke liye apply hoga iski jagah hum specific port bhi de sakte hai jaise 80 ya 22
    to_port = 0       #0 ka matlab allow all traffic from outside to inside the instance
    protocol = "-1"   #-1 ka matlab hai ki yeh rule sabhi protocols ke liye apply hoga iski jagah hum specific protocol bhi de sakte hai jaise tcp ya udp
    cidr_blocks = ["0.0.0.0/0"] #iska use to access the instance from anywhere in the world
  }

  tags ={
  Name = "mera_security_group"

}
}

#ec2 instance
resource "aws_instance" mera_ec2_instance {
  ami = "ami-05cf1e9f73fbad2e2" #this is the id of the amazon linux 2 ami in us-east-1 region
  instance_type = "t3.micro"
  key_name = aws_key_pair.my_key_pair.key_name #this is called interpolation and it is used to get the key name from the key pair resource
  security_groups = [aws_security_group.my_security_group.name] #humne security group.name use kiya hai kyunki security group ka name unique hota hai aur humne usko name diya hai mera_security_group

  root_block_device {
    volume_size = 15
    volume_type = "gp3"
    delete_on_termination = true  #isme instance delete hone par root volume bhi delete ho jayega
  }

  tags = {
    Name = "mera_ec2_instance"
  }
}