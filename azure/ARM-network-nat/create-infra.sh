#!/bin/bash
# Wrapper script to create Infrastructure
# Author: Vijay Anand Karthikeyan

source config_file
if [ "x" == "x$namePrefix" ] || [ "x" == "x$MyIpAddressCIDR" ] || [ "x" == "x$ResourceGroup" ] || [ "x" == "x$vmAdminPassword" ] || [ "x" == "x$deployVMinPrivateSubnet" ] || [ "x" == "x$deployBastionVM" ] || [ "x" == "x$resourceTags" ] || [ "x" == "x$setupPeeredNetwork" ] || [ "x" == "x$vmCountinPeeredNetwork" ]; then
  echo "Ensure that the required variables are set in the config_file"
  exit 1
fi

az deployment group create  \
      --resource-group ${ResourceGroup} \
      --template-file azuredeploy.json \
      --parameters azuredeploy.parameters.json \
      --parameters namePrefix=${namePrefix} vmAdminPassword=${vmAdminPassword} AllowIPAddress=${MyIpAddressCIDR} deployVMinPrivateSubnet=${deployVMinPrivateSubnet} deployBastionVM=${deployBastionVM} resourceTags="${resourceTags}" setupPeeredNetwork=${setupPeeredNetwork}  setupPeeredNetworkVMs=${setupPeeredNetworkVMs} vmCountinPeeredNetwork=${vmCountinPeeredNetwork} \
      --mode Complete
