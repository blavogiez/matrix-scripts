#!/bin/bash
set -e

source "$(dirname "$0")/../configuration/utils.sh"
source "$(dirname "$0")/../configuration/config.env"

log_info "Installation du serveur de sauvegarde"

# Installation rsync (déjà fait dans config mais on refait pour etre sur)
log_task "Installation de rsync..."
apt-get install -y rsync

# Creation du répertoire de sauvegarde
log_task "Creation du répertoire /var/backups/matrix..."
mkdir -p /var/backups/matrix
chown $DEFAULT_USER:$DEFAULT_USER /var/backups/matrix
chmod 700 /var/backups/matrix

log_success "Répertoire créé avec permissions 700"

# Creation du script de nettoyage
log_task "Creation du script de nettoyage..."
cat > /usr/local/bin/cleanup-old-backups.sh << 'EOF'
#!/bin/bash
# script de nettoyage automatique des anciennes sauvegardes

BACKUP_DIR="/var/backups/matrix"
RETENTION_DAYS=30
LOG_FILE="${BACKUP_DIR}/cleanup.log"

# Creation du log si inexistant
touch "$LOG_FILE"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Nettoyage des sauvegardes de plus de $RETENTION_DAYS jours" >> "$LOG_FILE"

# Suppression des anciennes sauvegardes
find "$BACKUP_DIR" -name "matrix_*.dump" -mtime +$RETENTION_DAYS -delete

# Compte les sauvegardes restantes
REMAINING=$(find "$BACKUP_DIR" -name "matrix_*.dump" 2>/dev/null | wc -l)
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Sauvegardes restantes: $REMAINING" >> "$LOG_FILE"
EOF

chmod +x /usr/local/bin/cleanup-old-backups.sh
log_success "Script de nettoyage créé"

# config cron pour nettoyage quotidien à 2h
log_task "config cron pour nettoyage automatique..."
(crontab -l 2>/dev/null || true; echo "* * * * * /usr/local/bin/cleanup-old-backups.sh") | crontab -
log_success "Cron configuré (tous les jours à 23h)"

# Vérification cron
log_info "Verif cron:"
crontab -l

log_success "installation  serveur backup terminée"
log_info "Dossier   : /var/backups/matrix (700)"
log_info "Nettoyage auto après 30 jours"
