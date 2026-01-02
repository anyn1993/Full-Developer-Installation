#!/bin/bash

if [ -z "$1" ]; then
    echo "================================================"
    echo "  Restore Developer Installation Stack"
    echo "================================================"
    echo ""
    echo "Usage: ./restore.sh <backup_directory>"
    echo ""
    echo "Example:"
    echo "   ./restore.sh backups/backup_20240101_120000"
    echo ""
    echo "Available backups:"
    if [ -d "backups" ]; then
        ls -1 backups/ | grep "backup_"
    else
        echo "   No backups found"
    fi
    echo ""
    exit 1
fi

BACKUP_DIR="$1"

if [ ! -d "$BACKUP_DIR" ]; then
    echo "❌ Backup directory not found: $BACKUP_DIR"
    exit 1
fi

echo "================================================"
echo "  Restore Developer Installation Stack"
echo "================================================"
echo ""
echo "⚠️  WARNING: This will replace existing data!"
echo ""
read -p "Are you sure you want to continue? (yes/no) " -r
echo
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Restore cancelled."
    exit 0
fi

# Get the project name (directory name)
PROJECT_NAME=$(basename "$(pwd)" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')

echo ""
echo "📦 Restoring from: $BACKUP_DIR"
echo ""

# List of volumes to restore
VOLUMES=(
    "certbot_data"
    "gitlab_config"
    "gitlab_data"
    "portainer_data"
    "registry_data"
    "nextcloud_db"
    "nextcloud_data"
    "nextcloud_config"
    "mosquitto_data"
    "n8n_data"
    "jenkins_home"
    "homarr_data"
)

echo "📋 Restoring volumes..."
echo ""

for volume in "${VOLUMES[@]}"; do
    BACKUP_FILE="${BACKUP_DIR}/${volume}.tar.gz"
    FULL_VOLUME_NAME="${PROJECT_NAME}_${volume}"
    
    if [ -f "$BACKUP_FILE" ]; then
        echo "   Restoring: $volume"
        
        # Create volume if it doesn't exist
        docker volume create "$FULL_VOLUME_NAME" > /dev/null 2>&1
        
        # Restore data
        docker run --rm \
            -v "${FULL_VOLUME_NAME}:/data" \
            -v "$(pwd)/${BACKUP_DIR}:/backup" \
            ubuntu tar xzf "/backup/${volume}.tar.gz" -C /data 2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo "   ✅ Restored: $volume"
        else
            echo "   ❌ Failed to restore $volume"
        fi
    else
        echo "   ⚠️  Backup file not found: ${volume}.tar.gz (skipping)"
    fi
done

# Restore configuration files
CONFIG_BACKUP="${BACKUP_DIR}/config_files.tar.gz"
if [ -f "$CONFIG_BACKUP" ]; then
    echo ""
    echo "📋 Restoring configuration files..."
    tar xzf "$CONFIG_BACKUP" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "   ✅ Configuration files restored"
    else
        echo "   ❌ Failed to restore configuration files"
    fi
fi

echo ""
echo "================================================"
echo "  ✅ Restore completed!"
echo "================================================"
echo ""
echo "📝 Next steps:"
echo "   1. Review the restored configuration files"
echo "   2. Start services: ./start.sh"
echo ""

