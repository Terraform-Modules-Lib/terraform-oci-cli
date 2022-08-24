output "oci_cli_command_outputs" {
  
  description = ""
  
  value = { 
    for command_key, command_output in data.local_file.oci_cli_command_outputs : command_key => command_output.content
  }
}
