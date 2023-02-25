# --------------------------------------"EC2-Bastion"-----------------------------

resource "aws_instance" "bastion" {
  ami = "ami-0d50e5e845c552faf"
  instance_type               = "t2.small"
  subnet_id                   = aws_subnet.sub_pub1.id
  key_name                    = "ssh"
  vpc_security_group_ids      = [aws_security_group.eks.id]
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.my_instance_profile1.id
  tags = {
    Name = "jumphost"
  }

}

resource "aws_iam_instance_profile" "my_instance_profile1" {
  name = "my-ec2-instance-profile1"

  role = aws_iam_role.ian_role_node.id

}
