# Minimum Rust version: https://github.com/hickory-dns/hickory-dns/blob/main/Cargo.toml "rust-version"

ARG VERSION="0.25.2"
ARG SOURCE_FILE="https://github.com/hickory-dns/hickory-dns/archive/refs/tags/v${VERSION}.tar.gz"
# wget https://github.com/hickory-dns/hickory-dns/archive/refs/tags/v${VERSION}.tar.gz -O - | sha256sum
ARG SOURCE_SHA256="b4f4b3ff1cbefd1023c6e2b96b3db237e051e4b6c3596cafb310da4901212e58"

FROM alpine:3.21 AS build-env

ARG VERSION
ARG SOURCE_FILE
ARG SOURCE_SHA256

# https://docs.rs/crate/hickory-dns/0.25.2/features
ARG DEFAULT_FEATURES="ascii-art,resolver,sqlite"
ARG FEATURES="h3-ring,quic-ring,https-ring,dnssec-ring,recursor,rustls-platform-verifier,webpki-roots,blocklist,$DEFAULT_FEATURES"

WORKDIR /workspace
RUN \
    set -exuo pipefail; \
    wget "${SOURCE_FILE}" -O /tmp/hickory-dns.tar.gz; \
    echo "${SOURCE_SHA256}  /tmp/hickory-dns.tar.gz" > /tmp/hickory-dns.tar.gz.sha256sum; \
    sha256sum -s -c -w /tmp/hickory-dns.tar.gz.sha256sum; \
    tar --strip-components=1 --directory /workspace -xzvf /tmp/hickory-dns.tar.gz; \
    rm /tmp/hickory-dns.tar.gz;

RUN apk add --no-cache --update rust cargo musl-dev openssl-dev pkgconfig
RUN cargo fetch
RUN cargo build -p hickory-dns --bin hickory-dns --release --no-default-features --features $FEATURES
RUN ldd /workspace/target/release/hickory-dns

FROM debian:trixie-slim AS dns-root-data

RUN apt update && apt install dns-root-data -y

FROM alpine:3.21 AS runtime

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
RUN apk add --no-cache --update libgcc bind-tools

COPY --chmod=555 --from=build-env /workspace/target/release/hickory-dns /usr/bin
COPY --chmod=444 --from=dns-root-data /usr/share/dns/root.ds /usr/share/dns/root.ds
COPY --chmod=444 --from=dns-root-data /usr/share/dns/root.hints /usr/share/dns/root.hints
COPY --chmod=444 --from=dns-root-data /usr/share/dns/root.key /usr/share/dns/root.key

# Quickly test the binary is "working" and has no linked libs errors
RUN set -eux; \
    hickory-dns --version; \
    hickory-dns --help; \
    printf '[[zones]]\nzone = "."\nzone_type = "External"\n[zones.stores]\ntype = "forward"\nname_servers = [{ socket_addr = "1.1.1.1:53", protocol = "udp" },{ socket_addr = "1.0.0.1:53", protocol = "tcp" }]\n' > /tmp/named.toml; \
    hickory-dns --validate --config /tmp/named.toml; \
    nohup sh -c "hickory-dns --config /tmp/named.toml &"; \
    dig +short google.fr @127.0.0.1; \
    rm /tmp/named.toml

ENTRYPOINT [ "hickory-dns" ]
