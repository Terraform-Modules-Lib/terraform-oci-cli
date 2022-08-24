# Terraform global configuration
terraform {
  required_providers {
    null = {
      source = "hashicorp/null"
      version = "3.1.1"
    }
    
    local = {
      source = "hashicorp/local"
      version = "2.2.3"
    }
    
    http = {
      source = "hashicorp/http"
      version = "3.0.1"
    }
  }
}

locals {
}

data "http" "oci_cli_installer" {
  url = "https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh"
}

resource "local_file" "oci_cli_installer" {
  filename = "./oci_cli_installer.sh"
  content = data.http.oci_cli_installer.response_body
}

/*
resource "null_resource" "local_oci_cli" {
  triggers = {
    run_every_time = timestamp()
  }
  
  provisioner "local-exec" {
    command = "curl -L -o ./oci_install.sh 'https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh' && chmod u+x ./oci_install.sh && ./oci_install.sh --accept-all-defaults"
  }
}
*/
