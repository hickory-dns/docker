[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE-MIT)
[![License: Apache 2.0](https://img.shields.io/badge/license-Apache_2.0-blue.svg)](LICENSE-APACHE)

![hickory-DNS](logo.png)

# hickory-DNS in Docker

This is the [hickory-dns](https://github.com/hickory-dns/hickory-dns#readme) Docker image

## Enabled [features](https://github.com/hickory-dns/hickory-dns/#using-as-a-dependency-and-custom-features) in the image

- `h3-ring`
- `quic-ring`
- `https-ring`
- `dnssec-ring`
- `ascii-art`
- `resolver`
- `recursor`
- `sqlite`
- `rustls-platform-verifier`
- `webpki-roots`

## Additional files

The container has some more files copied from the Debian (`trixie`) package `dns-root-data`.

See: https://www.iana.org/domains/root/files

- `/usr/share/dns/root.ds` The DNS `DS` record for DNSSEC validation of the root `.` (https://data.iana.org/root-anchors/root-anchors.xml).
- `/usr/share/dns/root.hints` The hints to the DNS root servers  (https://www.internic.net/domain/named.root).
- `/usr/share/dns/root.key` The DNS `DNSKEY` record for DNSSEC validation of the root `.` (https://data.iana.org/root-anchors/root-anchors.xml).

## Example use in docker-compose

```yaml
version: "2"

services:
    dns-server:
        image: docker.io/hickorydns/hickory-dns:latest
        volumes:
          - ./config/dns/named.toml:/etc/named.toml:ro
          - ./config/dns/ipv6_block.zone:/var/named/ipv6_block.zone:ro
        ports:
            - "53:53/tcp"
            - "53:53/udp"
```

### Contributing

#### Build a pull-request or your work

You can add the argument `FEATURES=` to define the list of enabled features

- Edit and run

    ```sh
    IMAGE_TAG="yourUsername/hickory-dns:ns-trial" \
    VERSION="0.20.x-dev" \
    SOURCE_FILE="https://github.com/hickory-dns/hickory-dns/archive/refs/heads/stop-returning-ns-on-auth-response.tar.gz" \
    SOURCE_SHA256="$(curl -Ls "${SOURCE_FILE}" -o - | sha256sum | cut -d ' ' -f 1)" \
    make build-alpine
    ```

To use wget, replace `curl -Ls "${SOURCE_FILE}" -o -` by `wget "${SOURCE_FILE}" -O -`

#### Push the result to your repository

```sh
IMAGE_TAG="yourUsername/hickory-dns:ns-trial" make push
```
