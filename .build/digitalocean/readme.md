The Digital Ocean build was created following https://marketplace.digitalocean.com/vendors#:~:text=how%20to%20list%20your%201-click%20application%20on%20the%20digitalocean%20marketplace and https://github.com/digitalocean/marketplace-partners#getting-started-creating-your-droplet-based-1-click-app

You can go here: https://github.com/nextcloud-releases/all-in-one/actions/workflows/publish-to-digitalocean.yml to create a new image.

Then update the Marketplace 1-click app with the just created snapshot via the Vendor API, see https://github.com/digitalocean/marketplace-partners#update-your-app-image-via-api (this is not possible via the DO web interface anymore).
