#!/bin/bash
OKTA_DOMAIN=$1
WORDPRESS_PATH="/var/www/html"


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
    echo '<p><a href="https://$OKTA_DOMAIN">Login with Okta</a></p>';
}

// Load the default login functionality
wp_login_form();
EOF

echo "wp-login.php configured successfully!"


