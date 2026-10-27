#!/bin/bash
# SPDX-FileCopyrightText: 2026 Nextcloud GmbH and Nextcloud contributors
# SPDX-License-Identifier: AGPL-3.0-or-later

# Builds one image from a checkout of https://github.com/nextcloud/all-in-one
# and tags it as ghcr.io/nextcloud-releases/<image-name>:<tag>.
# Extra arguments are passed on to `docker buildx build`.
#
# With --list, prints the names of all images in the checkout instead, one per line.
#
# Example: ./build-image.sh ../all-in-one aio-apache develop --platform linux/amd64
# Example: ./build-image.sh --list ../all-in-one

set -eu

usage() {
    echo "Usage: $0 <all-in-one-dir> <image-name> <tag> [docker buildx build args...]" >&2
    echo "       $0 --list <all-in-one-dir>" >&2
    exit 1
}

if [ "${1:-}" = "--list" ]; then
    if [ "$#" -ne 2 ]; then
        usage
    fi
    for FILE in "$2"/Containers/*/Dockerfile; do
        if [ ! -f "$FILE" ]; then
            echo "No Dockerfiles found in $2/Containers" >&2
            exit 1
        fi
        DIR="$(basename "$(dirname "$FILE")")"
        case "$DIR" in
            mastercontainer)
                echo "all-in-one"
                ;;
            *)
                echo "aio-$DIR"
                ;;
        esac
    done
    exit 0
fi

if [ "$#" -lt 3 ]; then
    usage
fi

SOURCE="$1"
NAME="$2"
TAG="$3"
shift 3

case "$NAME" in
    all-in-one)
        CONTEXT="$SOURCE"
        FILE="$SOURCE/Containers/mastercontainer/Dockerfile"
        ;;
    aio-nextcloud)
        CONTEXT="$SOURCE"
        FILE="$SOURCE/Containers/nextcloud/Dockerfile"
        ;;
    aio-*)
        CONTEXT="$SOURCE/Containers/${NAME#aio-}"
        FILE="$CONTEXT/Dockerfile"
        ;;
    *)
        echo "Unknown image name: $NAME" >&2
        exit 1
        ;;
esac

if [ ! -f "$FILE" ]; then
    echo "Dockerfile not found: $FILE" >&2
    exit 1
fi

docker buildx build --file "$FILE" --tag "ghcr.io/nextcloud-releases/$NAME:$TAG" "$@" "$CONTEXT"
