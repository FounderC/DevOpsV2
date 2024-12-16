#!/usr/bin/env bash

# Ім'я образу на DockerHub
IMAGE_NAME="olegkhomenko/http_server"
# Поріг завантаження для "busy" (наприклад 50%)
BUSY_THRESHOLD=50
# Поріг завантаження для "idle" (наприклад 10%)
IDLE_THRESHOLD=10
# Інтервал перевірки (секунд)
INTERVAL=30
# Кількість послідовних перевірок (2 хвилини / 30 секунд = 4 перевірки)
CHECK_COUNT=4

# Статуси контейнерів
RUNNING_SRV1=true
RUNNING_SRV2=false
RUNNING_SRV3=false

# Лічильники послідовних станів
SRV1_BUSY_COUNT=0
SRV2_BUSY_COUNT=0
SRV3_BUSY_COUNT=0

SRV2_IDLE_COUNT=0
SRV3_IDLE_COUNT=0

# Запустити srv1 на CPU core #0
docker run -d --cpuset-cpus=0 --name srv1 $IMAGE_NAME
RUNNING_SRV1=true

# Функція перевірки наявності новішого образу
check_new_image() {
    pullResult=$(docker pull $IMAGE_NAME | grep "Downloaded newer image")
    if [ -n "$pullResult" ]; then
        echo "Newer image found: $pullResult"
        # Оновлення контейнерів по черзі
        # Спочатку оновимо srv1, переконавшись, що srv2 або srv3 є (або srv1 сам)
        
        # Якщо працює лише srv1, оновлюємо його напряму (ризикованіше, але спростимо)
        if $RUNNING_SRV1; then
            echo "Updating srv1..."
            docker stop srv1
            docker run -d --cpuset-cpus=0 --name srv1 $IMAGE_NAME
        fi

        # Якщо є srv2
        if $RUNNING_SRV2; then
            echo "Updating srv2..."
            # Залишимо srv1 працюючим, зупинимо srv2
            docker stop srv2
            docker run -d --cpuset-cpus=1 --name srv2 $IMAGE_NAME
        fi

        # Якщо є srv3
        if $RUNNING_SRV3; then
            echo "Updating srv3..."
            # Залишимо srv1 чи srv2 працюючим, оновимо srv3
            docker stop srv3
            docker run -d --cpuset-cpus=2 --name srv3 $IMAGE_NAME
        fi
    else
        echo "Image is up to date"
    fi
}

# Функція отримання CPU відсотка для контейнера
get_cpu_usage() {
    local cname=$1
    # Формат: "XX.XX%" - відрізаємо '%' і робимо floor
    cpu_str=$(docker stats $cname --no-stream --format "{{.CPUPerc}}" 2>/dev/null)
    if [ -z "$cpu_str" ]; then
        # Якщо контейнер не працює
        echo 0
    else
        # видаляємо '%' і округлюємо вниз
        cpu_val=$(echo $cpu_str | tr -d '%')
        # Можемо взяти ціле значення:
        cpu_int=${cpu_val%.*}
        echo $cpu_int
    fi
}

while true
do
    # Перевірити новішу версію образу
    check_new_image

    # Отримати завантаження для кожного працюючого контейнера
    if $RUNNING_SRV1; then
        srv1_cpu=$(get_cpu_usage srv1)
    else
        srv1_cpu=0
    fi

    if $RUNNING_SRV2; then
        srv2_cpu=$(get_cpu_usage srv2)
    else
        srv2_cpu=0
    fi

    if $RUNNING_SRV3; then
        srv3_cpu=$(get_cpu_usage srv3)
    else
        srv3_cpu=0
    fi

    echo "CPU: srv1=$srv1_cpu%, srv2=$srv2_cpu%, srv3=$srv3_cpu%"

    # Логіка для запуску srv2 якщо srv1 busy
    if $RUNNING_SRV1; then
        if [ $srv1_cpu -gt $BUSY_THRESHOLD ]; then
            SRV1_BUSY_COUNT=$((SRV1_BUSY_COUNT+1))
        else
            SRV1_BUSY_COUNT=0
        fi

        # Якщо srv1 завантажений 2 хвилини поспіль (4 рази по 30с)
        if [ $SRV1_BUSY_COUNT -ge $CHECK_COUNT ] && ! $RUNNING_SRV2; then
            echo "srv1 busy for 2 minutes, starting srv2..."
            docker run -d --cpuset-cpus=1 --name srv2 $IMAGE_NAME
            RUNNING_SRV2=true
            SRV1_BUSY_COUNT=0
        fi
    fi

    # Логіка для запуску srv3 якщо srv2 busy
    if $RUNNING_SRV2; then
        if [ $srv2_cpu -gt $BUSY_THRESHOLD ]; then
            SRV2_BUSY_COUNT=$((SRV2_BUSY_COUNT+1))
            SRV2_IDLE_COUNT=0  # якщо busy, то скидаємо idle
        else
            # Якщо не busy, можливо idle
            if [ $srv2_cpu -lt $IDLE_THRESHOLD ]; then
                SRV2_IDLE_COUNT=$((SRV2_IDLE_COUNT+1))
            else
                SRV2_IDLE_COUNT=0
            fi
            SRV2_BUSY_COUNT=0
        fi

        # Якщо srv2 busy 2 хвилини поспіль і srv3 не запущений
        if [ $SRV2_BUSY_COUNT -ge $CHECK_COUNT ] && ! $RUNNING_SRV3; then
            echo "srv2 busy for 2 minutes, starting srv3..."
            docker run -d --cpuset-cpus=2 --name srv3 $IMAGE_NAME
            RUNNING_SRV3=true
            SRV2_BUSY_COUNT=0
        fi

        # Якщо srv2 idle 2 хвилини поспіль (і це можливо означає, що можна його зупинити)
        # Але умова завдання: якщо srv3 idle - stop srv3, те саме для srv2
        if [ $SRV2_IDLE_COUNT -ge $CHECK_COUNT ] && $RUNNING_SRV2; then
            echo "srv2 idle for 2 minutes, stopping srv2..."
            docker stop srv2
            RUNNING_SRV2=false
            SRV2_IDLE_COUNT=0
        fi
    fi

    # Логіка для зупинки srv3 якщо idle
    if $RUNNING_SRV3; then
        if [ $srv3_cpu -lt $IDLE_THRESHOLD ]; then
            SRV3_IDLE_COUNT=$((SRV3_IDLE_COUNT+1))
            SRV3_BUSY_COUNT=0
        else
            # Якщо не idle, можливо busy чи нормальний стан
            if [ $srv3_cpu -gt $BUSY_THRESHOLD ]; then
                SRV3_BUSY_COUNT=$((SRV3_BUSY_COUNT+1))
            else
                SRV3_BUSY_COUNT=0
            fi
            SRV3_IDLE_COUNT=0
        fi

        # Якщо srv3 idle 2 хвилини поспіль - stop srv3
        if [ $SRV3_IDLE_COUNT -ge $CHECK_COUNT ]; then
            echo "srv3 idle for 2 minutes, stopping srv3..."
            docker stop srv3
            RUNNING_SRV3=false
            SRV3_IDLE_COUNT=0
        fi
    fi

    sleep $INTERVAL
done
