FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt update && apt install -y \
    default-jre \
    unzip \
    python3 \
    python3-pip \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN adduser --system --no-create-home ggc_user && \
    addgroup --system ggc_group && \
    usermod -a -G ggc_group ggc_user

ENV GGC_INSTALL_DIR=/greengrass/v2
RUN mkdir -p ${GGC_INSTALL_DIR} && \
    chown -R ggc_user:ggc_group /greengrass

WORKDIR /tmp

COPY greengrass-nucleus-latest.zip .
COPY MeuCoreWSLDockerV2-connectionKit.zip .
COPY setup-and-start.sh /usr/local/bin/setup-and-start.sh
RUN chmod +x /usr/local/bin/setup-and-start.sh

ENTRYPOINT ["/usr/local/bin/setup-and-start.sh"]
