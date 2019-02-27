#!/bin/bash
function letsencrypt {
    DOMAIN=$1
    echo "Recreate Certificate for Domain $DOMAIN"
    docker run -it --rm -p 443:443 -p 80:80 --name letsencrypt \
        -v /docker/letsencrypt/etc:/etc/letsencrypt \
                certbot/certbot \
        certonly --standalone --agree-tos -d $DOMAIN
}

echo -n "Renew certificate (Y/n): "
read IS_RENEWAL

# PORTS FROM docker service are still used
# docker stack rm phx_client
# docker stack deploy -c /etc/teberl/docker-compose.yml phx_client

# allow temporally access to 443 and 80
ufw allow 80
ufw allow 443

if [ "$IS_RENEWAL" == "n" ]; then
        echo "create certificate a new certificate"
        letsencrypt teberl.de
else
        echo "renew all available certificates"
        # as of version 0.10.0, Certbot supports a renew action 
        # to check all installed certificates for impending expiry and 
        # attempt to renew them. The simplest form is simply
        certbot renew
fi

# put the firewall up again
ufw deny 80
ufw deny 443 