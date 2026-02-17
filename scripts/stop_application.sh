#!/usr/bin/env bash
set -euo pipefail

# Stop and disable service if it exists
systemctl stop flask-app.service 2>/dev/null || true
systemctl disable flask-app.service 2>/dev/null || true

# Kill any process on port 8000
lsof -ti:8000 | xargs kill -9 2>/dev/null || true
