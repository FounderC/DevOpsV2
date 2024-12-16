#!/bin/bash

LOG_FILE="scriptB.log"
TARGET_URL="http://localhost:8081/compute" # nginx LB endpoint

while true; do
    WAIT_TIME=$((RANDOM%1+2)) # випадковий час від 5 до 10 секунд
    echo "$(date) Sending request to $TARGET_URL" | tee -a $LOG_FILE
    curl -s -o /dev/null -w "%{http_code}\n" $TARGET_URL | tee -a $LOG_FILE
    sleep $WAIT_TIME &
    wait
done