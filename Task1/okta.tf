
terraform {
  required_providers {
    okta = {
      source = "okta/okta"
      version = "~> 4.0"
    }
  }
}

provider "okta" {
  org_name  = var.okta_org_name
  api_token = var.okta_api_token
}


#create Admin users
resource "okta_user" "admin_user1" {
  
    first_name = "Admin"
    last_name  = "User1"
    email      = "admin1@hellowordpress-test.com"
    login      = "admin1@hellowordpress-test.com"
    password =  "AdminUser1Password"
    
  
}

resource "okta_user" "admin_user2" {
    first_name = "Admin"
    last_name  = "User2"
    email      = "admin2@hellowordpress-test.com"
    login      = "admin2@hellowordpress-test.com"
    password = "AdminUser2Password"

}

#Create Normal Users
resource "okta_user" "normal_user1" {
 
    first_name = "Normal"
    last_name  = "User1"
    email      = "normal1@hellowordpress-test.com"
    login      = "normal1@hellowordpress-test.com"
    password = "NormalUser1Password"
  
}

resource "okta_user" "normal_user2" {

    first_name = "Normal"
    last_name  = "User2"
    email      = "normal2@hellowordpress-test.com"
    login      = "normal2@hellowordpress-test.com"
    password = "NormalUser2Password"
  

}

  resource "okta_user" "normal_user3" {
 
    first_name = "Normal"
    last_name  = "User3"
    email      = "normal3@hellowordpress-test.com"
    login      = "normal3@hellowordpress-test.com"
    password = "NormalUser3Password"
 
}


# Create groups
resource "okta_group" "admins" {
  name = "Admins"
}

resource "okta_group" "users" {
  name = "Users"
}


resource "okta_group_memberships" "admin_membership" {
  group_id = okta_group.admins.id
  users = [
    okta_user.admin_user1.id,
    okta_user.admin_user2.id,
  ]
}

resource "okta_group_memberships" "user_membership" {
  group_id = okta_group.users.id
  users = [
    okta_user.normal_user1.id,
    okta_user.normal_user2.id,
    okta_user.normal_user3.id,
  ]
}

#Assign roles to create group
resource "okta_group_role" "admins_roles" {
  group_id = okta_group.admins.id
  role_type = "USER_ADMIN"
}



