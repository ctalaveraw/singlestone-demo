## This is the data source that holds the Python application source code
data "archive_file" "lambda_zip" {
  type             = "zip"
  output_file_mode = "0666"
  source_dir       = var.app_code_path
  output_path      = var.app_code_output
}
