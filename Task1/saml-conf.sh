#!/bin/bash
METADATA_FILE=$1
OKTA_DOMAIN=$2
OKTA_APP_ID=$3
WORDPRESS_PATH="/var/www/html/wordpress"


# Configure the SAML settings in wp-config.php
cat <<EOF >> $WORDPRESS_PATH/wp-config.php
define('WP_SAML_AUTHENTICATION_IDP_METADATA_URL', '');
define('WP_SAML_AUTHENTICATION_IDP_ENTITY_ID', '');
define('WP_SAML_AUTHENTICATION_SSO_URL', '');
define('WP_SAML_AUTHENTICATION_SLO_URL', '');
define('WP_SAML_AUTHENTICATION_CERTIFICATE', '');
EOF

# Import Okta metadata
wp saml import $METADATA_FILE --path=$WORDPRESS_PATH --allow-root

# Update the SAML settings in wp-config.php
wp option update wp_saml_authentication_settings --path=$WORDPRESS_PATH --allow-root

echo "SAML SSO setup completed successfully!"

#set admin roles in members plugin
wp option set members_group_role_mappings "{\"Admins\":\"Administrator\"}" --path=$WORDPRESS_PATH --allow-root
#set User roles roles in members plugin : this might not work
wp option set members_group_role_mappings "{\"Users\":\"Author\"}" --path=$WORDPRESS_PATH --allow-root

# wp-login.php file
cat <<EOF > ${WORDPRESS_PATH}/wp-login.php
<?php
/**
 * WordPress Login Form
 *
 * @package WordPress
 */

// Load WordPress bootstrap.
require_once( dirname( dirname( __FILE__ ) ) . '/wp-load.php' );

//  custom login page title
add_filter( 'login_title', 'custom_login_title' );
function custom_login_title( \$title ) {
    return 'Custom Login Page Title';
}


// Add Okta SSO link to the login page
add_action( 'login_form', 'add_okta_sso_link' );
function add_okta_sso_link() {
    echo '<p><a href="https://$OKTA_DOMAIN/app/$OKTA_APP_ID/sso/saml">Login with Okta</a></p>';
}

// Load the default login functionality
wp_login_form();
EOF

echo "wp-login.php configured successfully!"


systemctl restart apache2
