FROM rust:1.53-alpine as build-env

ARG VERSION="0.20.3"
ARG SOURCE_FILE="https://github.com/bluejekyll/trust-dns/archive/refs/tags/v${VERSION}.tar.gz"
# wget https://github.com/bluejekyll/trust-dns/archive/refs/tags/v${VERSION}.tar.gz -O - | sha256sum
ARG SOURCE_SHA256="1766f59ea28e1c1289fcd370d455ae73416814035bad1de313528391cbf8454a"

WORKDIR /workspace
RUN \
    set -exuo pipefail; \
    wget "${SOURCE_FILE}" -O /tmp/trust-dns.tar.gz; \
    echo "${SOURCE_SHA256}  /tmp/trust-dns.tar.gz" > /tmp/trust-dns.tar.gz.sha256sum; \
    sha256sum -s -c -w /tmp/trust-dns.tar.gz.sha256sum; \
    tar --strip-components=1 --directory /workspace -xzvf /tmp/trust-dns.tar.gz; \
    rm /tmp/trust-dns.tar.gz;

RUN apk add --no-cache --update musl-dev openssl-dev
# https://users.rust-lang.org/t/sigsegv-with-program-linked-against-openssl-in-an-alpine-container/52172
RUN RUSTFLAGS="-C target-feature=-crt-static" cargo build --release

FROM alpine:3.12 as runtime

ARG VERSION="0.20.3"
ARG SOURCE_FILE="https://github.com/bluejekyll/trust-dns/archive/refs/tags/v${VERSION}.tar.gz"
# wget https://github.com/bluejekyll/trust-dns/archive/refs/tags/v${VERSION}.tar.gz -O - | sha256sum
ARG SOURCE_SHA256="1766f59ea28e1c1289fcd370d455ae73416814035bad1de313528391cbf8454a"

ARG BUILD_DATE

# Metadata
LABEL org.label-schema.vendor="trust-dns" \
    org.label-schema.url="https://github.com/bluejekyll/trust-dns#readme" \
    org.label-schema.name="trust-dns" \
    org.label-schema.description="trust-dns DNS server" \
    org.label-schema.version=${VERSION} \
    org.label-schema.vcs-url=${SOURCE_FILE} \
    # This one is not in the spec
    org.label-schema.vcs-sha256=${SOURCE_SHA256} \
    # org.label-schema.vcs-ref=${VCS_REF} \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.docker.schema-version="1.0"

# https://github.com/mischov/meeseeks/issues/98#issuecomment-636615680
RUN apk add --no-cache --update openssl libgcc
COPY --from=build-env /workspace/target/release/named /usr/bin
# Quickly test the binary is "working" and has no linked libs errors
RUN named --version

ENTRYPOINT [ "named" ]
