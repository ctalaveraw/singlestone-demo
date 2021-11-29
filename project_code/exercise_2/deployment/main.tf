/*
Unfortunately, the deployment of exercise_2 is strongly coupled
to an already-active deployment of exercise_1; the API gateway address
will be pasted into 'requests' part of the HTML code for the server homepage.

This means that this Terraform deployment is not modular.
It be for the infrastructure needed to make a scalable static
website based on EC2.

A bootstrap script will be provided for the apache server to automate its configuration
*/