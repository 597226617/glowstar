#!/bin/bash

# GlowStar Deployment Script
# Deploys the application to production server

set -e

# Configuration
SERVER_IP="47.101.134.80"
SERVER_USER="glowstar"
DEPLOY_DIR="/home/glowstar/glowstar"
BACKUP_DIR="/home/glowstar/backups"

echo "🚀 Starting GlowStar deployment..."

# Create backup
echo "📦 Creating backup..."
ssh ${SERVER_USER}@${SERVER_IP} "mkdir -p ${BACKUP_DIR}"
ssh ${SERVER_USER}@${SERVER_IP} "cp -r ${DEPLOY_DIR} ${BACKUP_DIR}/glowstar-$(date +%Y%m%d_%H%M%S)"

# Deploy new version
echo "📤 Uploading new version..."
rsync -avz --exclude 'node_modules' --exclude '.git' ../ ${SERVER_USER}@${SERVER_IP}:${DEPLOY_DIR}/

# Install dependencies
echo "📦 Installing dependencies..."
ssh ${SERVER_USER}@${SERVER_IP} "cd ${DEPLOY_DIR} && npm install --production"

# Build frontend
echo "🔨 Building frontend..."
ssh ${SERVER_USER}@${SERVER_IP} "cd ${DEPLOY_DIR}/client && flutter build web --release"

# Restart services
echo "🔄 Restarting services..."
ssh ${SERVER_USER}@${SERVER_IP} "cd ${DEPLOY_DIR} && docker-compose down"
ssh ${SERVER_USER}@${SERVER_IP} "cd ${DEPLOY_DIR} && docker-compose up -d"

# Health check
echo "🔍 Running health check..."
sleep 10
curl -f http://${SERVER_IP}/api/health || {
    echo "❌ Health check failed! Rolling back..."
    ssh ${SERVER_USER}@${SERVER_IP} "cd ${DEPLOY_DIR} && docker-compose down"
    ssh ${SERVER_USER}@${SERVER_IP} "cd ${DEPLOY_DIR} && cp -r ${BACKUP_DIR}/glowstar-latest/* ."
    ssh ${SERVER_USER}@${SERVER_IP} "cd ${DEPLOY_DIR} && docker-compose up -d"
    exit 1
}

echo "✅ Deployment completed successfully!"
echo "🌐 Application is running at http://${SERVER_IP}"
