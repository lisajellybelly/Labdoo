#!/bin/bash

echo "
===> Set the domain name (fqdn)

This is the domain that you have (or plan to get)
for the labdoo.

It will modify the files:
 1) /etc/hostname
 2) /etc/hosts
 3) /etc/nginx/sites-available/lbd*
 4) /etc/apache2/sites-available/lbd*
 5) /var/www/lbd*/sites/default/settings.php
"

if [ -z "${domain+xxx}" -o "$domain" = '' ]
then
    domain='example.org'
    read -p "Enter the domain name for labdoo [$domain]: " input
    domain=${input:-$domain}
fi

echo $domain > /etc/hostname
sed -i /etc/hosts.conf \
    -e "1c 127.0.0.1 $domain"
/etc/hosts_update.sh

### change config files
for file in $(ls /etc/nginx/sites-available/lbd*)
do
    sed -i $file -e "s/server_name .*\$/server_name $domain;/"
done
for file in $(ls /etc/apache2/sites-available/lbd*)
do
    sed -i $file \
        -e "s#ServerName .*\$#ServerName $domain#" \
        -e "s#RedirectPermanent .*\$#RedirectPermanent / https://$domain/#"
done
for file in $(ls /var/www/lbd*/sites/default/settings.php)
do
    sed -i $file -e "/^\\\$base_url/c \$base_url = \"https://$domain\";"
done
