FROM python:3.10-buster AS build

RUN mkdir /install

WORKDIR /install

RUN python3 -m pip install --upgrade pip && \
    pip install \
        -r https://raw.githubusercontent.com/EstrellaXD/Auto_Bangumi/main/requirements.txt \
        --prefix="/install"

FROM python:3.10-alpine

ENV Auto_Bangumi_TAG=2.5.25-fix

ENV TZ=Asia/Shanghai \
    PUID=1000 \
    PGID=1000

RUN apk add --update --no-cache \
        bash \
        su-exec \
        tzdata \
        shadow \
        curl \
    && \
    rm -rf \
        /tmp/* \
        /root/.cache/var/cache/apk/*

COPY --from=build --chmod=777 /install /usr/local

WORKDIR /src

RUN wget \
        https://github.com/EstrellaXD/Auto_Bangumi/archive/refs/tags/${Auto_Bangumi_TAG}.tar.gz \
        -O /tmp/Auto_Bangumi.tar.gz \
    && \
    tar \
        -zxvf /tmp/Auto_Bangumi.tar.gz \
        -C /tmp \
        --strip-components 1 \
    && \
    mv /tmp/src/* /src \
    && \
    wget \
        https://raw.githubusercontent.com/DDS-Derek/Auto_Bangumi/main/src/run.sh \
        -O /src/run.sh \
    && \
    wget \
        https://raw.githubusercontent.com/DDS-Derek/Auto_Bangumi/main/src/setID.sh \
        -O /src/setID.sh \
    && \
    addgroup \
        -S auto_bangumi \
    && \
    adduser \
        -S auto_bangumi \
        -G auto_bangumi \
        -h /src \
    && \
    usermod -s /bin/bash auto_bangumi \
    && \
    mkdir -p /config \
    && \
    chmod a+x \
        run.sh \
        getWebUI.sh \
        setID.sh \
    && \
    rm -rf \
        /tmp/* \
        /root/.cache/var/cache/apk/* \
    && \
    echo "version = '"${Auto_Bangumi_TAG}"'" > __version__.py

EXPOSE 7892

VOLUME [ "/config" ]

CMD ["sh", "run.sh"]