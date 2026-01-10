#!/bin/bash
set -e

source "$(dirname "$0")/../configuration/utils.sh"

# Variables

log_info "Installation Postgresql pour Synapse"
log_info "Utilisateur: $DB_USER"
log_info "Base: $DB_NAME"

# Installation
log_task "Installation du paquet postgresql..."
apt-get install -y postgresql

# Demarrage service
log_task "Démarrage du service..."
systemctl start postgresql
systemctl enable postgresql

# Creation utilisateur et base (en tant que postgres)
log_task "Création utilisateur $DB_USER..."
su - postgres -c "createuser $DB_USER" 2>/dev/null || log_warning "L'utilisateur existe peut-être déjà"

log_task "Configuration mot de passe..."
su - postgres -c "psql -c \"ALTER USER $DB_USER PASSWORD '$DB_USER_PASS';\""

log_task "Création base $DB_NAME avec bon encoding..."
su - postgres -c "dropdb $DB_NAME" 2>/dev/null || true
su - postgres -c "createdb --encoding=UTF8 --locale=C --template=template0 --owner=$DB_USER $DB_NAME"

log_success "Création BDD terminée"

# Modification fichier configuration 

# on écoute matrix
log_task "Modification configuration pour écoute réseau..."

sed -i -e 's/#listen_addresses = .*/listen_addresses = '\''localhost,10.42.123.3'\''/' /etc/postgresql/*/main/postgresql.conf

log_info "Adresses écoutées:"
cat /etc/postgresql/*/main/postgresql.conf | grep listen_addresses

# on autorise l'utilisateur synapse_user à se connecter à la base matrix
log_task "Configuration des accès (pg_hba.conf)..."
echo "host    matrix    synapse_user    matrix   scram-sha-256" >> /etc/postgresql/*/main/pg_hba.conf

log_task "Redémarrage postgresql..."
systemctl restart postgresql
log_success "Installation DB terminée"

# Configuration sauvegarde automatique
log_task "Configuration sauvegarde vers VM backup..."
bash "$(dirname "$0")/config-sauvegarde.sh"
