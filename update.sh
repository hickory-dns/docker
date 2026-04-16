#!/bin/sh

set -eu

DOCKERFILE="alpine/Dockerfile"
REPO="hickory-dns/hickory-dns"

# Get current version from Dockerfile
CURRENT_VERSION=$(grep -oP '^ARG VERSION="\K[^"]+' "${DOCKERFILE}")

# Fetch the latest release tag (includes pre-releases)
LATEST_TAG=$(gh release list --repo "${REPO}" --limit 1 --json tagName --jq '.[0].tagName')
LATEST_VERSION="${LATEST_TAG#v}"

echo "Current version: ${CURRENT_VERSION}"
echo "Latest version:  ${LATEST_VERSION}"

if [ "${CURRENT_VERSION}" = "${LATEST_VERSION}" ]; then
    echo "Already up to date."
    exit 0
fi

echo "Updating ${CURRENT_VERSION} -> ${LATEST_VERSION}"

# Download the tarball and compute SHA256
SOURCE_URL="https://github.com/${REPO}/archive/refs/tags/v${LATEST_VERSION}.tar.gz"
echo "Downloading ${SOURCE_URL} ..."
NEW_SHA256=$(wget -qO- "${SOURCE_URL}" | sha256sum | cut -d' ' -f1)
echo "New SHA256: ${NEW_SHA256}"

# Get old SHA256 from Dockerfile
OLD_SHA256=$(grep -oP '^ARG SOURCE_SHA256="\K[^"]+' "${DOCKERFILE}")

# Update the Dockerfile
sed -i "s|^ARG VERSION=\"${CURRENT_VERSION}\"|ARG VERSION=\"${LATEST_VERSION}\"|" "${DOCKERFILE}"
sed -i "s|^ARG SOURCE_SHA256=\"${OLD_SHA256}\"|ARG SOURCE_SHA256=\"${NEW_SHA256}\"|" "${DOCKERFILE}"

echo "Dockerfile updated successfully."
echo ""
echo "Changes:"
git diff "${DOCKERFILE}"
