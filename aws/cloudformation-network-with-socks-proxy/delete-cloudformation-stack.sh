#!/bin/bash -e
# Usage: ./delete-cloudformation-stack.sh

source config_file
if [ "x" == "x$EnvironmentPrefix" ] ; then
  echo "Ensure that the required variables are set in the config_file"
  exit 1
fi

stack_name="${EnvironmentPrefix}-cdp-network"
aws_cli_region=`aws configure get region`
# Prompt for user confirmation to proceed
while true; do
    read -p "Confirm deletion of stack ${stack_name} in ${aws_cli_region} (Y/N)? " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit 0;;
        * ) echo "Please answer Yes or No.";;
    esac
done

echo "Executing delete stack..."
aws cloudformation delete-stack \
    --stack-name ${stack_name}
echo "Waiting for stack to be deleted..."
aws cloudformation wait stack-delete-complete \
    --stack-name ${stack_name}
echo "Done"
