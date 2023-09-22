FROM docker.io/zmkfirmware/zmk-build-arm:stable

RUN apt-get update \
    && apt-get install -y wget \
    && wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq \
    && chmod +x /usr/bin/yq

ARG USER_ID=1000

RUN adduser --disabled-password --gecos '' --uid ${USER_ID} zmk

USER zmk

WORKDIR /app

COPY config/west.yml config/west.yml

RUN west init -l config

RUN west update

RUN west zephyr-export

CMD ["bin/build.sh"]
