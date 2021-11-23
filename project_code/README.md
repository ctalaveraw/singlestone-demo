# Welcome to my serverless fortune demo!

This demo will deploy a serverless web application that fetches a randomly generated fortune.

The toolset used to build this project is:

- GitHub - code repository to host all source code and configuration files
- Python - all application code will be written in Python
- Terraform - automated, platform-agnostic IaC infrastructure provisioning tool to deploy the app on the cloud
- AWS - cloud service provider that will host the actual project
    - Lambda - scalable, serverless compute platform
    - ALB - Application Load Balancer to appropriately scale requests
    - EC2 - to host a static website to call the created Lambda function


## Project architecture
*exercise_1*

1. The fortune Python app will send an HTTP request to http://yerkee.com/api/fortune/computers; the webpage will return a JSON object. 
2. The Python app will display the returned JSON as output. The app will be hosted on AWS using Lambda.
3. The web app will only be run everytime there is an HTTP request to the Lambda app.
4. The function will be deployed with automation on AWS using Terraform
5. (optional) I will attempt to implement metrics and logging for the Lambda function

*exercise_2*
1. An EC2 server will be provisioned on AWS using Terraform, which will host an Apache web server server
2. The Apache server will host a static web site that will call the created Lambda function from *exercise_1*
3. The EC2 instance will appropriately scale based on server load
4. (optional) I will attempt to implement metrics and logging on the EC2 instance
