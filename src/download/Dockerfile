FROM alpine

ARG WORKDIR=/tmp/opentofu
ARG TARGETPLATFORM
ARG TARGETARCH
ARG TARGETOS
ARG APP=tofu

ARG VERSION='1.8.0'

WORKDIR ${WORKDIR}

# hadolint ignore=DL3018
RUN apk add --no-cache \
    curl jq bash

COPY providers.txt providers.txt
COPY main.sh main.sh
COPY example.tf example.tf
RUN bash -x main.sh

# hadolint ignore=DL4006
RUN curl -fsSL -o "${WORKDIR}/${APP}.apk" \
    "https://github.com/opentofu/opentofu/releases/download/v${VERSION}/${APP}_${VERSION}_${TARGETARCH}.apk" \
    && apk add --no-cache --allow-untrusted \
    "${WORKDIR}/${APP}.apk" \
    && rm -rf "${WORKDIR}/${APP}.apk"
