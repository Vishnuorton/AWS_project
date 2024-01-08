This repo contains terraform code for wordpress project with disaster recovery approach.

In this project we create two instance  Production and  Disaster recovery instances.we run our application
in production in case if our production server down.we have DR server that contain copy of production server
application file so we get high availailty and disater recovery.

This project does't contain R53 and only support http protocol.

project flow :-

production server ---> s3 ---> DR server

production server and DR server contain wordpress installed . we connect both server with mysql database.

-------------------------------------------------------------------------------------------------------------------------------------------

check terraform.tfvars file to change the values of pre-defined variable of the project.

i make snipets in the code to explain flow of the code.


