# Nextcloud All-in-One releases

This repository builds and publishes the container images of [Nextcloud All-in-One](https://github.com/nextcloud/all-in-one). The source code lives in that repository; the workflows here check it out to build the images.

- [Build images](https://github.com/nextcloud-releases/all-in-one/actions/workflows/build_images.yml) (publishes `develop` and `develop-arm64`)
- [Promote to beta](https://github.com/nextcloud-releases/all-in-one/actions/workflows/promote-to-beta.yml)
- [Promote to latest](https://github.com/nextcloud-releases/all-in-one/actions/workflows/promote-to-latest.yml)
- [VPS and other builds](.build)
