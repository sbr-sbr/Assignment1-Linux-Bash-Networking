#!/bin/bash

LOG_FILE="logs/network-check.log"

log_message() {
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >> "$LOG_FILE"
}

if ! mkdir -p logs 2>/dev/null; then
    echo "Error: unable to create the logs directory." >&2
    exit 1
fi

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "Usage: $0 <hostname-or-ip> [port]" >&2
    log_message "Invalid arguments: expected a host and optional port."
    exit 2
fi

HOST_NAME=$1
PORT=$2

if [ -z "$HOST_NAME" ]; then
    echo "Error: host cannot be empty." >&2
    log_message "Invalid arguments: empty host."
    exit 2
fi

if [ "$#" -eq 2 ]; then
    if ! [[ "$PORT" =~ ^[0-9]+$ ]] || [ "$PORT" -lt 1 ] || [ "$PORT" -gt 65535 ]; then
        echo "Error: port must be a number from 1 to 65535." >&2
        log_message "Invalid port: $PORT"
        exit 2
    fi
fi

log_message "Network check started for host $HOST_NAME."

if ! command -v getent >/dev/null 2>&1; then
    echo "Error: getent is required to resolve hosts." >&2
    log_message "Host resolution failed: getent is unavailable."
    exit 1
fi

resolved_addresses=$(getent ahosts "$HOST_NAME" 2>/dev/null)
if [ -z "$resolved_addresses" ]; then
    echo "Failed to resolve host: $HOST_NAME" >&2
    log_message "Host resolution failed for $HOST_NAME."
    exit 1
fi

ip_address=$(printf '%s\n' "$resolved_addresses" | awk 'NR == 1 { print $1 }')
echo "Resolved address for $HOST_NAME: $ip_address"
log_message "Resolved $HOST_NAME to $ip_address."

if ! command -v ping >/dev/null 2>&1; then
    echo "Error: ping is unavailable." >&2
    log_message "Connectivity check failed: ping is unavailable."
    exit 1
fi

if ping -c 1 -W 2 "$HOST_NAME" >/dev/null 2>&1; then
    echo "Connectivity check: reachable"
    log_message "Connectivity check succeeded for $HOST_NAME."
else
    echo "Connectivity check: unreachable"
    log_message "Connectivity check failed for $HOST_NAME."
    exit 1
fi

if ! command -v ip >/dev/null 2>&1; then
    echo "Error: ip is unavailable." >&2
    log_message "Interface check failed: ip is unavailable."
    exit 1
fi

echo "Network interfaces:"
ip -brief address
log_message "Displayed network interface information."

if [ "$#" -eq 2 ]; then
    if ! command -v nc >/dev/null 2>&1; then
        echo "Error: nc is required for TCP port checks." >&2
        log_message "TCP check failed: nc is unavailable."
        exit 1
    fi

    if nc -z -w 3 "$HOST_NAME" "$PORT" >/dev/null 2>&1; then
        echo "TCP connectivity to port $PORT: open"
        log_message "TCP connectivity succeeded for $HOST_NAME:$PORT."
    else
        echo "TCP connectivity to port $PORT: unavailable"
        log_message "TCP connectivity failed for $HOST_NAME:$PORT."
        exit 1
    fi
fi

log_message "Network check completed for $HOST_NAME."
exit 0