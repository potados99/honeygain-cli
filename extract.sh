#!/usr/bin/env bash
# Docker 이미지에서 honeygain 바이너리와 라이브러리를 추출합니다.
# 추출된 파일은 dist/<version>/ 에 저장됩니다.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IMAGE="honeygain/honeygain:latest"
PLATFORM="linux/arm64"

echo "==> Docker 이미지 pull: $IMAGE ($PLATFORM)"
docker pull --platform "$PLATFORM" "$IMAGE"

# 버전 추출
VERSION=$(docker run --rm --platform "$PLATFORM" "$IMAGE" -version 2>&1 | grep 'version' | awk '{print $NF}')
if [ -z "$VERSION" ]; then
    echo "버전을 가져올 수 없습니다." >&2
    exit 1
fi
echo "==> 버전: $VERSION"

DIST_DIR="$SCRIPT_DIR/dist/$VERSION"

if [ -d "$DIST_DIR" ]; then
    echo "==> 이미 존재하는 버전입니다: $DIST_DIR"
    echo "    덮어쓰려면 해당 디렉토리를 삭제하고 다시 실행하세요."
    exit 0
fi

mkdir -p "$DIST_DIR"

# 임시 컨테이너 생성
CONTAINER=$(docker create --platform "$PLATFORM" "$IMAGE")
trap "docker rm $CONTAINER > /dev/null 2>&1" EXIT

echo "==> 바이너리 추출 중..."
docker cp "$CONTAINER:/app/honeygain" "$DIST_DIR/honeygain"
docker cp "$CONTAINER:/usr/lib/libhg.so.2.0.0" "$DIST_DIR/libhg.so.2.0.0"
docker cp "$CONTAINER:/usr/lib/libmsquic.so.2" "$DIST_DIR/libmsquic.so.2"

# latest 파일 업데이트
echo "$VERSION" > "$SCRIPT_DIR/latest"

echo ""
echo "==> 추출 완료:"
ls -lh "$DIST_DIR"
echo ""
echo "latest -> $VERSION"
echo ""
echo "이제 변경사항을 커밋하고 push하면 install.sh로 설치할 수 있습니다."
