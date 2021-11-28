## This is the data source that holds the Python application source code
data "archive_file" "lambda_zip" {
  type             = "zip"
  source_file       = var.app_code_path
  output_file_mode = "0666"
  output_path      = var.app_code_output
}