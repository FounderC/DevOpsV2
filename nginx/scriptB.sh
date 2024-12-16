#!/bin/bash

SERVER_URL="http://localhost:80" # або IP вашого балансувальника Nginx

while true
do
    # Генеруємо випадкову затримку від 5 до 10 секунд
    DELAY=$((RANDOM%6+5))
    
    # Викликаємо curl у бекграунді
    ( curl -s $SERVER_URL >/dev/null ) &
    
    sleep $DELAY
done
