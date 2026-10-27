#!/bin/bash
# SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
# SPDX-License-Identifier: AGPL-3.0-or-later

# Tests verify-images.sh with docker replaced by a stub that prints prepared `docker buildx imagetools inspect` output.

set -eu

SCRIPT="$(cd "$(dirname "$0")/.." && pwd)/verify-images.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# The stub prints the file in $TMP/images that is named after the image, or fails like a missing tag
mkdir -p "$TMP/bin" "$TMP/images"
cat > "$TMP/bin/docker" << 'STUB'
#!/bin/bash
FILE="$IMAGES/$(tr '/:' '__' <<< "$4")"
if [ ! -f "$FILE" ]; then
    echo "ERROR: $4: not found" >&2
    exit 1
fi
cat "$FILE"
STUB
chmod +x "$TMP/bin/docker"
export PATH="$TMP/bin:$PATH"
export IMAGES="$TMP/images"

OLD=1111111111111111111111111111111111111111
NEW=2222222222222222222222222222222222222222

# Single-platform image, as `{{json .Image}}` prints it for an image without an index
single() {
    printf '{"architecture": "%s", "os": "linux", "config": {"Labels": {"org.opencontainers.image.revision": "%s"}}}' "$2" "$3" \
        > "$IMAGES/$(tr '/:' '__' <<< "$1")"
}
# Multi-platform image with an attestation, as `{{json .Image}}` prints it for an index
multi() {
    printf '{"linux/amd64": {"architecture": "amd64", "os": "linux", "config": {"Labels": {"org.opencontainers.image.revision": "%s"}}},
             "linux/arm64": {"architecture": "arm64", "os": "linux", "config": {"Labels": {"org.opencontainers.image.revision": "%s"}}},
             "unknown/unknown": {"architecture": "unknown", "os": "unknown", "config": {}}}' "$2" "$3" \
        > "$IMAGES/$(tr '/:' '__' <<< "$1")"
}

R=ghcr.io/nextcloud-releases
# latest-candidate: single-architecture images, as built by build-image.sh
single "$R/all-in-one:latest-candidate" amd64 "$NEW"
single "$R/all-in-one:latest-candidate-arm64" arm64 "$NEW"
single "$R/aio-apache:latest-candidate" amd64 "$NEW"
single "$R/aio-apache:latest-candidate-arm64" arm64 "$NEW"
single "$R/aio-stale:latest-candidate" amd64 "$OLD"
single "$R/aio-stale:latest-candidate-arm64" arm64 "$OLD"
single "$R/aio-wrong-arch:latest-candidate" arm64 "$NEW"
single "$R/aio-wrong-arch:latest-candidate-arm64" arm64 "$NEW"
single "$R/aio-only-amd64:latest-candidate" amd64 "$NEW"
# beta: multi-architecture images, as created by promote-to-beta.yml
multi "$R/all-in-one:beta" "$NEW" "$NEW"
multi "$R/all-in-one:beta-arm64" "$NEW" "$NEW"
multi "$R/aio-mixed:beta" "$NEW" "$OLD"
multi "$R/aio-mixed:beta-arm64" "$NEW" "$OLD"
printf '{"architecture": "amd64", "os": "linux", "config": {}}' > "$IMAGES/$(tr '/:' '__' <<< "$R/all-in-one:unlabeled")"
single "$R/all-in-one:arm64-only" arm64 "$NEW"

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
status() {
    "$SCRIPT" "$@" > /dev/null 2>&1 && echo 0 || echo $?
}

check "revision of single-architecture images is read" "$NEW" "$("$SCRIPT" --revision latest-candidate)"
check "revision of multi-architecture images is read" "$NEW" "$("$SCRIPT" --revision beta)"
check "unlabeled images have no revision and are reported separately" "2" "$(status --revision unlabeled)"
check "missing images have no revision" "1" "$(status --revision missing)"
check "images without an amd64 image have no revision" "1" "$(status --revision arm64-only)"

check "images built from the commit pass" "0" "$(status latest-candidate "$NEW" all-in-one aio-apache)"
check "multi-architecture images built from the commit pass" "0" "$(status beta "$NEW" all-in-one)"
check "images built from another commit fail" "1" "$(status latest-candidate "$NEW" all-in-one aio-stale)"
check "images with the wrong architecture fail" "1" "$(status latest-candidate "$NEW" aio-wrong-arch)"
check "images missing the arm64 tag fail" "1" "$(status latest-candidate "$NEW" aio-only-amd64)"
check "missing images fail" "1" "$(status latest-candidate "$NEW" aio-missing)"
check "multi-architecture images partly built from another commit fail" "1" "$(status beta "$NEW" aio-mixed)"
check "all images are checked, not only up to the first problem" "2" \
    "$("$SCRIPT" latest-candidate "$NEW" aio-stale all-in-one aio-missing 2>&1 >/dev/null | grep -c 'aio-missing:latest-candidate')"
check "missing arguments fail" "1" "$(status latest-candidate "$NEW")"

if [ "$FAILURES" -ne 0 ]; then
    echo "$FAILURES test(s) failed"
    exit 1
fi
