provider "aws" {
  region = var.region

  shared_config_files      = ["/home/mustafa/.aws/config"]
  shared_credentials_files = ["/home/mustafa/.aws/credentials"]


  # other options for authentication
}