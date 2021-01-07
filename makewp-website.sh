#!/bin/bash

#
# By O. Echevarria
# Purpose of this script is to create a generic WordPress site set up
# The script generates the website directories, configuration files and SSL CSR/Key
# Copyright 2019
# License: GPV version 2
#

createRobotsFile(){
    
echo "User-agent: *" > $sitewww/robot.txt
echo "" 
echo "Disallow: /feed/" >> $sitewww/robot.txt
echo "Disallow: /trackback/" >> $sitewww/robot.txt
echo "Disallow: /wp-admin/" >> $sitewww/robot.txt
echo "Disallow: /wp-content/" >> $sitewww/robot.txt
echo "Disallow: /wp-includes/" >> $sitewww/robot.txt
echo "Disallow: /xmlrpc.php" >> $sitewww/robot.txt
echo "Disallow: /wp-" >> $sitewww/robot.txt
    
}


createSiteDir(){

    read -p "Enter Site Name: " sitename
#    read sitename

    echo "Creating $sitename directory"
        mkdir "$produrldir/$sitename"

    echo "Creating $sitename publishing directory"
        mkdir "$produrldir/$sitename/public_html"

    sitedir="$produrldir/$sitename"
    sitewww="$produrldir/$sitename/public_html"

}

createSiteCnf(){

        echo "<VirtualHost *:80>" >> $sitename.conf
        echo "" >> $sitename.conf
        echo "        DocumentRoot '$sitewww'" >> $sitename.conf
        echo "        ServerName $sitename" >> $sitename.conf
        echo "        ServerAlias www.$sitename" >> $sitename.conf
    echo "        Options All -Indexes"
        echo "        ErrorLog /var/log/httpd/$sitename-error.log" >> $sitename.conf
        echo "        CustomLog /var/log/httpd/$sitename-access.log combined" >> $sitename.conf
        echo "" >> $sitename.conf
    echo ""
    echo '<FilesMatch "^.*(error_log|wp-config\.php|php.ini|\.[hH][tT][aApP].*)$">'
    echo "Order deny,allow"
    echo "Deny from all"
    echo "</FilesMatch>"
    echo "<Directory '$sitewww/wp-content/uploads/'"
    echo ""
    echo "# Prevent PHP File Execution"
    echo "<Files '*.php'>"
    echo "Order Deny,Allow"
    echo "Deny from All"
    echo "</Files>"
    echo "</Directory>"
    echo ""
    echo "RewriteRule wp-content/plugins/(.*\.php)$ - [R=404,L]"
    echo "RewriteRule wp-content/themes/(.*\.php)$ - [R=404,L]"
    echo ""
    echo "# Disable Script injections"
    echo ""
    echo ""
    echo "Options +FollowSymLinks"
    echo "RewriteEngine On"
    echo "RewriteCond %{QUERY_STRING} (<|%3C).*script.*(>|%3E) [NC,OR]"
    echo "RewriteCond %{QUERY_STRING} GLOBALS(=|[|%[0-9A-Z]{0,2}) [OR]"
    echo "RewriteCond %{QUERY_STRING} _REQUEST(=|[|%[0-9A-Z]{0,2})"
    echo "RewriteRule ^(.*)$ index.php [F,L]    "
    echo ""
    echo ""
    echo "<IfModule mod_rewrite.c>"
    echo "RewriteEngine On"
    echo "RewriteBase /"
    echo "RewriteRule ^wp-admin/includes/ - [F,L]"
    echo "RewriteRule !^wp-includes/ - [S=3]"
    echo "RewriteRule ^wp-includes/[^/]+\.php$ - [F,L]"
    echo "RewriteRule ^wp-includes/js/tinymce/langs/.+\.php - [F,L]"
    echo "RewriteRule ^wp-includes/theme-compat/ - [F,L]"
    echo "</IfModule>"

        echo '</VirtualHost>' >> $sitename.conf

}

createUserInfo(){

        genuser=$(openssl rand -hex 7)
    echo "Creating user: db$genuser"
    
        genpass=$(openssl rand -base64 48)
    echo "Creating password: $genpass"
    
    echo "" > $sitename.db.txt
    
    echo "User: db$genuser" >> $sitename.db.txt
    echo "Password: $genpass" >> $sitename.db.txt

}

createCSRKey(){

openssl req -nodes -newkey rsa:2048 -keyout $sitename.key -out $sitename.csr -subj "/C=US/ST=Connecticut/L=Storrs/O=UConn/OU=ENGR/CN=$sitename"

echo "$sitename.key: created"
echo "$sitename.csr: created"

}

    produrldir="/var/www"
    sitename=""
    sitedir=""
    sitewww=""
    genuser=""
    genpass=""

createSiteDir 

echo "" > $sitename.conf

createUserInfo

createSiteCnf

createCSRKey
