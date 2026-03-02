#!/usr/bin/env bash
# Install honeygain CLI on arm64 (aarch64) Linux systems.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/potados99/honeygain-cli/main/install.sh | bash

set -euo pipefail

REPO="potados99/honeygain-cli"
BASE_URL="https://raw.githubusercontent.com/$REPO/main"
INSTALL_BIN="/usr/local/bin"
INSTALL_LIB="/usr/lib"

ARCH=$(uname -m)
if [ "$ARCH" != "aarch64" ]; then
    echo "This script only supports arm64 (aarch64). Detected: $ARCH" >&2
    exit 1
fi

echo "==> Fetching latest version..."
VERSION=$(curl -fsSL "$BASE_URL/latest")
if [ -z "$VERSION" ]; then
    echo "Failed to get version info." >&2
    exit 1
fi
echo "    Version: $VERSION"

DIST_URL="$BASE_URL/dist/$VERSION"

TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

echo "==> Downloading..."
curl -fsSL -o "$TMP/honeygain" "$DIST_URL/honeygain"
curl -fsSL -o "$TMP/libhg.so.2.0.0" "$DIST_URL/libhg.so.2.0.0"
curl -fsSL -o "$TMP/libmsquic.so.2" "$DIST_URL/libmsquic.so.2"

echo "==> Installing (sudo required)..."
sudo install -m 755 "$TMP/honeygain" "$INSTALL_BIN/honeygain"
sudo install -m 644 "$TMP/libhg.so.2.0.0" "$INSTALL_LIB/libhg.so.2.0.0"
sudo install -m 644 "$TMP/libmsquic.so.2" "$INSTALL_LIB/libmsquic.so.2"
sudo ldconfig

echo ""
echo "==> Installed honeygain $VERSION"
echo ""
echo "Usage:"
echo "  honeygain -email you@example.com -pass yourpass -device my-rpi -tou-accept"
