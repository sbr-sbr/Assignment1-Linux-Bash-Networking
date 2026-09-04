#!/bin/bash

THRESHOLD=$1
USER_PATH=$2
USAGE=$(df --output=pcent "$USER_PATH" | tail -n 1 | tr -d ' %')

if (( THRESHOLD >=1 && THRESHOLD <=100 )); then
    if(( USAGE >= THRESHOLD )); then
        echo "Disk usage has reached or exceeded the threshold."
        exit 1
    else
        echo "Disk usage is below the threshold."
        exit 0
    fi
else 
    echo "Invalid threshold value."
    exit 2
fi