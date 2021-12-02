#!/bin/bash


## Generate a key, adding in the hostname as the author
ssh-keygen -t rsa -f "./ssh_keys/aws_ec2_ssh_fortune" -P ""

## Show the created public key
cat ./ssh_keys/aws_ec2_ssh_fortune.pub
