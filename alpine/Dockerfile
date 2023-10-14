# Minimum Rust version: https://github.com/hickory-dns/hickory-dns/blob/main/Cargo.toml "rust-version"

ARG VERSION="0.24.0"
ARG SOURCE_FILE="https://github.com/hickory-dns/hickory-dns/archive/refs/tags/v${VERSION}.tar.gz"
# wget https://github.com/hickory-dns/hickory-dns/archive/refs/tags/v${VERSION}.tar.gz -O - | sha256sum
ARG SOURCE_SHA256="e5158a8e412876768fc3d171ef4b2c3e0d4e99c1a1d082018b93bcda9fb31334"

FROM rust:alpine3.18 as build-env

ARG VERSION
ARG SOURCE_FILE
ARG SOURCE_SHA256

ARG FEATURES="dnssec-openssl,dns-over-https,dns-over-https-rustls,dnssec-ring,dnssec,resolver,sqlite,backtrace"

WORKDIR /workspace
RUN \
    set -exuo pipefail; \
    wget "${SOURCE_FILE}" -O /tmp/hickory-dns.tar.gz; \
    echo "${SOURCE_SHA256}  /tmp/hickory-dns.tar.gz" > /tmp/hickory-dns.tar.gz.sha256sum; \
    sha256sum -s -c -w /tmp/hickory-dns.tar.gz.sha256sum; \
    tar --strip-components=1 --directory /workspace -xzvf /tmp/hickory-dns.tar.gz; \
    rm /tmp/hickory-dns.tar.gz;

RUN apk add --no-cache --update rust musl-dev openssl-dev pkgconfig
# https://users.rust-lang.org/t/sigsegv-with-program-linked-against-openssl-in-an-alpine-container/52172
RUN RUSTFLAGS="-C target-feature=-crt-static" cargo build --release --no-default-features --features $FEATURES

FROM alpine:3.18 as runtime

ARG VERSION
ARG SOURCE_FILE
ARG SOURCE_SHA256
ARG BUILD_DATE

# Metadata
LABEL org.label-schema.vendor="hickory-dns" \
    org.label-schema.url="https://github.com/hickory-dns/hickory-dns#readme" \
    org.label-schema.name="hickory-dns" \
    org.label-schema.description="hickory-dns DNS server" \
    org.label-schema.version=${VERSION} \
    org.label-schema.vcs-url=${SOURCE_FILE} \
    # This one is not in the spec
    org.label-schema.vcs-sha256=${SOURCE_SHA256} \
    # org.label-schema.vcs-ref=${VCS_REF} \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.docker.schema-version="1.0" \
    \
    com.docker.extension.publisher-url="https://github.com/hickory-dns" \
    \
    org.opencontainers.image.title="Docker hickory-dns DNS server" \
    org.opencontainers.image.description="hickory-dns DNS server" \
    org.opencontainers.image.authors="benjaminfry@me.com" \
    org.opencontainers.image.url="https://github.com/hickory-dns/hickory-dns#readme" \
    org.opencontainers.image.documentation="https://github.com/hickory-dns/hickory-dns#readme" \
    org.opencontainers.image.source="https://github.com/hickory-dns/hickory-dns" \
    org.opencontainers.image.vendor="hickory-dns" \
    org.opencontainers.image.licenses="MIT or Apache-2.0" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.version=${VERSION} \
    # org.opencontainers.image.revision=${VCS_REF} \
    org.opencontainers.image.ref.name="${VERSION}"

# https://github.com/mischov/meeseeks/issues/98#issuecomment-636615680
RUN apk add --no-cache --update openssl libgcc
COPY --from=build-env /workspace/target/release/hickory-dns /usr/bin
# Quickly test the binary is "working" and has no linked libs errors
RUN hickory-dns --version

ENTRYPOINT [ "hickory-dns" ]
