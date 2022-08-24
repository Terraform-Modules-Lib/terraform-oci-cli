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

resource "null_resource" "oci_cli_installer" {
  triggers = {
    run_every_time = timestamp()
    
    command = "${local_file.oci_cli_installer.filename} --accept-all-defaults"
  }
  
  provisioner "local-exec" {
    command = "${self.triggers.command}"
  }
}

resource "local_sensitive_file" "oci_cli_private_key" {
  depends_on = [
    null_resource.oci_cli_installer
  ]
  
  filename = "./.oci/oci.key"
  content = var.oci_private_key
}
