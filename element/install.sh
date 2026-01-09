#!/bin/bash
set -e

# version évolutive dans le temps
ELEMENT_VERSION="${1:-1.11.85}"

# Source config.env pour PHYS_HOSTNAME et IP
source "$(dirname "$0")/../configuration/config.env"

echo "installation element web"
echo "version: $ELEMENT_VERSION"
echo "hostname physique: $PHYS_HOSTNAME.iutinfo.fr"
echo ""

# Installation nginx
echo "installation du paquet nginx..."
apt-get install -y nginx
systemctl start nginx
systemctl enable nginx

# Telechargement Element Web
echo "telechargement element v$ELEMENT_VERSION..."
cd /tmp
wget https://github.com/element-hq/element-web/releases/download/v${ELEMENT_VERSION}/element-v${ELEMENT_VERSION}.tar.gz

# extraction et permissions
echo "extraction dans /var/www/element..."
tar -xzf element-v${ELEMENT_VERSION}.tar.gz
rm -rf /var/www/element
mv element-v${ELEMENT_VERSION} /var/www/element
chown -R www-data:www-data /var/www/element
chmod -R 755 /var/www/element

# Configuration config.json
echo "configuration element..."
cd /var/www/element
cp config.sample.json config.json

# Modification du config.json avec sed pour base_url et server_name
sed -i 's|"base_url": "https://matrix-client.matrix.org"|"base_url": "http://matrix:8008"|' config.json
sed -i 's|"server_name": "matrix.org"|"server_name": "'"${PHYS_HOSTNAME}.iutinfo.fr:8008"'"|' config.json

# Configuration nginx
echo "configuration nginx..."
cat > /etc/nginx/sites-available/element <<'EOF'
server {
    listen 80;
    listen [::]:80;

    server_name _;

    root /var/www/element;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
EOF

# suppression du site par defaut (qui bloque le port 80) et activation element
rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/element /etc/nginx/sites-enabled/element

# Test et reload
echo "test de la configuration nginx..."
nginx -t
systemctl reload nginx

echo ""
echo "installation element terminee"
