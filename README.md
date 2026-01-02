# Developer Tools Stack

Complete Docker Compose setup with GitLab, Jenkins, Portainer, Harbor, Nextcloud, n8n, Homarr, and Mosquitto. Automatic HTTPS via Caddy.

## Quick Start

```bash
# 1. Configure environment
cp env.example .env
nano .env  # Edit BASE_DOMAIN, SSL_EMAIL, passwords

# 2. Add hosts entries (for localhost development)
echo "127.0.0.1 gitlab.localhost jenkins.localhost portainer.localhost harbor.localhost nextcloud.localhost n8n.localhost homarr.localhost" | sudo tee -a /etc/hosts

# 3. Start all services
docker compose up -d

# 4. Open dashboard
xdg-open https://localhost  # or open in browser
```

> **Note**: Harbor certificates are automatically generated on first startup.

## Services

| Service | URL | Default Credentials |
|---------|-----|---------------------|
| GitLab | `https://gitlab.localhost` | `root` / `ChangeThisPassword123!` |
| Jenkins | `https://jenkins.localhost` | Setup on first access |
| Portainer | `https://portainer.localhost` | Setup on first access |
| Harbor | `https://harbor.localhost` | `admin` / `Harbor12345!` |
| Nextcloud | `https://nextcloud.localhost` | `admin` / `NextcloudAdmin123!` |
| n8n | `https://n8n.localhost` | `admin` / `n8nAdmin123!` |
| Homarr | `https://homarr.localhost` | No auth (configure in UI) |
| Mosquitto | Port 1883 (MQTT), 9001 (WS) | Anonymous access |

## Essential Commands

```bash
docker compose up -d          # Start all services
docker compose down           # Stop all services
docker compose logs -f        # View live logs
docker compose logs -f gitlab # View specific service logs
docker compose ps             # Check status
docker compose restart gitlab # Restart specific service
./backup.sh                   # Backup all data
./restore.sh                  # Restore from backup
```

## GitLab Usage

### SSH Access
```bash
# Add your SSH key in GitLab UI, then:
git clone ssh://git@localhost:2222/your-group/your-project.git
```

### HTTPS Access
```bash
git clone https://gitlab.localhost/your-group/your-project.git
```

### CI/CD
Create `.gitlab-ci.yml` in your repository. GitLab automatically detects and runs pipelines.

## Harbor Container Registry

Harbor is an enterprise-grade container registry with vulnerability scanning.

### Login to Harbor
```bash
docker login harbor.localhost
# Username: admin
# Password: Harbor12345!
```

### Push an Image
```bash
# Tag your image for Harbor
docker tag myimage:latest harbor.localhost/library/myimage:latest

# Push to Harbor
docker push harbor.localhost/library/myimage:latest
```

### Pull an Image
```bash
docker pull harbor.localhost/library/myimage:latest
```

### Features
- **Vulnerability Scanning**: Trivy scanner automatically scans images for CVEs
- **Image Replication**: Replicate images between registries
- **Access Control**: Fine-grained RBAC for projects and images
- **Audit Logs**: Track all registry activities

## Production Deployment

1. Update `.env` with your real domain:
   ```
   BASE_DOMAIN=yourdomain.com
   SSL_EMAIL=admin@yourdomain.com
   ```

2. Point DNS records to your server:
   - `gitlab.yourdomain.com`
   - `jenkins.yourdomain.com`
   - `harbor.yourdomain.com`
   - etc.

3. Caddy automatically obtains Let's Encrypt certificates.

## Troubleshooting

### GitLab takes forever to start
GitLab needs 3-5 minutes on first startup. Check progress:
```bash
docker compose logs -f gitlab
```

### Portainer "API version too old" error
```bash
sudo systemctl edit docker.service
# Add:
# [Service]
# Environment=DOCKER_MIN_API_VERSION=1.24

sudo systemctl restart docker
docker compose restart portainer
```

### SSL certificate issues (localhost)
Accept the self-signed certificate warning in your browser, or install Caddy's root CA.

## Requirements

- Docker Engine 20.10+
- Docker Compose 2.0+
- 8GB RAM minimum (16GB recommended)
- 50GB disk space

## License

MIT - Use freely for any purpose.
