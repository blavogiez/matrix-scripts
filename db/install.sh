#!/bin/bash
set -e

# Variables
ID="${1:-123}"
DB_USER="${2:-synapse_user}"
DB_USER_PASS="${3:-synapse_user}"
DB_NAME="${4:-matrix}"


echo "installation postgresql pour synapse"
echo "utilisateur: $DB_USER"
echo "base: $DB_NAME"
echo ""

# Installation
echo "installation du paquet postgresql..."
apt-get install -y postgresql

# Demarrage service
echo "demarrage du service..."
systemctl start postgresql
systemctl enable postgresql

# Creation utilisateur et base (en tant que postgres)
echo "creation utilisateur $DB_USER..."
su - postgres -c "createuser $DB_USER" 2>/dev/null

echo "configuration mot de passe..."
su - postgres -c "psql -c \"ALTER USER $DB_USER PASSWORD '$DB_USER_PASS';\""

echo "creation base $DB_NAME avec bon encoding..."
su - postgres -c "dropdb $DB_NAME" 2>/dev/null
su - postgres -c "createdb --encoding=UTF8 --locale=C --template=template0 --owner=$DB_USER $DB_NAME"

echo ""
echo "création BDD terminee"

# Modification fichier configuration 

# on écoute matrix

sed -i -e 's/#listen_addresses = .*/listen_addresses = '\''localhost,10.42.123.3'\''/' /etc/postgresql/*/main/postgresql.conf

echo "Ce sont les adresses désormais écoutées"
cat /etc/postgresql/*/main/postgresql.conf | grep listen_addresses

# on autorise l'utilisateur synapse_user à se connecter à la base matrix
echo "configuration des accès..."
echo "host    matrix    synapse_user    matrix   scram-sha-256" >> /etc/postgresql/*/main/pg_hba.conf

systemctl restart postgresql