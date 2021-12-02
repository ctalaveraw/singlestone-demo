

## A network interface will be created to attach to the EC2
resource "aws_network_interface" "fortune_network_interface" {
  subnet_id   = aws_subnet.fortune-subnet-public-1.id
  private_ips = ["10.0.0.69"]

}

## An EC2 instance for the "random fortune" app will be created
resource "aws_instance" "fortune-web-server" {
  ami                         = data.aws_ami.amazon-linux-2.id
  availability_zone           = "us-east-1a"
  subnet_id                   = aws_subnet.fortune-subnet-public-1.id
  vpc_security_group_ids      = ["${aws_security_group.fortune-security-group.id}"]
  instance_type               = "t3.micro"
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
    type        = "ssh"
    host        = coalesce(self.public_ip, self.private_ip)
    user        = var.instance_username
    private_key = file(var.aws_ssh_key_private_fortune)
  }
}
