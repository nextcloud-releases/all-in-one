#!/bin/bash
# SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
# SPDX-License-Identifier: AGPL-3.0-or-later

# Tests build-image.sh against a fake all-in-one checkout, with docker replaced by a stub that prints its arguments.

set -eu

SCRIPT="$(cd "$(dirname "$0")/.." && pwd)/build-image.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$TMP/bin"
cat > "$TMP/bin/docker" << 'STUB'
#!/bin/bash
echo "$@"
STUB
chmod +x "$TMP/bin/docker"
export PATH="$TMP/bin:$PATH"

SOURCE="$TMP/all-in-one"
for DIR in apache mastercontainer nextcloud talk-recording; do
    mkdir -p "$SOURCE/Containers/$DIR"
    touch "$SOURCE/Containers/$DIR/Dockerfile"
done
mkdir -p "$SOURCE/Containers/no-dockerfile"

FAILURES=0
check() {
    if [ "$2" = "$3" ]; then
        echo "ok: $1"
    else
        echo "FAIL: $1"
        echo "  expected: $2"
        echo "  actual:   $3"
        FAILURES=$((FAILURES + 1))
    fi
}

check "list maps mastercontainer to all-in-one and skips dirs without a Dockerfile" \
    "$(printf 'aio-apache\nall-in-one\naio-nextcloud\naio-talk-recording')" \
    "$("$SCRIPT" --list "$SOURCE")"

check "all-in-one is built with the repo root as context" \
    "buildx build --file $SOURCE/Containers/mastercontainer/Dockerfile --tag ghcr.io/nextcloud-releases/all-in-one:develop $SOURCE" \
    "$("$SCRIPT" "$SOURCE" all-in-one develop)"

check "aio-nextcloud is built with the repo root as context" \
    "buildx build --file $SOURCE/Containers/nextcloud/Dockerfile --tag ghcr.io/nextcloud-releases/aio-nextcloud:develop $SOURCE" \
    "$("$SCRIPT" "$SOURCE" aio-nextcloud develop)"

check "other images are built with their own dir as context, extra args are passed on" \
    "buildx build --file $SOURCE/Containers/talk-recording/Dockerfile --tag ghcr.io/nextcloud-releases/aio-talk-recording:develop-arm64 --platform linux/arm64 $SOURCE/Containers/talk-recording" \
    "$("$SCRIPT" "$SOURCE" aio-talk-recording develop-arm64 --platform linux/arm64)"

# Every listed name must be buildable, so the image list and the build mapping stay in sync
while read -r NAME; do
    check "listed image $NAME can be built" "0" "$("$SCRIPT" "$SOURCE" "$NAME" develop > /dev/null 2>&1; echo $?)"
done < <("$SCRIPT" --list "$SOURCE")

check "unknown image names fail" "1" "$("$SCRIPT" "$SOURCE" unknown develop > /dev/null 2>&1 || echo $?)"
check "missing Dockerfiles fail" "1" "$("$SCRIPT" "$SOURCE" aio-no-dockerfile develop > /dev/null 2>&1 || echo $?)"
check "listing a dir without Dockerfiles fails" "1" "$("$SCRIPT" --list "$TMP" > /dev/null 2>&1 || echo $?)"
check "missing arguments fail" "1" "$("$SCRIPT" "$SOURCE" aio-apache > /dev/null 2>&1 || echo $?)"

if [ "$FAILURES" -ne 0 ]; then
    echo "$FAILURES test(s) failed"
    exit 1
fi
