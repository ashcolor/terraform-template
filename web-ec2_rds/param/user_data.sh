#!/bin/bash

yum update
yum install -y httpd
systemctl start httpd
systemctl enable httpd
