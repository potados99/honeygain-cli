#!/usr/bin/env bash
# honeygain CLI를 시스템에 설치합니다.
#
# 사용법:
#   curl -fsSL https://raw.githubusercontent.com/potados99/honeygain-cli/main/install.sh | bash

set -euo pipefail

REPO="potados99/honeygain-cli"
BASE_URL="https://raw.githubusercontent.com/$REPO/main"
INSTALL_BIN="/usr/local/bin"
INSTALL_LIB="/usr/lib"

# 아키텍처 확인
ARCH=$(uname -m)
if [ "$ARCH" != "aarch64" ]; then
    echo "이 설치 스크립트는 arm64(aarch64) 전용입니다. 현재: $ARCH" >&2
    exit 1
fi

# 최신 버전 확인
echo "==> 최신 버전 확인 중..."
VERSION=$(curl -fsSL "$BASE_URL/latest")
if [ -z "$VERSION" ]; then
    echo "버전 정보를 가져올 수 없습니다." >&2
    exit 1
fi
echo "    버전: $VERSION"

DIST_URL="$BASE_URL/dist/$VERSION"

# 임시 디렉토리
TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

echo "==> 다운로드 중..."
curl -fsSL -o "$TMP/honeygain" "$DIST_URL/honeygain"
curl -fsSL -o "$TMP/libhg.so.2.0.0" "$DIST_URL/libhg.so.2.0.0"
curl -fsSL -o "$TMP/libmsquic.so.2" "$DIST_URL/libmsquic.so.2"

echo "==> 설치 중... (sudo 필요)"
sudo install -m 755 "$TMP/honeygain" "$INSTALL_BIN/honeygain"
sudo install -m 644 "$TMP/libhg.so.2.0.0" "$INSTALL_LIB/libhg.so.2.0.0"
sudo install -m 644 "$TMP/libmsquic.so.2" "$INSTALL_LIB/libmsquic.so.2"
sudo ldconfig

echo ""
echo "==> 설치 완료! (honeygain $VERSION)"
echo ""
echo "실행 예시:"
echo "  honeygain -email you@example.com -pass yourpass -device my-rpi -tou-accept"
