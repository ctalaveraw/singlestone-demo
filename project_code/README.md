# Welcome to my serverless fortune demo!

This demo will deploy a serverless web application that fetches a randomly generated fortune.

The toolset used to build this project is:

- GitHub - code repository to host all source code and configuration files
- Python - all application code will be written in Python
- JavaScript - the frontend of the web application calling the Lambda function is in JavaScript
- Terraform - automated, platform-agnostic IaC infrastructure provisioning tool to deploy the app on the cloud
- AWS - cloud service provider that will host the actual project
    - [`exercise_1`](exercise_1/)
        - Lambda - scalable, serverless compute platform to run the random fortune app
        - API Gateway - infrastructure to make an API for the Lambda function
        - IAM roles - to give Lambda permission
        - CloudWatch - stores logs for every execution of the function
        - Security Group - to allow public access
        - ALB - Application Load Balancer handles requests for high-availability
            - 2x Subnets - for ALB to distribute traffic 
    - [`exercise_2`](exercise_2/)
        - EC2 - to host a static website to call the created Lambda function (*coupled to output from Lambda function*)
        - Auto Scaling Group - to allow for website to scale based on traffic demand


## Prerequisites for execution:
- Git 
- Terraform
- Active AWS account
    - IAM user with admin privileges
        - IAM access key
        - IAM secret key

## Project architecture
[`exercise_1`](exercise_1/)

*Lambda function deployment on AWS using Terraform*

1. The fortune Python app will send an HTTP request to http://yerkee.com/api/fortune/computers; the webpage will return a JSON object. 
2. The Python app will display the returned JSON as output. The app will be hosted on AWS using Lambda.
3. The function will only be run everytime there is an HTTP request to the Lambda app
4. The function will be deployed with automation on AWS using Terraform
5. CloudWatch metrics are automatically implemented for the created Lambda function with Terraform

[`exercise_2`](exercise_2/)

*Deployment of scalable web server calling Lambda  on AWS using Terraform*

1. An EC2 server will be provisioned on AWS using Terraform, which will host an Apache web server server
2. The Apache server will host a static web site that will call the created Lambda function from `exercise_1`
3. The EC2 instance will appropriately scale based on server load
4. CloudWatch metrics are automatically implemented for the created web server to scale based on traffic levels


## Setting up deployment

1. Clone the repository locally:
    ```
    $ git clone https://github.com/ctalaveraw/singlestone-demo
    ```
2. Navigate to project directory:
    ```
    $ cd project_code/
    ```

## Executing deployment
[`exercise_1`](exercise_1/)


1. Navigate to the deployment directory:
    ```
    $ cd exercise_1/deployment 
    ```
2. Initialize Terraform:
    ```
    $ terraform init
    ```
3. Rename `local_deployment` to `local_deployment.tfvars`:
    ```
    $ mv local_deployment local_deployment.tfvars
    ```
4. Edit the `local_deployment.tfvars` file to add IAM secrets for Terraform's access to AWS:
    ```
    ...

    /*
    These store the access keys for the AWS account; this should not have public access
    */

    aws_access_key = "INSERT_ACCESS_KEY_HERE"
    aws_secret_key = "INSERT_SECRET_KEY_HERE"
    
    ...
    ```
5. Verify successful use of AWS access keys:
    ```
    $ terraform plan -var-file=./local_deployment.tfvars
    ```
6. If good to go, apply the deployment:
    ```
    $ terraform apply --auto-approve -var-file=./local_deployment.tfvars
    ```
7. The Lambda application deployment should be successful; check the AWS admin console to verify resources are created. Copy and paste the URL of the created API Gateway for deployment of [`exercise_2`](exercise_2/)

[`exercise_2`](exercise_2/)

\* NOTE: [`exercise_1`](exercise_1/) must be deployed FIRST, as the URL of the created API gateway must be hard-coded into the "index.html" front-end webpage \*

1. Navigate to the deployment directory:
    ```
    $ cd exercise_2/deployment 
    ```
2. Edit the JavaScript code in the `apache_server_bootstrap.sh` bash script to use the URL of the API Gateway created from [`exercise_1`](exercise_1/):
    ```
    ...

    ## Create the index.html homepage
    echo "<!DOCTYPE html>
    <html lang='en'>
    <head>
        <meta charset='UTF-8'>
        <meta name='viewport' content='width=device-width, initial-scale=1.0'>
        <title>Fortune Frontend</title>
    </head>
    <! The above 'head' block contains formatting information>

    <body>
        <h2>Your fortune is:</h2>
        <p id='fortune'>Loading...</p>
        <p>Version 0.2</p>
        <script>
        fetch('INSERT_URL_OF_API_GATEWAY_HERE').then(resp => resp.json()).then(data => {
            document.getElementById('fortune').innerText = data['fortune']
        });
        </script>
    <! The 'script' block represents client-side JavaScript to be run>
    </body>
    </html>

    <script>
    // the lambda url is dependent upon exercise_1 deployment to get the URL of the associated API gateway
    </script>" > ./index.html

    ...
    ```
3. Create an SSH key pair using pre-built script:
    ```
    $ ./generate_key.sh
    ```

4. Initialize Terraform:
    ```
    $ terraform init
    ```
5. Rename `local_deployment` to `local_deployment.tfvars`:
    ```
    $ mv local_deployment local_deployment.tfvars
    ```
6. Edit the `local_deployment.tfvars` file to add IAM secrets for Terraform's access to AWS:
    ```
    ...

    /*
    These store the access keys for the AWS account; this should not have public access
    */

    aws_access_key = "INSERT_ACCESS_KEY_HERE"
    aws_secret_key = "INSERT_SECRET_KEY_HERE"
    
    ...
    ```
7. Edit the `local_deployment.tfvars` file to add SSH keys for Terraform's access to AWS:
    ```
    ...

    ## These point to the path of the EC2 instance's SSH keys
    aws_ssh_key_public_fortune = "PUT_PUBLIC_KEY_PATH_HERE"
    aws_ssh_key_private_fortune = "PUT_PRIVATE_KEY_PATH_HERE"
    
    ...
    ```
8. Verify successful use of AWS access keys:
    ```
    $ terraform plan -var-file=./local_deployment.tfvars
    ```
9. If good to go, apply the deployment:
    ```
    $ terraform apply --auto-approve -var-file=./local_deployment.tfvars
    ```
10. The web server calling the created Lambda application from [`exercise_1`](exercise_1/) should be successful; check the AWS admin console to verify resources are created