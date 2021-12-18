# Welcome to my serverless fortune demo

This demo will deploy a serverless web application that fetches a randomly generated fortune.

Current example of running project:

- [Lambda Function behind ALB](http://random-fortune-alb-1107252489.us-east-1.elb.amazonaws.com/)
- [Web Server calling Lambda Function](http://fortune-webapp-alb-2007243567.us-east-1.elb.amazonaws.com/)

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

## Prerequisites for execution

- Git
- Terraform
- Active AWS account
  - IAM user with admin privileges
    - IAM access key
    - IAM secret key

## Project architecture

[`exercise_1`](exercise_1/)

### Lambda function deployment on AWS using Terraform

1. The fortune Python app will send an HTTP request to <http://yerkee.com/api/fortune/computers>; the webpage will return a JSON object.
2. The Python app will display the returned JSON as output. The app will be hosted on AWS using Lambda.
3. The function will only be run everytime there is an HTTP request to the Lambda app
4. The function will be deployed with automation on AWS using Terraform
5. CloudWatch metrics are automatically implemented for the created Lambda function with Terraform

[`exercise_2`](exercise_2/)

### Deployment of scalable web server calling Lambda  on AWS using Terraform

1. An EC2 server will be provisioned on AWS using Terraform, which will host an Apache web server server
2. The Apache server will host a static web site that will call the created Lambda function from `exercise_1`
3. The EC2 instance will appropriately scale based on server load
4. CloudWatch metrics are automatically implemented for the created web server to scale based on traffic levels

## Setting up deployment

1. Clone the repository locally:

    ``` bash
    git clone https://github.com/ctalaveraw/singlestone-demo
    ```

2. Navigate to project directory:

    ``` bash
    cd project_code/
    ```

## Executing deployment

### [`exercise_1`](exercise_1/)

1. Navigate to the deployment directory:

    ``` bash
    cd exercise_1/deployment
    ```

2. Initialize Terraform:

    ``` bash
    terraform init
    ```

3. Rename `local_deployment` to `local_deployment.tfvars`:

    ``` bash
    mv local_deployment local_deployment.tfvars
    ```

4. Edit the `local_deployment.tfvars` file to add IAM secrets for Terraform's access to AWS:

    ``` HCL
    /*
    These store the access keys for the AWS account; this should not have public access
    */

    aws_access_key = "INSERT_ACCESS_KEY_HERE"
    aws_secret_key = "INSERT_SECRET_KEY_HERE"
    ```

5. Verify successful use of AWS access keys:

    ``` bash
    terraform plan -var-file=./local_deployment.tfvars
    ```

6. If good to go, apply the deployment:

    ``` bash
    terraform apply --auto-approve -var-file=./local_deployment.tfvars
    ```

7. The Lambda application deployment should be successful; check the AWS admin console to verify resources are created. Copy and paste the URL of the created API Gateway for deployment of [`exercise_2`](exercise_2/)

### [`exercise_2`](exercise_2/)

#### NOTE: [`exercise_1`](exercise_1/) must be deployed FIRST, as the URL of the created ALB behind the Lambda function must be hard-coded into the "index.html" front-end webpage \*

1. Navigate to the deployment directory:

    ``` bash
    cd exercise_2/deployment
    ```

2. Edit the JavaScript code in the `apache_server_bootstrap.sh` bash script to use the URL of the ALB behind the Lambda function created from [`exercise_1`](exercise_1/):

    ``` bash
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
        fetch('INSERT_URL_OF_ALB_BEHIND_LAMBDA_FUNCTION_HERE').then(resp => resp.json()).then(data => {
            document.getElementById('fortune').innerText = data['fortune']
        });
        </script>
    <! The 'script' block represents client-side JavaScript to be run>
    </body>
    </html>

    <script>
    // the lambda url is dependent upon exercise_1 deployment to get the URL of the associated API gateway
    </script>" > /var/www/html/index.html


    ...
    ```

3. Create an SSH key pair using pre-built script:

    ``` bash
    ./generate_key.sh
    ```

4. Initialize Terraform:

    ``` bash
    terraform init
    ```

5. Rename `local_deployment` to `local_deployment.tfvars`:

    ``` bash
    mv local_deployment local_deployment.tfvars
    ```

6. Edit the `local_deployment.tfvars` file to add IAM secrets for Terraform's access to AWS:

    ``` bash
    /*
    These store the access keys for the AWS account; this should not have public access
    */

    aws_access_key = "INSERT_ACCESS_KEY_HERE"
    aws_secret_key = "INSERT_SECRET_KEY_HERE"
    ```

7. Edit the `local_deployment.tfvars` file to add the path of the created SSH keys for Terraform's access to AWS:

    ``` bash
    ## These point to the path of the EC2 instance's SSH keys
    aws_ssh_key_public_fortune = "PUT_PUBLIC_KEY_PATH_HERE"
    aws_ssh_key_private_fortune = "PUT_PRIVATE_KEY_PATH_HERE"
    ```

8. Verify successful use of AWS access keys:

    ``` bash
    terraform plan -var-file=./local_deployment.tfvars
    ```

9. If good to go, apply the deployment:

    ``` bash
    terraform apply --auto-approve -var-file=./local_deployment.tfvars
    ```

10. The web server calling the created Lambda application from [`exercise_1`](exercise_1/) should be successful; check the AWS admin console to verify resources are created

## Timeline of work

### **2021-11-18**

- Received the technical exercise
  - Computer was borked, new computer acquired on 2021-11-22

### **2021-11-23**

#### Project work began

- Research done on `os`, `sys`, `traceback`, `logging`, and `requests` Python modules for application source code to understand the given Lambda application for project use
- Using old SSH keys for Git account on new account caused initial setback
  - Issue: GitHub SSH keys with custom filenames are not supported
    - Solution: Only SSH keys with the following names are supported in GitHub:
      - `id_rsa.pub`
      - `id_ecdsa.pub`
      - `id_ed25519.pub`
- Terraform project skeleton was created for `exercise_1` deployment
  - The following project files were created:
    - `main.tf`
    - `providers.tf`
    - `data.tf`
    - `resources_lambda.tf`
    - `resources_api.tf`
- Working Lambda infrastructure is provisioned with Terraform, actual Lambda function is not working yet
  - Learned about `EOF` for use within Terraform for long scripts
  - Terraform deployment kept timing out, so remaining resources were manually deleted and resource destruction proceeded as normal
  - Issue: An error was thrown, "A managed resource has not been declared in the root module"
    - Solution: There was no custom VPC resource created for this deployment, so the `aws_default_vpc` and `aws_default_subnet` resources were used instead

### **2021-11-24**

#### Work on ``exercise_1`` continues

- Attempted to upload custom Lambda function on AWS
  - Managed to get the Python application source code to be successfully uploaded with Terraform using the `remote-exec` provisioner
    - Used secrets within Terraform for deployment, stored in `local_deployment.tfvars` file:
      - AWS access key
      - AWS secret key
- Debugging is needed for custom Lambda application
  - CloudWatch logging group, IAM and attachment resources were added to Terraform deployment to allow for detailed Lambda logging
- Issue: Lambda function giving HTTP 503 error
  - Solution: Function was missing an IAM role, so one was created and attached with Terraform
- Issue: Error with Lambda function being loaded on AWS:

  ```Python
  Unable to import module 'lambda_function': No module named 'lambda_function'
  ```

  - Solution: The file name of the Lambda function was incorrectly defined; the correct syntax is `PYTHON_FILE_NAME.METHOD_NAME` so the proper Lambda function handler is called
- Issue: Error with `requests` library not loaded on Lambda function:

  ```Python
  Unable to import module 'lambda_function': No module named 'requests'
  ```

  - Solution: the required `requests` library for HTTP GET requests needs installation in the root directory of the application code using:

     ``` bash
     pip install --target="./" requests
     ```

    - AWS Lambda does not come with many commonly-used Python libraries; they have to be packaged with the application, or separately uploaded using Lambda layers

### **2021-11-25**

#### Attempted to implement an ALB
