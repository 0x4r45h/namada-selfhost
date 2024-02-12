FROM debian:stable-slim
ARG HERMES_TAG
ARG HERMES_ARG="x86_64-unknown-linux-gnu"
RUN apt-get update && apt-get install -y \
    curl \
    nano \
    git \
    jq \
    dnsutils \
    iputils-ping \
    && apt-get clean
WORKDIR /root
RUN curl -Lo /tmp/hermes.tar.gz https://github.com/heliaxdev/hermes/releases/download/${HERMES_TAG}/hermes-${HERMES_TAG}-${HERMES_ARG}.tar.gz
RUN tar -xvzf /tmp/hermes.tar.gz -C /usr/local/bin
RUN hermes completions --shell bash