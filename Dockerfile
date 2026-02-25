FROM --platform=$BUILDPLATFORM golang:1.26 AS build

ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

ADD . /go/src/github.com/chrissnell/external-mdns
WORKDIR /go/src/github.com/chrissnell/external-mdns

RUN mkdir -p /release/etc &&\
    echo nobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin > /release/etc/passwd &&\
    CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} GOARM=$(echo ${TARGETVARIANT} | cut -c2) \
    go build \
    -ldflags="-s -w" \
    -o /release/external-mdns .

FROM scratch

LABEL org.opencontainers.image.description="Advertises records for Kubernetes resources over multicast DNS." \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.source="https://github.com/chrissnell/external-mdns" \
      org.opencontainers.image.title="external-mdns" \
      org.opencontainers.image.url="https://github.com/chrissnell/external-mdns"

COPY --from=build /release /
USER nobody
ENTRYPOINT ["/external-mdns"]
