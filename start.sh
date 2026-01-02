#!/bin/bash

echo "================================================"
echo "  Developer Tools Stack"
echo "================================================"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    echo "   Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is available
if ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not available. Please update Docker."
    echo "   Visit: https://docs.docker.com/compose/install/"
    exit 1
fi

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    echo "❌ Docker daemon is not running. Please start Docker first."
    exit 1
fi

echo "✅ Docker and Docker Compose are ready"
echo ""

# Check for .env file
if [ ! -f ".env" ]; then
    echo "📝 Creating .env file from template..."
    cp env.example .env
    echo "   Edit .env to customize your configuration"
    echo ""
fi

# Check available disk space
if command -v df &> /dev/null; then
    available_space=$(df -BG . | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ "$available_space" -lt 50 ]; then
        echo "⚠️  Warning: Less than 50GB disk space available (${available_space}GB)"
        read -p "   Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        echo "✅ Sufficient disk space (${available_space}GB)"
    fi
fi

echo ""
echo "🚀 Starting services..."
echo ""

# Start services
docker compose up -d

if [ $? -eq 0 ]; then
    echo ""
    echo "================================================"
    echo "  ✅ Services started successfully!"
    echo "================================================"
    echo ""
    echo "📊 Service URLs (add to /etc/hosts for localhost):"
    echo "   Dashboard:    https://localhost"
    echo "   GitLab:       https://gitlab.localhost"
    echo "   Jenkins:      https://jenkins.localhost"
    echo "   Portainer:    https://portainer.localhost"
    echo "   Harbor:       https://harbor.localhost"
    echo "   Nextcloud:    https://nextcloud.localhost"
    echo "   n8n:          https://n8n.localhost"
    echo "   Homarr:       https://homarr.localhost"
    echo ""
    echo "🔐 Default Credentials:"
    echo "   GitLab:     root / ChangeThisPassword123!"
    echo "   Harbor:     admin / Harbor12345!"
    echo "   Nextcloud:  admin / NextcloudAdmin123!"
    echo "   n8n:        admin / n8nAdmin123!"
    echo "   Others:     Set up on first access"
    echo ""
    echo "⚠️  Change default passwords after first login!"
    echo ""
    echo "📝 Notes:"
    echo "   - GitLab may take 3-5 minutes to fully start"
    echo "   - Harbor may take 1-2 minutes to fully start"
    echo "   - All data is persisted in Docker volumes"
    echo "   - Run 'docker compose logs -f' to view logs"
    echo "   - Run 'docker compose down' to stop services"
    echo ""
else
    echo ""
    echo "❌ Failed to start services. Check errors above."
    echo "   Run 'docker compose logs' for details."
    exit 1
fi
