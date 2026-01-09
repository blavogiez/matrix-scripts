#!/bin/bash

set -e

source "$(dirname "$0")/../configuration/utils.sh"

log_info "Installation du serveur nginx"

apt install -y nginx

log_info "Écriture de la configuration du Reverse Proxy"

cat > /etc/nginx/sites-available/matrix-reverse-proxy << EOF

server {
  listen 80;
  server_name element.$INSTANCE_NAME;

  # Element Web sur VM dédiée element:80
  location / {
    proxy_pass http://$ELEMENT_HOSTNAME:80;
    # ou : proxy_pass http://element:80;
  }
}

server {
  listen 80;
  server_name matrix.$INSTANCE_NAME;

  # Synapse sur VM matrix:8008
  location / {
    proxy_pass http://$MATRIX_HOSTNAME:8008;
    # ou : proxy_pass http://matrix:8008;
  }
}

EOF

log_info "Configuration des liens symboliques nginx"

# Supprimer le site par défaut
rm -f /etc/nginx/sites-enabled/default

# Activer le site via lien symbolique
ln -sf /etc/nginx/sites-available/matrix-reverse-proxy /etc/nginx/sites-enabled/matrix-reverse-proxy

log_info "Redémarrage du serveur nginx"

systemctl restart nginx


