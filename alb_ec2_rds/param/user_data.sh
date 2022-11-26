#!/bin/bash

yum update

# Web Server
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# MySQL
yum install -y mysql
