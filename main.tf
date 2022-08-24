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
  oci_installer_url = "https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh"
  oci_installer_filename = "./oci_cli_installer.sh"
  
  oci_private_key_filename = "./.oci/oci.key"
  oci_config_filename = "./.oci/config"
  oci_config_templatename = "./oci_config_file.tftpl"
  
  oci_cli = "$HOME/bin/oci --config-file ${local_file.oci_cli_config_file.filename}"
}

data "http" "oci_cli_installer" {
  url = local.oci_installer_url
}

resource "local_file" "oci_cli_installer" {
  filename = local.oci_installer_filename
  file_permission = "0700"
  
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
  
  filename = local.oci_private_key_filename
  file_permission = "0600"
  
  content = var.oci_private_key
}

resource "local_file" "oci_cli_config_file" {
  filename = local.oci_config_filename
  file_permission = "0600"
  
  content = templatefile(local.oci_config_templatename, {
    oci_tenancy_ocid = var.oci_tenancy_id
    oci_region = var.oci_region_name
    oci_user_ocid = var.oci_user_id
    oci_key_fingerprint = var.oci_key_fingerprint
    oci_private_key_path = local_sensitive_file.oci_cli_private_key.filename
  })
}

resource "null_resource" "oci_cli_commands" {
  for_each = {
    compartment_list = "iam compartment list"
  }
  
  triggers = {
    run_every_time = timestamp()
    
    oci_cli = local.oci_cli
    oci_command = each.value
  }
  
  provisioner "local-exec" {
    command = "${self.triggers.oci_cli} ${self.triggers.oci_command}"
  }
}
