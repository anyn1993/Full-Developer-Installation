#!/bin/sh
# Caddy Entrypoint Script
# - Generates Harbor certificates if needed
# - Processes HTML template with environment variables

set -e

echo "🚀 Starting Caddy initialization..."

# ============================================
# Harbor Certificate Generation
# ============================================
HARBOR_CONFIG="/harbor-config"
CERT_DIR="${HARBOR_CONFIG}/registry"
CORE_DIR="${HARBOR_CONFIG}/core"

if [ -d "$HARBOR_CONFIG" ]; then
    mkdir -p "$CERT_DIR" "$CORE_DIR/certificates"
    
    # Generate certificates if they don't exist
    if [ ! -f "${CERT_DIR}/root.crt" ]; then
        echo "🔐 Generating Harbor certificates..."
        
        # Generate private key
        openssl genrsa -out "${CORE_DIR}/private_key.pem" 4096 2>/dev/null
        
        # Generate certificate
        openssl req -new -x509 -key "${CORE_DIR}/private_key.pem" \
            -out "${CERT_DIR}/root.crt" \
            -days 3650 \
            -subj "/C=US/ST=State/L=City/O=Harbor/CN=harbor-token-issuer" 2>/dev/null
        
        # Copy to core certificates
        cp "${CERT_DIR}/root.crt" "${CORE_DIR}/certificates/"
        
        echo "   ✓ Harbor certificates generated"
    else
        echo "   ✓ Harbor certificates already exist"
    fi
    
    # Generate secret key if it doesn't exist
    if [ ! -f "${CORE_DIR}/secretkey" ]; then
        openssl rand -hex 16 > "${CORE_DIR}/secretkey"
        echo "   ✓ Harbor secret key generated"
    fi
fi

# ============================================
# Dashboard Template Processing
# ============================================
TEMPLATE_DIR="/srv/dashboard-template"
OUTPUT_DIR="/srv/dashboard"

if [ -f "${TEMPLATE_DIR}/index.html.template" ]; then
    echo "📝 Processing dashboard template..."
    mkdir -p "$OUTPUT_DIR"
    
    # Use envsubst to replace environment variables in template
    envsubst '${BASE_DOMAIN} ${GITLAB_SUBDOMAIN} ${PORTAINER_SUBDOMAIN} ${HARBOR_SUBDOMAIN} ${NEXTCLOUD_SUBDOMAIN} ${N8N_SUBDOMAIN} ${JENKINS_SUBDOMAIN} ${HOMARR_SUBDOMAIN} ${MOSQUITTO_SUBDOMAIN}' \
        < "${TEMPLATE_DIR}/index.html.template" \
        > "${OUTPUT_DIR}/index.html"
    
    echo "   ✓ Dashboard generated with domain: ${BASE_DOMAIN}"
fi

echo "✅ Initialization complete!"
echo ""

# Execute the main command (Caddy)
exec "$@"

