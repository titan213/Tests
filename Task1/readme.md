
*Note:

    I have Automated to create the saml app configration using terraform okta provider as well.  And the associated sso info will be used in Word press configuration. 

main.tf: Contains AWS resources creation 
user_data.tpl: Contains LAP stack and Wordpress initial configuration including SSO/SAML integration.
saml-conf.sh: Includes the login page creation.
okta.tf: Contains okta saml app creation, user creation, group creation and assignment and app integration

