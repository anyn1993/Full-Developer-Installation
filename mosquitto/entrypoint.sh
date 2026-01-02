#!/bin/sh
# Mosquitto Entrypoint Script
# Generates password file from environment variables

set -e

PASSWORD_FILE="/mosquitto/passwd/passwd"

echo "🔐 Configuring Mosquitto authentication..."

# Create password file if credentials are provided
if [ -n "$MOSQUITTO_USERNAME" ] && [ -n "$MOSQUITTO_PASSWORD" ]; then
    # Create password file with the default user
    mosquitto_passwd -c -b "$PASSWORD_FILE" "$MOSQUITTO_USERNAME" "$MOSQUITTO_PASSWORD"
    echo "   ✓ Created user: $MOSQUITTO_USERNAME"
    
    # Set proper permissions
    chmod 600 "$PASSWORD_FILE"
    chown mosquitto:mosquitto "$PASSWORD_FILE"
else
    echo "   ⚠ No MOSQUITTO_USERNAME/MOSQUITTO_PASSWORD set, authentication disabled!"
fi

echo "✅ Mosquitto configuration complete!"
echo ""

# Start Mosquitto
exec /usr/sbin/mosquitto -c /mosquitto/config/mosquitto.conf

