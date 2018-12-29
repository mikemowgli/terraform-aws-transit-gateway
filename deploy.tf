###############
# VPC Section #
###############

# VPCs

resource "aws_vpc" "vpc-1" {
  cidr_block = "10.10.0.0/16"
  tags = {
    Name = "${var.scenario}-vpc1-dev"
    scenario = "${var.scenario}"
    env = "dev"
  }
}

resource "aws_vpc" "vpc-2" {
  cidr_block = "10.11.0.0/16"
  tags = {
    Name = "${var.scenario}-vpc2-dev"
    scenario = "${var.scenario}"
    env = "dev"
  }
}

resource "aws_vpc" "vpc-3" {
  cidr_block = "10.12.0.0/16"
  tags = {
    Name = "${var.scenario}-vpc3-shared"
    scenario = "${var.scenario}"
    env = "shared"
  }
}

resource "aws_vpc" "vpc-4" {
  cidr_block = "10.13.0.0/16"
  tags = {
    Name = "${var.scenario}-vpc4-prod"
    scenario = "${var.scenario}"
    env = "prod"
  }
}

# Subnets

resource "aws_subnet" "vpc-1-sub-a" {
  vpc_id     = "${aws_vpc.vpc-1.id}"
  cidr_block = "10.10.1.0/24"
  availability_zone = "${var.az1}"

  tags = {
    Name = "${aws_vpc.vpc-1.tags.Name}-sub-a"
  }
}

resource "aws_subnet" "vpc-1-sub-b" {
  vpc_id     = "${aws_vpc.vpc-1.id}"
  cidr_block = "10.10.2.0/24"
  availability_zone = "${var.az2}"

  tags = {
    Name = "${aws_vpc.vpc-1.tags.Name}-sub-b"
  }
}

resource "aws_subnet" "vpc-2-sub-a" {
  vpc_id     = "${aws_vpc.vpc-2.id}"
  cidr_block = "10.11.1.0/24"
  availability_zone = "${var.az1}"

  tags = {
    Name = "${aws_vpc.vpc-2.tags.Name}-sub-a"
  }
}

resource "aws_subnet" "vpc-2-sub-b" {
  vpc_id     = "${aws_vpc.vpc-2.id}"
  cidr_block = "10.11.2.0/24"
  availability_zone = "${var.az2}"

  tags = {
    Name = "${aws_vpc.vpc-2.tags.Name}-sub-b"
  }
}

resource "aws_subnet" "vpc-3-sub-a" {
  vpc_id     = "${aws_vpc.vpc-3.id}"
  cidr_block = "10.12.1.0/24"
  availability_zone = "${var.az1}"

  tags = {
    Name = "${aws_vpc.vpc-3.tags.Name}-sub-a"
  }
}

resource "aws_subnet" "vpc-3-sub-b" {
  vpc_id     = "${aws_vpc.vpc-3.id}"
  cidr_block = "10.12.2.0/24"
  availability_zone = "${var.az2}"

  tags = {
    Name = "${aws_vpc.vpc-3.tags.Name}-sub-b"
  }
}

resource "aws_subnet" "vpc-4-sub-a" {
  vpc_id     = "${aws_vpc.vpc-4.id}"
  cidr_block = "10.13.1.0/24"
  availability_zone = "${var.az1}"

  tags = {
    Name = "${aws_vpc.vpc-4.tags.Name}-sub-a"
  }
}

resource "aws_subnet" "vpc-4-sub-b" {
  vpc_id     = "${aws_vpc.vpc-4.id}"
  cidr_block = "10.13.2.0/24"
  availability_zone = "${var.az2}"

  tags = {
    Name = "${aws_vpc.vpc-4.tags.Name}-sub-b"
  }
}

# Internet Gateway

resource "aws_internet_gateway" "vpc-3-igw" {
  vpc_id = "${aws_vpc.vpc-3.id}"

  tags = {
    Name = "vpc-3-igw"
    scenario = "${var.scenario}"
  }
}

# Main Route Tables Associations
## Forcing our Route Tables to be the main ones for our VPCs,
## otherwise AWS automatically will create a main Route Table
## for each VPC, leaving our own Route Tables as secondary

resource "aws_main_route_table_association" "main-rt-vpc-1" {
  vpc_id         = "${aws_vpc.vpc-1.id}"
  route_table_id = "${aws_route_table.vpc-1-rtb.id}"
}

resource "aws_main_route_table_association" "main-rt-vpc-2" {
  vpc_id         = "${aws_vpc.vpc-2.id}"
  route_table_id = "${aws_route_table.vpc-2-rtb.id}"
}

resource "aws_main_route_table_association" "main-rt-vpc-3" {
  vpc_id         = "${aws_vpc.vpc-3.id}"
  route_table_id = "${aws_route_table.vpc-3-rtb.id}"
}

resource "aws_main_route_table_association" "main-rt-vpc-4" {
  vpc_id         = "${aws_vpc.vpc-4.id}"
  route_table_id = "${aws_route_table.vpc-4-rtb.id}"
}


# Route Tables
## Usually unecessary to explicitly create a Route Table in Terraform
## since AWS automatically creates and assigns a 'Main Route Table'
## whenever a VPC is created. However, in a Transit Gateway scenario,
## Route Tables are explicitly created so an extra route to the
## Transit Gateway could be defined

resource "aws_route_table" "vpc-1-rtb" {
  vpc_id = "${aws_vpc.vpc-1.id}"

  route {
    cidr_block = "10.0.0.0/8"
    transit_gateway_id = "${aws_ec2_transit_gateway.test-tgw.id}"
  }

  tags = {
    Name       = "vpc-1-rtb"
    env        = "dev"
    scenario = "${var.scenario}"
  }
  depends_on = ["aws_ec2_transit_gateway.test-tgw"]
}

resource "aws_route_table" "vpc-2-rtb" {
  vpc_id = "${aws_vpc.vpc-2.id}"

  route {
    cidr_block = "10.0.0.0/8"
    transit_gateway_id = "${aws_ec2_transit_gateway.test-tgw.id}"
  }

  tags = {
    Name       = "vpc-2-rtb"
    env        = "dev"
    scenario = "${var.scenario}"
  }
  depends_on = ["aws_ec2_transit_gateway.test-tgw"]
}

resource "aws_route_table" "vpc-3-rtb" {
  vpc_id = "${aws_vpc.vpc-3.id}"

  route {
    cidr_block = "10.0.0.0/8"
    transit_gateway_id = "${aws_ec2_transit_gateway.test-tgw.id}"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.vpc-3-igw.id}"
  }

  tags = {
    Name       = "vpc-3-rtb"
    env        = "shared"
    scenario = "${var.scenario}"
  }
  depends_on = ["aws_ec2_transit_gateway.test-tgw"]
}

resource "aws_route_table" "vpc-4-rtb" {
  vpc_id = "${aws_vpc.vpc-4.id}"

  route {
    cidr_block = "10.0.0.0/8"
    transit_gateway_id = "${aws_ec2_transit_gateway.test-tgw.id}"
  }

  tags = {
    Name       = "vpc-4-rtb"
    env        = "prod"
    scenario = "${var.scenario}"
  }
  depends_on = ["aws_ec2_transit_gateway.test-tgw"]
}


###########################
# Transit Gateway Section #
###########################

# Transit Gateway
## Default association and propagation are disabled since our scenario involves
## a more elaborated setup where
## - Dev VPCs can reach themselves and the Shared VPC
## - the Shared VPC can reach all VPCs
## - the Prod VPC can only reach the Shared VPC
## The default setup being a full mesh scenario where all VPCs can see every other
resource "aws_ec2_transit_gateway" "test-tgw" {
  description                     = "Transit Gateway testing scenario with 4 VPCs, 2 subnets each"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags                            = {
    Name                          = "${var.scenario}"
    scenario                      = "${var.scenario}"
  }
}

# VPC attachment

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-vpc-1" {
  subnet_ids         = ["${aws_subnet.vpc-1-sub-a.id}", "${aws_subnet.vpc-1-sub-b.id}"]
  transit_gateway_id = "${aws_ec2_transit_gateway.test-tgw.id}"
  vpc_id             = "${aws_vpc.vpc-1.id}"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags               = {
    Name             = "tgw-att-vpc1"
    scenario         = "${var.scenario}"
  }
  depends_on = ["aws_ec2_transit_gateway.test-tgw"]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-vpc-2" {
  subnet_ids         = ["${aws_subnet.vpc-2-sub-a.id}", "${aws_subnet.vpc-2-sub-b.id}"]
  transit_gateway_id = "${aws_ec2_transit_gateway.test-tgw.id}"
  vpc_id             = "${aws_vpc.vpc-2.id}"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags               = {
    Name             = "tgw-att-vpc2"
    scenario         = "${var.scenario}"
  }
  depends_on = ["aws_ec2_transit_gateway.test-tgw"]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-vpc-3" {
  subnet_ids         = ["${aws_subnet.vpc-3-sub-a.id}", "${aws_subnet.vpc-3-sub-b.id}"]
  transit_gateway_id = "${aws_ec2_transit_gateway.test-tgw.id}"
  vpc_id             = "${aws_vpc.vpc-3.id}"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags               = {
    Name             = "tgw-att-vpc3"
    scenario         = "${var.scenario}"
  }
  depends_on = ["aws_ec2_transit_gateway.test-tgw"]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-vpc-4" {
  subnet_ids         = ["${aws_subnet.vpc-4-sub-a.id}", "${aws_subnet.vpc-4-sub-b.id}"]
  transit_gateway_id = "${aws_ec2_transit_gateway.test-tgw.id}"
  vpc_id             = "${aws_vpc.vpc-4.id}"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags               = {
    Name             = "tgw-att-vpc4"
    scenario         = "${var.scenario}"
  }
  depends_on = ["aws_ec2_transit_gateway.test-tgw"]
}

# Route Tables

resource "aws_ec2_transit_gateway_route_table" "tgw-dev-rt" {
  transit_gateway_id = "${aws_ec2_transit_gateway.test-tgw.id}"
  tags               = {
    Name             = "tgw-dev-rt"
    scenario         = "${var.scenario}"
  }
  depends_on = ["aws_ec2_transit_gateway.test-tgw"]
}

resource "aws_ec2_transit_gateway_route_table" "tgw-shared-rt" {
  transit_gateway_id = "${aws_ec2_transit_gateway.test-tgw.id}"
  tags               = {
    Name             = "tgw-shared-rt"
    scenario         = "${var.scenario}"
  }
  depends_on = ["aws_ec2_transit_gateway.test-tgw"]
}

resource "aws_ec2_transit_gateway_route_table" "tgw-prod-rt" {
  transit_gateway_id = "${aws_ec2_transit_gateway.test-tgw.id}"
  tags               = {
    Name             = "tgw-prod-rt"
    scenario         = "${var.scenario}"
  }
  depends_on = ["aws_ec2_transit_gateway.test-tgw"]
}

# Route Tables Associations
## This is the link between a VPC (already symbolized with its attachment to the Transit Gateway)
##  and the Route Table the VPC's packet will hit when they arrive into the Transit Gateway.
## The Route Tables Associations do not represent the actual routes the packets are routed to.
## These are defined in the Route Tables Propagations section below.

resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-vpc-1-assoc" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-1.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.tgw-dev-rt.id}"
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-vpc-2-assoc" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-2.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.tgw-dev-rt.id}"
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-vpc-3-assoc" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-3.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.tgw-shared-rt.id}"
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw-rt-vpc-4-assoc" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-4.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.tgw-prod-rt.id}"
}

# Route Tables Propagations
## This section defines which VPCs will be routed from each Route Table created in the Transit Gateway

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-dev-to-vpc-1" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-1.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.tgw-dev-rt.id}"
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-dev-to-vpc-2" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-2.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.tgw-dev-rt.id}"
}
resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-dev-to-vpc-3" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-3.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.tgw-dev-rt.id}"
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-shared-to-vpc-1" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-1.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.tgw-shared-rt.id}"
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-shared-to-vpc-2" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-2.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.tgw-shared-rt.id}"
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-shared-to-vpc-4" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-4.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.tgw-shared-rt.id}"
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw-rt-prod-to-vpc-3" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.tgw-att-vpc-3.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.tgw-prod-rt.id}"
}

#########################
# EC2 Instances Section #
#########################

# Key Pair

resource "aws_key_pair" "test-tgw-keypair" {
  key_name   = "test-tgw-keypair"
  public_key = "${var.public_key}"
}

# Security Groups
## Need to create 4 of them as our Security Groups are linked to a VPC

resource "aws_security_group" "sec-group-vpc-1-ssh-icmp" {
  name        = "sec-group-vpc-1-ssh-icmp"
  description = "test-tgw: Allow SSH and ICMP traffic"
  vpc_id      = "${aws_vpc.vpc-1.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8 # the ICMP type number for 'Echo'
    to_port     = 0 # the ICMP code
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0 # the ICMP type number for 'Echo Reply'
    to_port     = 0 # the ICMP code
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sec-group-vpc-1-ssh-icmp"
    scenario = "${var.scenario}"
  }
}

resource "aws_security_group" "sec-group-vpc-2-ssh-icmp" {
  name        = "sec-group-vpc-2-ssh-icmp"
  description = "test-tgw: Allow SSH and ICMP traffic"
  vpc_id      = "${aws_vpc.vpc-2.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8 # the ICMP type number for 'Echo'
    to_port     = 0 # the ICMP code
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0 # the ICMP type number for 'Echo Reply'
    to_port     = 0 # the ICMP code
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sec-group-vpc-2-ssh-icmp"
    scenario = "${var.scenario}"
  }
}

resource "aws_security_group" "sec-group-vpc-3-ssh-icmp" {
  name        = "sec-group-vpc-3-ssh-icmp"
  description = "test-tgw: Allow SSH and ICMP traffic"
  vpc_id      = "${aws_vpc.vpc-3.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8 # the ICMP type number for 'Echo'
    to_port     = 0 # the ICMP code
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0 # the ICMP type number for 'Echo Reply'
    to_port     = 0 # the ICMP code
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sec-group-vpc-3-ssh-icmp"
    scenario = "${var.scenario}"
  }
}

resource "aws_security_group" "sec-group-vpc-4-ssh-icmp" {
  name        = "sec-group-vpc-4-ssh-icmp"
  description = "test-tgw: Allow SSH and ICMP traffic"
  vpc_id      = "${aws_vpc.vpc-4.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8 # the ICMP type number for 'Echo'
    to_port     = 0 # the ICMP code
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0 # the ICMP type number for 'Echo Reply'
    to_port     = 0 # the ICMP code
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sec-group-vpc-4-ssh-icmp"
    scenario = "${var.scenario}"
  }
}

# VMs

## Fetching AMI info
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "test-tgw-instance1-dev" {
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "t2.micro"
  subnet_id                   = "${aws_subnet.vpc-1-sub-a.id}"
  vpc_security_group_ids     = [ "${aws_security_group.sec-group-vpc-1-ssh-icmp.id}" ]
  key_name                    = "${aws_key_pair.test-tgw-keypair.key_name}"
  private_ip                  = "10.10.1.10"

  tags = {
    Name = "test-tgw-instance1-dev"
    scenario    = "${var.scenario}"
    env         = "dev"
    az          = "${var.az1}"
    vpc         = "1"
  }
}

resource "aws_instance" "test-tgw-instance2-dev" {
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "t2.micro"
  subnet_id                   = "${aws_subnet.vpc-2-sub-a.id}"
  vpc_security_group_ids     = [ "${aws_security_group.sec-group-vpc-2-ssh-icmp.id}" ]
  key_name                    = "${aws_key_pair.test-tgw-keypair.key_name}"
  private_ip                  = "10.11.1.10"

  tags = {
    Name = "test-tgw-instance2-dev"
    scenario    = "${var.scenario}"
    env         = "dev"
    az          = "${var.az1}"
    vpc         = "2"
  }
}

resource "aws_instance" "test-tgw-instance3-shared" {
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "t2.micro"
  subnet_id                   = "${aws_subnet.vpc-3-sub-a.id}"
  vpc_security_group_ids     = [ "${aws_security_group.sec-group-vpc-3-ssh-icmp.id}" ]
  key_name                    = "${aws_key_pair.test-tgw-keypair.key_name}"
  private_ip                  = "10.12.1.10"
  associate_public_ip_address = true

  tags = {
    Name = "test-tgw-instance3-shared"
    scenario    = "${var.scenario}"
    env         = "shared"
    az          = "${var.az1}"
    vpc         = "3"
  }
}

resource "aws_instance" "test-tgw-instance4-prod" {
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "t2.micro"
  subnet_id                   = "${aws_subnet.vpc-4-sub-a.id}"
  vpc_security_group_ids     = [ "${aws_security_group.sec-group-vpc-4-ssh-icmp.id}" ]
  key_name                    = "${aws_key_pair.test-tgw-keypair.key_name}"
  private_ip                  = "10.13.1.10"

  tags = {
    Name = "test-tgw-instance4-prod"
    scenario    = "${var.scenario}"
    env         = "prod"
    az          = "${var.az1}"
    vpc         = "4"
  }
}

###########
# Outputs #
###########

output "PUBLIC_IP" { value = "${aws_instance.test-tgw-instance3-shared.public_ip}" }
