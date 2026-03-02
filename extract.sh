#!/usr/bin/env bash
# Extract honeygain binary and shared libraries from the official Docker image.
# Only arm64 (aarch64) binaries are extracted.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IMAGE="honeygain/honeygain:latest"
PLATFORM="linux/arm64"

echo "==> Pulling $IMAGE ($PLATFORM)"
docker pull --platform "$PLATFORM" "$IMAGE"

VERSION=$(docker run --rm --platform "$PLATFORM" "$IMAGE" -version 2>&1 | grep 'version' | awk '{print $NF}')
if [ -z "$VERSION" ]; then
    echo "Failed to get version." >&2
    exit 1
fi
echo "==> Version: $VERSION"

DIST_DIR="$SCRIPT_DIR/dist/$VERSION"

if [ -d "$DIST_DIR" ]; then
    echo "==> Already extracted: $DIST_DIR"
    echo "    Remove the directory and re-run to overwrite."
    exit 0
fi

mkdir -p "$DIST_DIR"

CONTAINER=$(docker create --platform "$PLATFORM" "$IMAGE")
trap "docker rm $CONTAINER > /dev/null 2>&1" EXIT

echo "==> Extracting binaries..."
docker cp "$CONTAINER:/app/honeygain" "$DIST_DIR/honeygain"
docker cp "$CONTAINER:/usr/lib/libhg.so.2.0.0" "$DIST_DIR/libhg.so.2.0.0"
docker cp "$CONTAINER:/usr/lib/libmsquic.so.2" "$DIST_DIR/libmsquic.so.2"

echo "$VERSION" > "$SCRIPT_DIR/latest"

echo ""
echo "==> Done:"
ls -lh "$DIST_DIR"
echo ""
echo "latest -> $VERSION"
