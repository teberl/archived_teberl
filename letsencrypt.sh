#!/bin/bash
function letsencrypt {
    DOMAIN=$1
    echo "Recreate Certificate for Domain $DOMAIN"
    docker run -it --rm -p 443:443 -p 80:80 --name letsencrypt \
        -v /docker/letsencrypt/etc:/etc/letsencrypt \
                certbot/certbot \
        certonly --standalone --agree-tos -d $DOMAIN
}

# PORTS FROM docker service are still used
# docker stack rm phx_client
# docker stack deploy -c /etc/teberl/docker-compose.yml phx_client

# allow temporally access to 443 and 80
ufw allow 80
ufw allow 443

# recreate the certificates
letsencrypt teberl.de

# put the firewall up again
ufw deny 80
ufw deny 443