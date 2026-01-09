#!/bin/bash 
set -e

source "$(dirname "$0")/../configuration/utils.sh"

log_info "Ajout des dépôts matrix.org"

apt install -y lsb-release wget apt-transport-https
wget -O /usr/share/keyrings/matrix-org-archive-keyring.gpg https://packages.matrix.org/debian/matrix-org-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/matrix-org-archive-keyring.gpg] https://packages.matrix.org/debian/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/matrix-org.list

# configurer les permissions (sinon ça ne fonctionne pas)
chmod o+r /usr/share/keyrings/matrix-org-archive-keyring.gpg

log_info "Mise à jour des dépôts APT"

apt update

log_info "Installation de Synapse" 

# présélections pour la configuration de synapse
echo "matrix-synapse matrix-synapse/server-name string $INSTANCE_NAME" | sudo debconf-set-selections
apt install -y matrix-synapse-py3

log_info "Écriture de la configuration synapse"
log_info "FICHIER: /etc/matrix-synapse/homserver.yaml"

cat > /etc/matrix-synapse/homeserver.yaml << EOF
pid_file: "/var/run/matrix-synapse.pid"
listeners:
  - port: 8008
    tls: false
    type: http
    x_forwarded: true
    resources:
      - names: [client, federation]
        compress: false
database:
  name: psycopg2
  args:
    user: $DB_USER
    password: $DB_USER_PASS
    dbname: $DB_NAME
    host: $DB_HOSTNAME
    cp_min: 5
    cp_max: 10

log_config: "/etc/matrix-synapse/log.yaml"
media_store_path: /var/lib/matrix-synapse/media
signing_key_path: "/etc/matrix-synapse/homeserver.signing.key"
trusted_key_servers: []
enable_registration: true
enable_registration_without_verification: true

EOF

log_info "Redémarrage du serveur Synapse" 

systemctl restart matrix-synapse


