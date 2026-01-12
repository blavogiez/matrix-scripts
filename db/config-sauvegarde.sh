#!/bin/bash
set -e

source "$(dirname "$0")/../configuration/utils.sh"
source "$(dirname "$0")/../config.env"

log_info "======================================="
log_info "Configuration de la sauvegarde DB distante vers vm backup"
log_info "======================================="

# Construction de l'IP de la VM backup
BACKUP_IP="$IP_PREFIX.$IP_OCTET3.$BACKUP_SUFFIX"

log_info "VM backup  : $BACKUP_HOSTNAME"
log_info "IP backup : $BACKUP_IP"
log_info "Repertoire distant (vm backup) : /var/backups/matrix"
echo

# Installation de sshpass pour automatisation (on log ssh sans prompt)
log_task "Installation de sshpass..."
apt-get install -f -y sshpass

# Creation du répertoire local de sauvegarde
log_task "Creation du répertoire /var/backups/postgresql..."
mkdir -p /var/backups/postgresql
chown postgres:postgres /var/backups/postgresql
chmod 700 /var/backups/postgresql
log_success "Répertoire créé"

# Configuration SSH pour connexion sans mot de passe
log_task "Configuration SSH vers VM backup..."

# Génération de la clé SSH si elle n'existe pas (normalement c'est toujours bon)
if [ ! -f /root/.ssh/id_rsa ]; then
    log_info "Génération de la clé SSH..."
    mkdir -p /root/.ssh
    ssh-keygen -t rsa -b 4096 -C "backup-db-to-backup" -f /root/.ssh/id_rsa -N ""
    log_success "Clé générée"
else
    log_info "Clé SSH existante"
fi

# copie de la clé vers backup avec sshpass
log_info "Copie de la clé SSH vers $BACKUP_HOSTNAME..."
sshpass -p "$USER_PASS" ssh-copy-id -o StrictHostKeyChecking=no $DEFAULT_USER@$BACKUP_IP

# Test de connexion
log_info "Test de connexion SSH..."
ssh -o StrictHostKeyChecking=no $DEFAULT_USER@$BACKUP_IP "echo 'Connexion OK'"
log_success "SSH configuré avec succès"
echo

# Creation du script de sauvegarde (identique à la procedure)
log_task "Creation du script /usr/local/bin/backup-synapse.sh..."
cat > /usr/local/bin/backup-synapse.sh << EOF
#!/bin/bash
# script de sauvegarde automatique de la base Matrix

# config
DB_NAME="$DB_NAME"
BACKUP_DIR="/var/backups/postgresql"
RETENTION_DAYS=7

DATE=\$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="\${BACKUP_DIR}/matrix_\${DATE}.dump"
LOG_FILE="\${BACKUP_DIR}/backup.log"

# On se place dans le répertoire de sauvegarde
cd "\$BACKUP_DIR"

# Fonction de log
log() {
    echo "[\$(date '+%Y-%m-%d %H:%M:%S')] \$1" >> "\$LOG_FILE"
}

# Sauvegarde de la base
log "Début de la sauvegarde"
log "Base : \$DB_NAME → \$BACKUP_FILE"

if sudo -u postgres pg_dump -d "\$DB_NAME" -Fc -f "\$BACKUP_FILE"; then
    log "Sauvegarde réussie (\$(du -h "\$BACKUP_FILE" | cut -f1))"
else
    log "ERR : Échec de la sauvegarde"
    exit 1
fi

# clean des sauvegardes anciennes
log "Nettoyage des sauvegardes de plus de \$RETENTION_DAYS jours"
find "\$BACKUP_DIR" -name "matrix_*.dump" -mtime +\$RETENTION_DAYS -delete

REMAINING=\$(find "\$BACKUP_DIR" -name "matrix_*.dump" | wc -l)
log "Sauvegardes locales conservées : \$REMAINING"

# Copie vers VM backup
REMOTE_USER="$DEFAULT_USER"
REMOTE_HOST="$BACKUP_IP"
REMOTE_DIR="/var/backups/matrix"

log "Copie des sauvegardes vers \${REMOTE_HOST}"
if rsync -avz --quiet "\$BACKUP_DIR/" "\${REMOTE_USER}@\${REMOTE_HOST}:\${REMOTE_DIR}/"; then
    log "Copie distante réussie"
else
    log "ERR: Échec de la copie distante (sauvegarde locale OK)"
fi

log "Sauvegarde terminée avec succès"
EOF

chmod +x /usr/local/bin/backup-synapse.sh
log_success "Script créé"

# test du script
log_task "Test du script de sauvegarde..."
/usr/local/bin/backup-synapse.sh
log_success "Test réussi"
echo

# Vérification des fichiers créés
log_info "Vérification des sauvegardes locales:"
ls -lh /var/backups/postgresql/matrix_*.dump 2>/dev/null || log_warning "Aucune sauvegarde trouvée"

log_info "Vérification des logs:"
tail -10 /var/backups/postgresql/backup.log

# Vérification de la copie distante
log_task "Vérification de la copie distante..."
ssh $DEFAULT_USER@$BACKUP_IP "ls -lh /var/backups/matrix/matrix_*.dump 2>/dev/null" || log_warning "Aucune sauvegarde distante"
echo

# Configuration cron
log_task "Configuration cron pour sauvegarde à 2h et 15h..."
(crontab -l 2>/dev/null || true; echo "0 2 * * * /usr/local/bin/backup-synapse.sh"; echo "0 15 * * * /usr/local/bin/backup-synapse.sh") | crontab -
log_success "Cron configuré"

log_info "Vérification cron:"
crontab -l
echo

log_success "======================================="
log_success "Configuration sauvegarde terminée"
log_success "======================================="
log_info "Sauvegarde locale: /var/backups/postgresql (7 jours)"
log_info "Sauvegarde distante: $BACKUP_HOSTNAME:/var/backups/matrix (30 jours)"
log_info "Fréquence: 2x/jour à 2h et 15h"
log_info "Logs: /var/backups/postgresql/backup.log"
log_info "======================================="
