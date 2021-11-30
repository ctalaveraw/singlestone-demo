## This script will bootstrap an Apache webserver
## It will host the Lambda app static webpage

#!/bin/bash

## Run OS updates
yum update -y

## Install Apache webserver
yum install -y httpd

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
    fetch('https://ipqy2r8hp8.execute-api.us-east-1.amazonaws.com/*').then(resp => resp.json()).then(data => {
        document.getElementById('fortune').innerText = data['fortune']
    });
    </script>
<! The 'script' block represents client-side JavaScript to be run>
</body>
</html>

<script>
// the lambda url is dependent upon exercise_1 deployment to get the URL of the associated API gateway
</script>" > ./index.html

## Start the Apache system service
systemctl start httpd

## Enable the Apache system service
systemctl enable httpd