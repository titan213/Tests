## Note:

I have automated the creation of the SAML app configuration and user creation using Terraform with the Okta provider. The associated SSO information will be used in the WordPress configuration.

**Files:**

- `main.tf`: Contains AWS resource creation.
- `user_data.tpl`: Contains LAMP stack and WordPress initial configuration, including SSO/SAML integration.
- `saml-conf.sh`: Includes the login page creation.
- `okta.tf`: Contains Okta SAML app creation, user creation, group creation and assignment, and app integration.
