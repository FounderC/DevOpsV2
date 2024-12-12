# Використання офіційного базового образу Ubuntu
FROM ubuntu:latest

# Оновлення системи та встановлення необхідних інструментів для компіляції
RUN apt-get update && apt-get install -y \
    build-essential \
    g++ \
    autoconf \
    automake \
    libtool \
    pkg-config \
    cmake \
    git \
    wget \
    libgtest-dev

# Створення робочої директорії
WORKDIR /app

# Копіювання локальних файлів у контейнер
COPY . /app

# Компіляція та збирання проекту
RUN autoreconf --install && ./configure && make

# Відкриття порту для HTTP сервера
EXPOSE 8081

# Налаштування команд для запуску HTTP сервера
CMD ["./FuncA"]

