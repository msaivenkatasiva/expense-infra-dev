#!bin/bash
component=$1
environment=$2
dnf install ansible -y
pip3.9 install botocore boto3