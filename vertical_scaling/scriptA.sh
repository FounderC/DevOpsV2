#!/bin/bash

LOG_FILE="scriptA.log"
IMAGE_NAME="olegkhomenko/http_server"  # або ваш образ
CPU_THRESHOLD_BUSY=50
CPU_THRESHOLD_IDLE=5
CHECK_INTERVAL=30       # перевіряємо завантаження кожні 30с
CONSECUTIVE_MINUTES=2   # 2 хвилини = 4 перевірки по 30с
BUSY_COUNT=0
IDLE_COUNT=0

# Стартуємо srv1 на CPU0
echo "$(date) Starting srv1 on CPU0" | tee -a $LOG_FILE
docker run --name srv1 --cpuset-cpus=0 -d -p 8081:8081 $IMAGE_NAME

SRV2_RUNNING=0
SRV3_RUNNING=0

while true; do
    # Перевіряємо наявність нової версії образу
    pullResult=$(docker pull $IMAGE_NAME | grep "Downloaded newer image")
    if [ -n "$pullResult" ]; then
        echo "$(date) New image found. Updating..." | tee -a $LOG_FILE
        # Оновлюємо запущені контейнери. Робимо це по черзі.
        # Головна умова: хоча б один контейнер має працювати.
        
        # 1. Оновлення srv1 (якщо працює). Спочатку перезапустимо srv1, але нам потрібен мінімум один сервер доступний.
        #   Якщо srv2 або srv3 працюють – можна зупиняти srv1.
        
        if [ $(docker ps -q -f name=srv1) ]; then
            if [ $SRV2_RUNNING -eq 1 ] || [ $SRV3_RUNNING -eq 1 ]; then
                echo "$(date) Updating srv1..." | tee -a $LOG_FILE
                docker kill --signal=SIGINT srv1
                docker wait srv1
                docker run --name srv1 --cpuset-cpus=0 -d -p 8081:8081 $IMAGE_NAME
            fi
        fi
        
        # 2. Оновлення srv2
        if [ $SRV2_RUNNING -eq 1 ]; then
            if [ $(docker ps -q -f name=srv1) ]; then
                echo "$(date) Updating srv2..." | tee -a $LOG_FILE
                docker kill --signal=SIGINT srv2
                docker wait srv2
                docker run --name srv2 --cpuset-cpus=1 -d -p 8082:8081 $IMAGE_NAME
            fi
        fi
        
        # 3. Оновлення srv3
        if [ $SRV3_RUNNING -eq 1 ]; then
            if [ $(docker ps -q -f name=srv1) ] || [ $SRV2_RUNNING -eq 1 ]; then
                echo "$(date) Updating srv3..." | tee -a $LOG_FILE
                docker kill --signal=SIGINT srv3
                docker wait srv3
                docker run --name srv3 --cpuset-cpus=2 -d -p 8083:8081 $IMAGE_NAME
            fi
        fi
        echo "$(date) Update complete." | tee -a $LOG_FILE
    fi

    # Перевіряємо завантаження контейнерів
    # Використаємо команду docker stats
    # Формат: docker stats --no-stream --format "{{.Name}} {{.CPUPerc}}"
    STATS=$(docker stats --no-stream --format "{{.Name}} {{.CPUPerc}}")
    # Parsing
    # Очікуємо рядки на кшталт:
    # srv1 10.23%
    # srv2 80.50%
    # srv3 2.00%
    # Витягнемо проценти:
    
    SRV1_CPU=$(echo "$STATS" | grep srv1 | awk '{print $2}' | tr -d '%')
    SRV2_CPU=$(echo "$STATS" | grep srv2 | awk '{print $2}' | tr -d '%' )
    SRV3_CPU=$(echo "$STATS" | grep srv3 | awk '{print $2}' | tr -d '%')

    # Якщо контейнер відсутній, значення буде порожнє
    [ -z "$SRV1_CPU" ] && SRV1_CPU=0
    [ -z "$SRV2_CPU" ] && SRV2_CPU=0
    [ -z "$SRV3_CPU" ] && SRV3_CPU=0

    echo "$(date) CPU: srv1=$SRV1_CPU%, srv2=$SRV2_CPU%, srv3=$SRV3_CPU%" | tee -a $LOG_FILE

    # Логіка масштабування:
    # 1) Якщо srv1 > 50% CPU 2 хвилини поспіль => запуск srv2
    if [ $(echo "$SRV1_CPU > $CPU_THRESHOLD_BUSY" | bc) -eq 1 ]; then
        BUSY_COUNT=$((BUSY_COUNT+1))
    else
        BUSY_COUNT=0
    fi

    if [ $BUSY_COUNT -ge 4 ] && [ $SRV2_RUNNING -eq 0 ]; then
        echo "$(date) srv1 busy for 2 minutes, starting srv2 on CPU1" | tee -a $LOG_FILE
        docker run --name srv2 --cpuset-cpus=1 -d -p 8082:8081 $IMAGE_NAME
        SRV2_RUNNING=1
        BUSY_COUNT=0
    fi

    # Якщо srv2 > 50% 2 хвилини поспіль => запуск srv3
    if [ $SRV2_RUNNING -eq 1 ]; then
        if [ $(echo "$SRV2_CPU > $CPU_THRESHOLD_BUSY" | bc) -eq 1 ]; then
            BUSY_COUNT=$((BUSY_COUNT+1))
        else
            BUSY_COUNT=0
        fi

        if [ $BUSY_COUNT -ge 4 ] && [ $SRV3_RUNNING -eq 0 ]; then
            echo "$(date) srv2 busy for 2 minutes, starting srv3 on CPU2" | tee -a $LOG_FILE
            docker run --name srv3 --cpuset-cpus=2 -d -p 8083:8081 $IMAGE_NAME
            SRV3_RUNNING=1
            BUSY_COUNT=0
        fi
    fi

    # Логіка згортання:
    # Якщо srv3 запущений і srv3 < 5% 2 хвилини => зупинити srv3
    if [ $SRV3_RUNNING -eq 1 ]; then
        if [ $(echo "$SRV3_CPU < $CPU_THRESHOLD_IDLE" | bc) -eq 1 ]; then
            IDLE_COUNT=$((IDLE_COUNT+1))
        else
            IDLE_COUNT=0
        fi

        if [ $IDLE_COUNT -ge 4 ]; then
            echo "$(date) srv3 idle for 2 minutes, stopping srv3" | tee -a $LOG_FILE
            docker kill --signal=SIGINT srv3
            docker wait srv3
            SRV3_RUNNING=0
            IDLE_COUNT=0
        fi
    fi

    # Якщо srv2 запущений, немає srv3, і srv2 <5% 2 хвилини => зупинити srv2
    if [ $SRV2_RUNNING -eq 1 ] && [ $SRV3_RUNNING -eq 0 ]; then
        if [ $(echo "$SRV2_CPU < $CPU_THRESHOLD_IDLE" | bc) -eq 1 ]; then
            IDLE_COUNT=$((IDLE_COUNT+1))
        else
            IDLE_COUNT=0
        fi

        if [ $IDLE_COUNT -ge 4 ]; then
            echo "$(date) srv2 idle for 2 minutes, stopping srv2" | tee -a $LOG_FILE
            docker kill --signal=SIGINT srv2
            docker wait srv2
            SRV2_RUNNING=0
            IDLE_COUNT=0
        fi
    fi

    sleep $CHECK_INTERVAL
done
