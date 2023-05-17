variable "region" {
    description = "Provide the AWS region"
    default = "us-east-1"
}

variable "key_pair" {
    description = "Provide Keypair name"
    default = "testpair"
}

variable "script_path" {
    description = "Provide your local file path"
    default = "C:\\Development"
}

variable "cidr_block" {
    default = "10.0.0.0/16"
}

variable "public_cidr_blocks" {
    default = "10.0.1.0/24"
}

variable "private_cidr_blocks" {
    default = "10.0.10.0/24"
}

variable "db_cidr_blocks" {
  default = "10.0.100.0/24"
}

variable "rds_engine" {
  default = "mysql"
}

variable "rds_engine_version" {
  default = "8.0.28"
}

variable "rds_instance" {
  default = "db.t3.micro"
}

variable "aws_access_key" {
    description = "Your AWS access key"
}

variable "aws_secret_key" {
    description = "Your AWS secret key"
}

variable "ami_id" {
    description = "AMI ID for the EC2 instance"
    default = "ami-007855ac798b5175e"
}

variable "db_user" {
    default = "wpadmin"
}

variable "db_cred" {
    default = "WpPwsd123!"
}

variable "AZ1" {
    default = "us-east-1a"
}

variable "AZ2" {
    default = "us-east-1b"
}

variable "domain_name" {
  description = "Domain name for the WordPress site"
  default     = "hellowordpress-test.com"  
}

variable "subdomain_name" {
  description = "Subdomain name for the WordPress site"
  default     = "wordpress"  
}

variable "okta_domain" {
    description = "provide okta domain"
}

variable "okta_app_id" {
    description = "provide okta app id"
}

variable "okta_metadata_file" {
    description = "provide okta SSO metadata configuration file"
    default = "metadata.xml"
}

variable "okta_org_name" {
    description = "provide okta org name"
    
}

variable "okta_api_token" {
    description = "provide okta api token"
    
}

variable "wp_admin" {
    default = "admin"
    
}

variable "wp_admin_creds" {
    default = "password"
    
}

variable "wp_admin_email_add" {
    default = "admin@hellowordpress-test.com"
    
}





