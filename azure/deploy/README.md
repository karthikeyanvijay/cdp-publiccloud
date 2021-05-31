# CDP
Use the following steps to deploy the environment. [CDP CLI](https://docs.cloudera.com/cdp/latest/cli/topics/mc-installing-cdp-client.html) should already be configured to use the following steps.

## Environment & Datalake creation
* Create the credential to be used through the CDP control plane.
* Create Environment
    ```
    cdp environments create-azure-environment  --cli-input-json file://environment.json
    ```
* Assign ID Broker mappings
    ```
    cdp environments set-id-broker-mappings --cli-input-json file://environment-id-broker-mappings.json
    (or)
    cdp environments set-id-broker-mappings --environment-name vkacdpdev \
    --data-access-role "arn:aws:iam::123456789012:role/vkarthikeyan-cdp-datalake-admin-role" \
    --ranger-audit-role "arn:aws:iam::123456789012:role/vkarthikeyan-cdp-ranger-audit-role" \
    --set-empty-mappings
    ```
* Create Datalake
    ```
    cdp datalake create-azure-datalake  --cli-input-json file://datalake.json
    ```
* Grant permissions
    ```
    env_crn=`cdp environments describe-environment --environment-name cdpvkazure | jq -r .environment.crn`

    # Grant access to Admins
    for role in `cdp iam list-resource-roles | jq -r .resourceRoles[].crn`
    do
    cdp iam assign-group-resource-role  \
        --group-name ps-sandbox-aws-env-user-group   \
        --resource-role-crn $role   \
        --resource-crn $env_crn
    done

    # Grant access to users
    for role in `cdp iam list-resource-roles | jq -r .resourceRoles[].crn | grep 'User$'`
    do
    cdp iam assign-group-resource-role  \
        --group-name sandbox-default-ps-admin   \
        --resource-role-crn $role   \
        --resource-crn $env_crn
    done
    ```

## Create users
* Create a machine user `cdp iam create-machine-user --machine-user-name devuser`
* Assign previleges
    ```
    machineusername="devuser"
    envname="vkacdpdev"

    env_crn=`cdp environments describe-environment --environment-name $envname | jq -r .environment.crn`
    envuserrole=`cdp iam list-resource-roles | jq -r .resourceRoles[].crn | grep 'EnvironmentUser$'`

    cdp iam assign-machine-user-resource-role \
        --machine-user-name $machineusername \
        --resource-role-crn $envuserrole   \
        --resource-crn $env_crn
    deuserrole=`cdp iam list-resource-roles | jq -r .resourceRoles[].crn | grep 'DEUser$'` 
    cdp iam assign-machine-user-resource-role \
        --machine-user-name $machineusername \
        --resource-role-crn $deuserrole   \
        --resource-crn $env_crn

    # Set workload password through Control plane (Do not use the following command)
    machineusercrn=`cdp iam list-machine-users --machine-user-names $machineusername | jq .machineUsers[].crn`
    cdp iam set-workload-password --actor-crn $machineusercrn --password BadPass#1
    ```

## Datahub
* To create a datahub cluster, run the following command
    ```
    cdp datahub create-aws-cluster --cli-input-json file://datahub-etl.json

    ```

## Cloudera Data Warehouse
* 
```
cdp dw create-cluster --cli-input-json file://cdw-cluster.json
```

## Ops DB
* 
```
cdp opdb create-database --cli-input-json file://opdb-database.json
```

## Cloudera Data Engineering
* Enable service
    ```
    cdp de enable-service --cli-input-json file://cde-service.json
    ```
* Create Virtual cluster with on-demand instances. (Timeout issues when deploying through CLI. Deployed manually)
    ```
    cdp de create-vc --cli-input-json file://cde-virtual-cluster-ondemand.json
    ```
