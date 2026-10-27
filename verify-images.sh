#!/bin/bash
# SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
# SPDX-License-Identifier: AGPL-3.0-or-later

# Checks that the images at ghcr.io/nextcloud-releases/<image-name>:<tag> (amd64) and :<tag>-arm64 (arm64)
# were all built from the same commit of nextcloud/all-in-one, so that they can be promoted together.
# The commit is read from the org.opencontainers.image.revision label that build-image.sh is called with.
#
# With --revision, prints the commit that the amd64 image of ghcr.io/nextcloud-releases/all-in-one:<tag> was built from instead.
# It exits with 2 if that image exists but has no revision label, e.g. because it was built before the label was introduced.
#
# Example: ./verify-images.sh latest-candidate 0123abcd... aio-apache all-in-one
# Example: ./verify-images.sh --revision latest-candidate

set -eu -o pipefail

REGISTRY="ghcr.io/nextcloud-releases"

usage() {
    echo "Usage: $0 <tag> <commit> <image-name>..." >&2
    echo "       $0 --revision <tag>" >&2
    exit 1
}

# Prints "<os>/<architecture> <revision>" for every platform of the given image
platform_revisions() {
    docker buildx imagetools inspect "$1" --format '{{json .Image}}' | jq --raw-output '
        (if has("architecture") then [.] else [.[]] end)[]
        | select(.os != "unknown")
        | "\(.os)/\(.architecture) \(.config.Labels["org.opencontainers.image.revision"] // "none")"'
}

if [ "${1:-}" = "--revision" ]; then
    if [ "$#" -ne 2 ]; then
        usage
    fi
    REVISION="$(platform_revisions "$REGISTRY/all-in-one:$2" | awk '$1 == "linux/amd64" { print $2 }')"
    if [ -z "$REVISION" ]; then
        echo "$REGISTRY/all-in-one:$2 has no linux/amd64 image." >&2
        exit 1
    fi
    if [ "$REVISION" = "none" ]; then
        echo "$REGISTRY/all-in-one:$2 has no revision label." >&2
        exit 2
    fi
    echo "$REVISION"
    exit 0
fi

if [ "$#" -lt 3 ]; then
    usage
fi

TAG="$1"
COMMIT="$2"
shift 2

FAILED=0
for NAME in "$@"; do
    for ARCH in amd64 arm64; do
        if [ "$ARCH" = "amd64" ]; then
            IMAGE="$REGISTRY/$NAME:$TAG"
        else
            IMAGE="$REGISTRY/$NAME:$TAG-arm64"
        fi
        if ! REVISIONS="$(platform_revisions "$IMAGE" 2>&1)"; then
            echo "$IMAGE could not be inspected: $REVISIONS" >&2
            FAILED=1
            continue
        fi
        if ! grep -qx "linux/$ARCH $COMMIT" <<< "$REVISIONS"; then
            echo "$IMAGE has no linux/$ARCH image built from $COMMIT." >&2
            FAILED=1
        fi
        if OTHERS="$(grep -vx "[^ ]* $COMMIT" <<< "$REVISIONS")"; then
            echo "$IMAGE contains images built from another revision: $OTHERS" >&2
            FAILED=1
        fi
    done
done

exit "$FAILED"
