#!/bin/bash
# Wrapper script to create Infrastructure
# Author: Vijay Anand Karthikeyan

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <resource-group-name>"
    exit 1
fi

az deployment group create  \
        --resource-group ${1} \
        --template-file azuredeploy.json \
        --parameters azuredeploy.parameters.json \
        --mode Complete \
        --parameters vmAdminPassword='BadPass#1' AllowIPAddress='71.135.69.90/32' deployVMinPrivateSubnet=false deployBastionVM=false
