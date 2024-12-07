FROM alpine:latest AS build
RUN apk add --no-cache build-base autoconf automake git
WORKDIR /home/DevOpsV2
RUN git clone --branch branchHTTPserver https://github.com/FounderC/DevOpsV2.git . 
RUN autoreconf --install && \
    ./configure && \
    make

FROM alpine:latest
RUN apk add --no-cache libc6-compat
WORKDIR /app
COPY --from=build /home/DevOpsV2/FuncA /app/FuncA
EXPOSE 8081
CMD ["./FuncA"]

