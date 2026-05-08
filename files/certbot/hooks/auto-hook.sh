#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../config/dns-config.conf"

log_message() {
    log_level="$1"
    log_text="$2"
    log_timestamp=$(date "+%Y-%m-%d %H:%M:%S")

    if [ "$LOG_FILE" != "" ]; then
        mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true
        echo "[$log_timestamp] [$log_level] $log_text" >> "$LOG_FILE"
    fi

    if [ "$log_level" = "ERROR" ]; then
        echo "$log_text" >&2
    fi
}

if [ ! -f "$CONFIG_FILE" ]; then
    echo "dns-config.conf not found: $CONFIG_FILE" >&2
    exit 1
fi

# shellcheck disable=SC1090
source "$CONFIG_FILE"

if [ "$CERTBOT_DOMAIN" = "" ] || [ "$CERTBOT_VALIDATION" = "" ]; then
    log_message "ERROR" "Missing Certbot environment variables for DNS auth hook"
    exit 1
fi

ZONE=$(echo "$CERTBOT_DOMAIN" | awk -F. '{print $(NF-1)"."$NF}')

RRSETS=$(cat <<EOF
{
    "rrsets": [
        {
            "name": "_acme-challenge.${CERTBOT_DOMAIN}.",
            "type": "TXT",
            "changetype": "REPLACE",
            "records": [
                {
                    "content": "\"${CERTBOT_VALIDATION}\"",
                    "disabled": false
                }
            ],
            "ttl": ${TTL:-60}
        }
    ]
}
EOF
)

if ! RESPONSE=$(curl -X PATCH -sS -w "HTTPCODE:%{http_code}" \
    -H "X-API-Key: ${API_KEY}" \
    -H "Content-Type: application/json" \
    -d "$RRSETS" \
    "http://${DNS_SERVER}:${DNS_PORT}/api/v1/servers/localhost/zones/${ZONE}."); then
    log_message "ERROR" "PowerDNS request failed while creating TXT record for $CERTBOT_DOMAIN"
    exit 1
fi

HTTP_CODE=$(echo "$RESPONSE" | grep -o "HTTPCODE:[0-9]*" | cut -d: -f2)
RESPONSE_BODY=$(echo "$RESPONSE" | sed 's/HTTPCODE:[0-9]*$//')

if [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 300 ]; then
    log_message "INFO" "Created DNS TXT record for $CERTBOT_DOMAIN"
else
    log_message "ERROR" "PowerDNS returned HTTP $HTTP_CODE while creating TXT record: $RESPONSE_BODY"
    exit 1
fi

sleep "${DNS_PROPAGATION_WAIT:-60}"