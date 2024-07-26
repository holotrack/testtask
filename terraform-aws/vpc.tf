data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "hello" {
  cidr_block = "10.0.0.0/16"


}

# requried for multizone eks installation
resource "aws_subnet" "hello" {
  count = 2

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.hello.id

 
}

resource "aws_internet_gateway" "hello" {
  vpc_id = aws_vpc.hello.id


}

resource "aws_route_table" "hello" {
  vpc_id = aws_vpc.hello.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.hello.id
  }
}

resource "aws_route_table_association" "hello" {
  count = 2

  subnet_id      = aws_subnet.hello[count.index].id
  route_table_id = aws_route_table.hello.id
}