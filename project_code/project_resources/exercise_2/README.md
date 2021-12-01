# Exercise 2 – Elastic Infrastructure

Deploy the [provided web site](frontend/) on an EC2-based web server. The web application calls the API from the first exercise. The web application should scale elastically based on load (using reasonable metrics of your choosing). Consider how to increase the application's observability. Deploy all infrastructure using an Infrastructure as Code tool (CloudFormation/CDK or Terraform are strongly preferred). EC2 instances should bootstrap themselves without manual intervention.
