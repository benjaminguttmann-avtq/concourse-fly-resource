ARG base_image=alpine:edge

FROM ${base_image} AS resource

LABEL MAINTAINER="Troy Kinsella <troy.kinsella@gmail.com>"

COPY assets/ /opt/resource/

RUN apk add --no-cache \
      bash \
      ca-certificates \
      curl \
      jq \
    && update-ca-certificates \
    && chmod +x /opt/resource/*

FROM resource AS tests

RUN test -x /opt/resource/check \
    && test -x /opt/resource/in \
    && test -x /opt/resource/out

FROM resource
