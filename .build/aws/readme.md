# AWS

The AWS build is mostly based on the guide from here: https://learn.hashicorp.com/collections/packer/aws-get-started

You can go here: https://github.com/nextcloud-releases/all-in-one/actions/workflows/publish-to-aws.yml to create a new image.

The image can then be reached in for testing here: https://aws.amazon.com/marketplace/management/manage-products/#/ and click on `Add new AMI` to retrieve the 

Afterwards the image can be updated here: https://aws.amazon.com/marketplace/management/products/server. Click on the Nextcloud offering and click on `Add new version`. Then choose the new version title, for `Amazon Machine Image (AMI) ID` enter the `ami-xxx` version that you retrieved in the former step. For `IAM access role ARN`, enter `arn:aws:iam::<your-IAM-name>:role/RoleName`. `<your-IAM-name>` can be retrieved from your IAM user name (passwort manager).

# test