# Nextcloud All-in-One releases

This repository builds and publishes the container images of [Nextcloud All-in-One](https://github.com/nextcloud/all-in-one). The source code lives in that repository; the workflows here check it out to build the images.

- [Build images](https://github.com/nextcloud-releases/all-in-one/actions/workflows/build_images.yml) (publishes `main` as `develop` and `develop-arm64`, or a `release-*` branch as `latest-candidate` and `latest-candidate-arm64`)
- [Promote to beta](https://github.com/nextcloud-releases/all-in-one/actions/workflows/promote-to-beta.yml) (from `develop`)
- [Promote to latest](https://github.com/nextcloud-releases/all-in-one/actions/workflows/promote-to-latest.yml) (from `beta` or `latest-candidate`)
- [VPS and other builds](.build)

To release images without the changes that are currently in `beta`, e.g. a stable release with updated packages, build its `release-*` branch, which publishes it as `latest-candidate`, test it by running `ghcr.io/nextcloud-releases/all-in-one:latest-candidate` (or `:latest-candidate-arm64`), and then promote `latest-candidate` to latest.
