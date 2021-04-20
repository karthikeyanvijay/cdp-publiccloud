#!/bin/bash
# Usage: ./deploy-cloudformation-stack.sh
source config_file
if [ "x" == "x$EnvironmentPrefix" ] || [ "x" == "x$MyIpAddressCIDR" ] ; then
  echo "Ensure that the required variables are set in the config_file"
  exit 1
fi

aws_cli_region=`aws configure get region`
stack_name="${EnvironmentPrefix}-cdp-network"

# Check if stack exists
check_stack=`aws cloudformation describe-stacks --stack-name=${EnvironmentPrefix}-cdp-network 2>&1`
if [ $? -ne 0 ]; then
    # If Stack does not exist, create one
    echo "Creating stack ${stack_name} in ${aws_cli_region}"
    aws cloudformation create-stack \
        --stack-name ${stack_name} \
        --template-body file://cloudformation-network.yml \
        --parameters file://cloudformation-parameters.json \
        --tags file://cloudformation-tags.json \
        --parameters ParameterKey=EnvironmentPrefix,ParameterValue=${EnvironmentPrefix} ParameterKey=AllowIPAddress,ParameterValue=${MyIpAddressCIDR} ParameterKey=DeployPrivateSubnets,ParameterValue=${DeployPrivateSubnets} ParameterKey=DeployBastionHost,ParameterValue=${DeployBastionHost} ParameterKey=SSHKeyName,ParameterValue=${SSHKeyName} ParameterKey=LinuxAMIId,ParameterValue=${LinuxAMIId}
    echo "Waiting for stack ${stack_name} to complete.."
    aws cloudformation wait stack-create-complete --stack-name ${stack_name}
else
    # If Stack exists, create a deploy a change set
    datetime=`date +'%Y%m%d-%H%M%S'`
    changeset_name="change-${datetime}"
    echo "Creating Change set ${changeset_name} for stack ${stack_name}..."

    # Create Change set & wait for completion
    aws cloudformation create-change-set \
        --stack-name ${stack_name} \
        --change-set-name ${changeset_name} \
        --template-body file://cloudformation-network.yml \
        --parameters file://cloudformation-parameters.json \
        --tags file://cloudformation-tags.json \
        --parameters ParameterKey=EnvironmentPrefix,ParameterValue=${EnvironmentPrefix} ParameterKey=AllowIPAddress,ParameterValue=${MyIpAddressCIDR} ParameterKey=DeployPrivateSubnets,ParameterValue=${DeployPrivateSubnets} ParameterKey=DeployBastionHost,ParameterValue=${DeployBastionHost} ParameterKey=SSHKeyName,ParameterValue=${SSHKeyName}  ParameterKey=LinuxAMIId,ParameterValue=${LinuxAMIId}
    aws cloudformation wait change-set-create-complete \
        --stack-name ${stack_name} \
        --change-set-name ${changeset_name}
    
    # Prompt for user confirmation to proceed
    while true; do
        read -p "Execute the change set ${changeset_name} for stack ${stack_name} (Y/N)? " yn
        case $yn in
            [Yy]* ) break;;
            [Nn]* ) exit 0;;
            * ) echo "Please answer Yes or No.";;
        esac
    done

    # Execute Change set & wait for completion
    echo "Executing change set, waiting for it to complete..."
    aws cloudformation execute-change-set \
        --stack-name ${stack_name} \
        --change-set-name ${changeset_name}
    aws cloudformation wait stack-update-complete \
        --stack-name ${stack_name}

fi

# Reading the output for the stack
aws cloudformation describe-stacks --stack-name=${EnvironmentPrefix}-cdp-network | jq '.Stacks[].Outputs[]'