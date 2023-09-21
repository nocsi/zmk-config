FROM docker.io/zmkfirmware/zmk-build-arm:stable

WORKDIR /app

COPY config/west.yml config/west.yml

RUN west init -l config

RUN west update

RUN west zephyr-export

RUN apt-get update \
    && apt-get install -y wget \
    && wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq \
    && chmod +x /usr/bin/yq

COPY build.yaml ./

COPY bin/build.sh ./

CMD ["./build.sh"]
