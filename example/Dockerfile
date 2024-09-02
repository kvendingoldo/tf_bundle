FROM golang:1.23.0-bookworm as builder
RUN apt-get update \
    && apt-get install git
WORKDIR /app
RUN git clone https://github.com/kvendingoldo/tf_bundle.git
COPY files providers.txt

FROM ghcr.io/opentofu/opentofu:1.8.1
WORKDIR /demo

#COPY --from=builder
COPY files /demo/main.tf
