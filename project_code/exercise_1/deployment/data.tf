## This is the data source that holds the Python application source code
data "archive_file" "lambda_zip" {
  type             = "zip"
  source_dir       = "source_code"
  output_file_mode = "0666"
  output_path      = "lambda_fortune_app.zip"
}