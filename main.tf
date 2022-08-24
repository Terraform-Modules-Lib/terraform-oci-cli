# Terraform global configuration
terraform {
  required_providers {
    null = {
      source = "hashicorp/null"
      version = "3.1.1"
    }
  }
}

locals {
}

resource "null_resource" "local_oci_cli" {
  triggers = {
    run_every_time = timestamp()
  }
  
  provisioner "local-exec" {
    command = "curl -L -o ./oci_install.sh 'https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh' && chmod u+x ./oci_install.sh && ./oci_install.sh --accept-all-defaults"
  }
}
