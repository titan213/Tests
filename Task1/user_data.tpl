#!/bin/bash
db_username=${db_username}
db_user_password=${db_user_password}
db_name=${db_name}
db_RDS=${db_RDS}
WORDPRESS_PATH="/var/www/html"


apt update  -y
apt upgrade -y

#Install LAMP 
apt install -y apache2 php php-{pear,cgi,common,curl,mbstring,gd,mysqlnd,bcmath,json,xml,intl,zip,imap,imagick} mysql-client-core-8.0

systemctl enable --now  apache2


# Change OWNER and permission of directory /var/www
usermod -a -G www-data ubuntu
chown -R ubuntu:www-data /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;


#*Installing Wordpress with WP CLI 
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
wp core download --path=/var/www/html --allow-root
wp config create --dbname=$db_name --dbuser=$db_username --dbpass=$db_user_password --dbhost=$db_RDS --path=/var/www/html --allow-root --extra-php <<PHP
define( 'FS_METHOD', 'direct' );
define('WP_MEMORY_LIMIT', '128M');
PHP


# Change permission of /var/www/html/
chown -R ubuntu:www-data /var/www/html
chmod -R 774 /var/www/html

function runAsUbuntu {
    wp core install --url=https://${wp_url} --title="WPTest" --admin_user=${wp_admin} --admin_password=${wp_admin_pw} --admin_email=${wp_admin_email} --path=/var/www/html
    wp config create --dbname=$db_name --dbuser=$db_username --dbpass=$db_user_password --dbhost=$db_RDS --path=/var/www/html --allow-root --extra-php <<PHP
    define( 'FS_METHOD', 'direct' );
    define('WP_MEMORY_LIMIT', '128M');
PHP

}
export -f runAsUbuntu
su ubuntu -c runAsUbuntu

rm /var/www/html/index.html
#  enable .htaccess files in Apache config using sed command
sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride all/' /etc/apache2/apache2.conf
a2enmod rewrite
systemctl restart apache2

function runWpPluginInstallation {
    # Install the user management 
    wp plugin install members  --activate --path=/var/www/html
    # Install SAML plugin
    wp plugin install miniorange-saml-20-single-sign-on --activate --path=/var/www/html
    #update the mo_saml configuration
    wp config set WP_SAML_AUTHENTICATION_IDP_METADATA_URL ${saml_sp_metadata_url}
    wp config set WP_SAML_AUTHENTICATION_IDP_ENTITY_ID ${saml_sp_entity_id}
    wp config set WP_SAML_AUTHENTICATION_SSO_URL ${saml_sp_sso_url}
    wp config set WP_SAML_AUTHENTICATION_CERTIFICATE ${saml_sp_certificate}

    

}
export -f runWpPluginInstallation
su ubuntu -c runWpPluginInstallation



systemctl restart apache2
echo WordPress Installed
