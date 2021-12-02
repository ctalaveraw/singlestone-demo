#!/bin/bash


## Generate a key, adding in the hostname as the author
ssh-keygen -t rsa -f "./ssh_aws_ec2_fortune" -P ""

## Show the created public key
cat ./ssh_aws_ec2_fortune.pub
