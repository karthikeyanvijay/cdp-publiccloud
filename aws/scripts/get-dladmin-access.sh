#!/bin/bash
# Script to get access to datalake admin role

unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
role_arn='arn:aws:iam::123456789012:role/customer-cdp-dev-datalake-admin-role'
role_session_name='session1'
profile_name='dladmin'

temp_role=$(aws sts assume-role \
     --role-arn $role_arn \
     --role-session-name $role_session_name)

export AWS_ACCESS_KEY_ID=$(echo $temp_role | jq -r .Credentials.AccessKeyId)
export AWS_SECRET_ACCESS_KEY=$(echo $temp_role | jq -r .Credentials.SecretAccessKey)
export AWS_SESSION_TOKEN=$(echo $temp_role | jq -r .Credentials.SessionToken)

aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID --profile $profile_name
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY --profile $profile_name
aws configure set aws_session_token $AWS_SESSION_TOKEN --profile $profile_name

echo "Use profile ${profile_name} in AWS CLI get access to datalake admin role"
