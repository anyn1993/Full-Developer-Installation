#!/bin/bash

echo "================================================"
echo "  Backup Developer Installation Stack"
echo "================================================"
echo ""

# Create backup directory with timestamp
BACKUP_DIR="backups/backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "📦 Creating backups in: $BACKUP_DIR"
echo ""

# List of volumes to backup
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

# Get the project name (directory name)
PROJECT_NAME=$(basename "$(pwd)" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')

echo "📋 Backing up volumes..."
echo ""

for volume in "${VOLUMES[@]}"; do
    FULL_VOLUME_NAME="${PROJECT_NAME}_${volume}"
    
    # Check if volume exists
    if docker volume ls | grep -q "$FULL_VOLUME_NAME"; then
        echo "   Backing up: $volume"
        docker run --rm \
            -v "${FULL_VOLUME_NAME}:/data" \
            -v "$(pwd)/${BACKUP_DIR}:/backup" \
            ubuntu tar czf "/backup/${volume}.tar.gz" -C /data . 2>/dev/null
        
        if [ $? -eq 0 ]; then
            SIZE=$(du -h "${BACKUP_DIR}/${volume}.tar.gz" | cut -f1)
            echo "   ✅ ${volume}.tar.gz (${SIZE})"
        else
            echo "   ❌ Failed to backup $volume"
        fi
    else
        echo "   ⚠️  Volume not found: $FULL_VOLUME_NAME (skipping)"
    fi
done

# Backup configuration files
echo ""
echo "📋 Backing up configuration files..."
tar czf "${BACKUP_DIR}/config_files.tar.gz" \
    docker-compose.yml \
    nginx/ \
    harbor/ \
    .gitignore \
    README.md \
    *.sh 2>/dev/null

if [ $? -eq 0 ]; then
    SIZE=$(du -h "${BACKUP_DIR}/config_files.tar.gz" | cut -f1)
    echo "   ✅ config_files.tar.gz (${SIZE})"
fi

# Calculate total backup size
TOTAL_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)

echo ""
echo "================================================"
echo "  ✅ Backup completed successfully!"
echo "================================================"
echo ""
echo "📊 Backup Summary:"
echo "   Location: $BACKUP_DIR"
echo "   Total size: $TOTAL_SIZE"
echo ""
echo "📝 To restore from this backup:"
echo "   1. Copy the backup directory to the new computer"
echo "   2. Run: ./restore.sh $BACKUP_DIR"
echo ""

