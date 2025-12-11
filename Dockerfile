ARG GO_VERSION=1.25.1

FROM golang:${GO_VERSION}-alpine AS builder

ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT
ARG PS3NETSRV_GO_REPO=https://github.com/xakep666/ps3netsrv-go.git
ARG PS3NETSRV_GO_REF=main

WORKDIR /src

RUN apk add --no-cache git ca-certificates && \
    update-ca-certificates

RUN git clone --depth 1 --branch "${PS3NETSRV_GO_REF}" "${PS3NETSRV_GO_REPO}" . && \
    go mod download

ENV CGO_ENABLED=0
RUN GOOS="${TARGETOS:-linux}" \
    GOARCH="${TARGETARCH}" \
    GOARM="${TARGETVARIANT#v}" \
    go build -trimpath -ldflags="-s -w -X main.Version=${PS3NETSRV_GO_REF}" \
    -o /out/ps3netsrv-go ./cmd/ps3netsrv-go

FROM alpine:3.21

WORKDIR /srv/ps3data

RUN apk add --no-cache ca-certificates tzdata && \
    addgroup -g 1000 ps3netsrv && \
    adduser -D -H -u 1000 -G ps3netsrv ps3netsrv && \
    chown ps3netsrv:ps3netsrv /srv/ps3data

COPY --from=builder /out/ps3netsrv-go /usr/local/bin/ps3netsrv-go

ENV PS3NETSRV_ROOT=/srv/ps3data \
    PS3NETSRV_LISTEN_ADDR=0.0.0.0:38008 \
    PS3NETSRV_STRICT_ROOT=true \
    PS3NETSRV_ALLOW_WRITE=true

VOLUME ["/srv/ps3data"]

EXPOSE 38008

USER ps3netsrv:ps3netsrv

ENTRYPOINT ["ps3netsrv-go"]
CMD ["server"]
