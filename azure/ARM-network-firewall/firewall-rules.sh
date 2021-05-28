#!/bin/bash
# Wrapper script to create/update firewall rules
# Author: Vijay Anand Karthikeyan

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <resource-group-name>"
    exit 1
fi

resource_group_name=$1

az deployment group create  \
        --resource-group ${resource_group_name} \
        --template-file firewall-rules-template.json \
        --mode Complete
