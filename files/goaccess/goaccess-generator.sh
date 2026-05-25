#!/bin/bash

# GoAccess Statistics Generator - Master Script
# Usage: goaccess-generator.sh DOMAINNAME
# Created by VirtualX

# Check if domain parameter is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 DOMAINNAME"
    echo "Example: $0 www.example.com"
    exit 1
fi

DOMAINNAME="$1"
LOG_DIR="/home/httpd/$DOMAINNAME/logs"
OUTPUT_DIR="/home/httpd/$DOMAINNAME/htdocs/WEBSTATS"
OUTPUT_FILE="$OUTPUT_DIR/index.html"

# GeoIP database (for country statistics)
GEOIP_DB="/usr/share/GeoIP/GeoLite2-Country.mmdb"

# IP addresses and ranges to be excluded
EXCLUDE_IPS="127.0.0.1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,87.128.6.6"

# Check if domain parameter looks valid
if [[ ! "$DOMAINNAME" =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    echo "Error: Invalid domain format: $DOMAINNAME"
    exit 1
fi

# Check if log directory exists
if [ ! -d "$LOG_DIR" ]; then
    echo "Error: Log directory does not exist: $LOG_DIR"
    exit 1
fi

# Check if GeoIP database exists
if [ ! -f "$GEOIP_DB" ]; then
    GEOIP_AVAILABLE=false
else
    GEOIP_AVAILABLE=true
fi

# Check if output directory exists, create if not
if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
fi

# Find all access.log files and sort chronologically
# First the archived files (oldest first), then the current access.log
ARCHIVED_FILES=($(find "$LOG_DIR" -name "access.log-*" -type f | sort))
CURRENT_FILE=$(find "$LOG_DIR" -name "access.log" -not -name "access.log-*" -type f)

# Combine: archived files + current log
LOG_FILES=("${ARCHIVED_FILES[@]}")
if [ -n "$CURRENT_FILE" ]; then
    LOG_FILES+=("$CURRENT_FILE")
fi

# Check if log files were found
if [ ${#LOG_FILES[@]} -eq 0 ]; then
    echo "Warning: No log files found for $DOMAINNAME"
    exit 1
fi

# Temporary file for combined logs
TEMP_LOG=$(mktemp)

# Combine all log files in chronological order
for file in "${LOG_FILES[@]}"; do
    if [[ "$file" == *.gz ]]; then
        # .gz files decompress and append
        zcat "$file" >> "$TEMP_LOG"
    else
        # Normal files append directly
        cat "$file" >> "$TEMP_LOG"
    fi
done

# Assemble GoAccess parameters
GOACCESS_PARAMS=(
    "$TEMP_LOG"
    "-o" "$OUTPUT_FILE"
    "--log-format=COMBINED"
    "--exclude-ip=$EXCLUDE_IPS"
)

# Add GeoIP parameters if available
if [ "$GEOIP_AVAILABLE" = true ]; then
    GOACCESS_PARAMS+=("--geoip-database=$GEOIP_DB")
fi

# Set German locale for date/time formatting
export LC_TIME="de_DE.UTF-8"
export LANG="de_DE.UTF-8"

# Execute GoAccess with assembled parameters
goaccess "${GOACCESS_PARAMS[@]}"

# Check GoAccess exit code
GOACCESS_EXIT_CODE=$?

# Delete temporary file if it exists
if [ -f "$TEMP_LOG" ]; then
    rm -f "$TEMP_LOG"
fi

# Log result
if [ $GOACCESS_EXIT_CODE -eq 0 ]; then
    echo "GoAccess: Statistics generated successfully for $DOMAINNAME"
else
    echo "GoAccess: Error generating statistics for $DOMAINNAME (exit code: $GOACCESS_EXIT_CODE)"
fi

exit $GOACCESS_EXIT_CODE
