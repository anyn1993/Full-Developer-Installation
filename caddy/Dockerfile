FROM caddy:2-alpine

# Install OpenSSL for certificate generation and gettext for envsubst
RUN apk add --no-cache openssl gettext

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Copy dashboard template
COPY dashboard/index.html.template /srv/dashboard-template/index.html.template

ENTRYPOINT ["/entrypoint.sh"]
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]

