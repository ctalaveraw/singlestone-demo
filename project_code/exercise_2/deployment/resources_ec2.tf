
## SSH key pair for the instance will be created to SSH for running bootstrap
resource "aws_key_pair" "fortune-keypair" {
  key_name   = "fortune-keypair"
  public_key = file(var.aws_ssh_key_public_fortune)

}

## An EC2 instance for the "random fortune" app will be created
resource "aws_instance" "fortune-web-server" {
  ami                         = data.aws_ami.amazon-linux-2.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.fortune-keypair.key_name
  tags = {
    Name = "fortune-web-server"
  }
  ## This reads the script that needs to be deployed to the EC2 instance
  provisioner "file" {
    source      = "apache_server_bootstrap.sh"
    destination = "/tmp/apache_server_bootstrap.sh" # Copies script to /tmp/ directory
  }
  ## This executes the script remotely on the EC2 instance
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/apache_server_bootstrap.sh", # Makes the script executable
      "sudo /tmp/apache_server_bootstrap.sh"      # Runs the script
    ]
  }
  connection {
    host        = ""
    type        = "ssh"
    user        = ""
    private_key = file(var.aws_ssh_key_private_fortune)
  }
}
