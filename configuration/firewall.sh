#!/bin/bash
set -e

source "$(dirname "$0")/utils.sh"

# Config firewall

apt-get install -y ufw

ufw deny incoming
ufw allow outgoing