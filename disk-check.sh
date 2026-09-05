#!/bin/bash

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "Usage: $0 <threshold> [path]" >&2
    exit 2
fi

THRESHOLD=$1
USER_PATH=${2:-/}

if ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]] || [ "$THRESHOLD" -lt 1 ] || [ "$THRESHOLD" -gt 100 ]; then
    echo "Invalid threshold value. Use an integer from 1 to 100." >&2
    exit 2
fi

if [ ! -e "$USER_PATH" ]; then
    echo "Invalid path: $USER_PATH" >&2
    exit 2
fi

USAGE=$(df --output=pcent -- "$USER_PATH" 2>/dev/null | tail -n 1 | tr -d ' %')

if ! [[ "$USAGE" =~ ^[0-9]+$ ]]; then
    echo "Unable to determine disk usage for: $USER_PATH" >&2
    exit 2
fi

echo "Disk usage for $USER_PATH: ${USAGE}%"

if [ "$USAGE" -ge "$THRESHOLD" ]; then
    echo "Disk usage has reached or exceeded the threshold."
    exit 1
fi

echo "Disk usage is below the threshold."
exit 0