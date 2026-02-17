#!/usr/bin/env bash
set -euo pipefail

APP_DIR="/var/www/app"
VENV_DIR="$APP_DIR/venv"

python3 -m venv "$VENV_DIR"
"$VENV_DIR/bin/pip" install --upgrade pip --quiet
"$VENV_DIR/bin/pip" install -r "$APP_DIR/requirements.txt" --quiet
chown -R ec2-user:ec2-user "$APP_DIR"

