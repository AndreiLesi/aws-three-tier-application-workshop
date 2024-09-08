provider "aws" {
  region = local.region
  default_tags {
    tags = {
      Creator = "Andrei Lesi"
      Project = "three-tier-architecture"
    }
  }
}