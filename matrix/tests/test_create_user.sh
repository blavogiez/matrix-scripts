#!/bin/bash

USERNAME="${1:-testuser}"
PASSWORD="${2:-testpass123}"
DB_HOST="${3:-10.42.123.3}"
SYNAPSE_PORT=8008
SYNAPSE_URL="http://localhost:$SYNAPSE_PORT"

echo "test creation utilisateur synapse"
echo "utilisateur: $USERNAME"
echo "mot de passe: $PASSWORD"
echo "host db: $DB_HOST"
echo "port synapse: $SYNAPSE_PORT"
echo ""

echo "verification si l'utilisateur existe deja..."
EXISTING=$(PGPASSWORD=synapse_user psql -h $DB_HOST -U synapse_user -d matrix -t -c "select 1 from users where name like '%$USERNAME%';")
EXISTING_PROFILE=$(PGPASSWORD=synapse_user psql -h $DB_HOST -U synapse_user -d matrix -t -c "select 1 from profiles where user_id like '%$USERNAME%';")

if [ ! -z "$EXISTING" ] || [ ! -z "$EXISTING_PROFILE" ]; then
    echo "utilisateur ou profil existant detecte"
    echo "nettoyage complet de l'utilisateur..."
    PGPASSWORD=synapse_user psql -h $DB_HOST -U synapse_user -d matrix << EOF
delete from profiles where user_id like '%$USERNAME%';
delete from users where name like '%$USERNAME%';
delete from user_threepids where user_id like '%$USERNAME%';
delete from access_tokens where user_id like '%$USERNAME%';
delete from devices where user_id like '%$USERNAME%';
delete from user_filters where user_id like '%$USERNAME%';
EOF
    echo "utilisateur nettoye"
    echo ""
fi

echo "creation de l'utilisateur (non admin)..."
register_new_matrix_user \
    -c /etc/matrix-synapse/homeserver.yaml \
    -u $USERNAME \
    -p $PASSWORD \
    --no-admin \
    $SYNAPSE_URL

if [ $? -ne 0 ]; then
    echo "echec creation utilisateur"
    exit 1
fi

echo "utilisateur cree"
echo ""

echo "verification dans la base de donnees..."
RESULT=$(PGPASSWORD=synapse_user psql -h $DB_HOST -U synapse_user -d matrix -t -c "select 1 from users where name like '%$USERNAME%';")

if [ -z "$RESULT" ]; then
    echo "utilisateur non trouve dans la base"
    exit 1
fi

echo "utilisateur trouve dans postgres"
echo ""
echo "test reussi"
