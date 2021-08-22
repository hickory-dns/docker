[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE-MIT)
[![License: Apache 2.0](https://img.shields.io/badge/license-Apache_2.0-blue.svg)](LICENSE-APACHE)

![Trust-DNS](logo.svg)

# Trust-DNS in Docker

This is the trust-dns Docker image

## Example use in docker-compose

```yaml
version: "2"

services:
    dns-server:
        image: botsudo/trust-dns:ns-trial
        volumes:
          - ./config/dns/named.toml:/etc/named.toml:ro
          - ./config/dns/ipv6_block.zone:/var/named/ipv6_block.zone:ro
        ports:
            - "53:53/tcp"
            - "53:53/udp"
```

## Build a pull-request

- Edit and run

    ```sh
    IMAGE_TAG="botsudo/trust-dns:ns-trial" \
    VERSION="0.20.x-dev" \
    SOURCE_FILE="https://github.com/bluejekyll/trust-dns/archive/refs/heads/stop-returning-ns-on-auth-response.tar.gz" \
    SOURCE_SHA256="$(curl -Ls "${SOURCE_FILE}" -o - | sha256sum | cut -d ' ' -f 1)" \
    make build-alpine
    ```

To use wget, replace `curl -Ls "${SOURCE_FILE}" -o -` by `wget "${SOURCE_FILE}" -O -`

### Push the result

```sh
IMAGE_TAG="botsudo/trust-dns:ns-trial" make push
```
