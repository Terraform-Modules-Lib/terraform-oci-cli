output "oci_cli_command_outputs" {
  
  description = "Outputs from oci cli commands json decoded"
  
  value = { 
    for command_key, command_output in data.local_file.oci_cli_command_outputs : command_key => jsondecode(command_output.content)
  }
}
