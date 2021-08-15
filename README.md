[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE-MIT)
[![License: Apache 2.0](https://img.shields.io/badge/license-Apache_2.0-blue.svg)](LICENSE-APACHE)

![Trust-DNS](logo.svg)

# Trust-DNS in Docker

This is the trust-dns Docker image

## Build a pull-request

- Compute the SOURCE_SHA256 running `wget "$SOURCE_FILE" -O - | sha256sum` and replace the variable in this command.
- Edit and run

    ```sh
    IMAGE_TAG="botsudo/trust-dns:ns-trial" \
    BUILD_ARGS='--build-arg VERSION="0.20.x-dev" \
        --build-arg SOURCE_FILE="https://github.com/bluejekyll/trust-dns/archive/refs/heads/stop-returning-ns-on-auth-response.tar.gz" \
        --build-arg SOURCE_SHA256="f48ee16fca6b328bae1b2_REPLACE_ME_c17f0152efa986416740c9"' make build-alpine
    ```

### Push the result

```sh
IMAGE_TAG="botsudo/trust-dns:ns-trial" make push
```
