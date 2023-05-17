
data "aws_ami" "ami" {

  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

data "aws_availability_zones" "available" {
  state = "available"
}

provider "aws" {
    region = var.region
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
}

# Create VPC
resource "aws_vpc" "main-vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = "true" 
  enable_dns_hostnames = "true" 
  instance_tenancy     = "default"


}

#create public Subnet for EC2
resource "aws_subnet" "public-subnet-ec2" {
  vpc_id                  = aws_vpc.main-vpc.id
  cidr_block              = var.public_cidr_blocks
  map_public_ip_on_launch = "true" 
  availability_zone       = var.AZ1

}

# Create Private subnet for DB
resource "aws_subnet" "subnet-db" {
  vpc_id                  = aws_vpc.main-vpc.id
  cidr_block              = var.db_cidr_blocks
  map_public_ip_on_launch = "false" 
  availability_zone       = var.AZ1
}


# Create private subnet RDS
resource "aws_subnet" "private_subnet-rds" {
  vpc_id                  = aws_vpc.main-vpc.id
  cidr_block              = var.private_cidr_blocks
  map_public_ip_on_launch = "false" 
  availability_zone       = var.AZ2
}

# Create Internet Gateway for internet connection 
resource "aws_internet_gateway" "wp-igw" {
  vpc_id = aws_vpc.main-vpc.id

}

# Create Route table 
resource "aws_route_table" "create-public-routing" {
  vpc_id = aws_vpc.main-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wp-igw.id
  }


}

# Associating route tabe to public subnet
resource "aws_route_table_association" "crta-public-subnet" {
  subnet_id      = aws_subnet.public-subnet-ec2.id
  route_table_id = aws_route_table.create-public-routing.id
}



# webserver security group
resource "aws_security_group" "webserver-sg" {


  ingress {
    description = "For HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "For HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "For MYSQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "For SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "ec2 security group"
  }
}


#DB security Group
resource "aws_security_group" "DB-sg" {
  vpc_id = aws_vpc.main-vpc.id
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.webserver-sg.id}"]
  }
  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow webserver to DB"
  }

}


#MySQL RDS security Group
resource "aws_db_subnet_group" "db-subnet-group" {
  subnet_ids = ["${aws_subnet.subnet-db.id}", "${aws_subnet.private_subnet-rds.id}"]
}

# Create RDS instance
resource "aws_db_instance" "setup-rds-db" {
  allocated_storage      = 10
  engine                 = var.rds_engine
  engine_version         = var.rds_engine_version
  instance_class         = var.rds_instance
  db_subnet_group_name   = aws_db_subnet_group.db-subnet-group.id
  vpc_security_group_ids = ["${aws_security_group.DB-sg.id}"]
  db_name                   = "wordpressDB"
  username               = var.db_user
  password               = var.db_cred
  skip_final_snapshot    = true

  lifecycle {
     ignore_changes = [password]
   }
}

#Wordpress installation template
data "template_file" "user_data" {
  template =  file("${path.module}\\user_data.tpl") 
  vars = {
    db_username      = var.db_user
    db_user_password = var.db_cred
    db_name          = "wordpressDB"
    db_RDS           = aws_db_instance.setup-rds-db.endpoint
    wp_url           = "${var.subdomain_name}.${var.domain_name}"
    wp_admin         = var.wp_admin
    wp_admin_pw      = var.wp_admin_creds
    wp_admin_email   = var.wp_admin_email_add
    saml_sp_entity_id = okta_app_saml.setup-saml-app.entity_key
    saml_sp_metadata_url = okta_app_saml.setup-saml-app.metadata_url
    saml_sp_sso_url = okta_app_saml.setup-saml-app.sso_url
    saml_sp_certificate = okta_app_saml.setup-saml-app.certificate
  }
}

#setup key pair
resource "tls_private_key" "wordpress_private_key" {
    algorithm = "RSA"
    rsa_bits = 4096
}

resource "aws_key_pair" "keypair" {
  key_name   = var.key_pair
  public_key = tls_private_key.wordpress_private_key.public_key_openssh
  depends_on = [ tls_private_key.wordpress_private_key ]
}

resource "local_file" "save_key_local" {
    content = tls_private_key.wordpress_private_key.private_key_pem
    filename = "${var.script_path}/${var.key_pair}-private.pem" 
}

resource "aws_instance" "wp-webserver" {
  ami                    =  data.aws_ami.ami.id 
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public-subnet-ec2.id
  vpc_security_group_ids = ["${aws_security_group.webserver-sg.id}"]
  user_data              = data.template_file.user_data.rendered
  key_name               = aws_key_pair.keypair.id
  tags = {
    Name = "Wp webserver"
  }

  root_block_device {
    volume_size = 15

  }

    connection {
    type        = "ssh"
    user        = "ubuntu" 
    private_key = file("${var.script_path}/${var.key_pair}-private.pem")
    host        = self.public_ip
  }

   provisioner "remote-exec" {
    inline = [
        "${path.module}/saml-conf.sh ${okta_app_saml.setup-saml-app.sso_url}",    
    ]

  }



  depends_on = [aws_db_instance.setup-rds-db]
}

#create Elastic IP for webserver
resource "aws_eip" "eip" {
  instance = aws_instance.wp-webserver.id
}

##create URL for Wp
resource "aws_route53_zone" "setup-wp-url" {
  name = var.domain_name
}

resource "aws_route53_record" "wp-alias" {
  zone_id = aws_route53_zone.setup-wp-url.zone_id
  name    = var.subdomain_name
  type    = "A"
  ttl     = 300
  records = [aws_eip.eip.public_ip]

}

resource "null_resource" "Wp_Install_check" {
   triggers={
    ec2_id=aws_instance.wp-webserver.id,
    rds_endpoint=aws_db_instance.setup-rds-db.endpoint

  }
  connection {
    type        = "ssh"
    user        =  "ubuntu"
    private_key = file("${var.script_path}/${var.key_pair}-private.pem")
    host        = aws_eip.eip.public_ip
  }


  provisioner "remote-exec" {
    inline = ["sudo tail -f -n0 /var/log/cloud-init-output.log| grep -q 'WordPress Installed'"]

  }
}

