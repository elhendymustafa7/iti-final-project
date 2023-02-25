
resource "aws_vpc" "Main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Main-vpc"
  }
}








