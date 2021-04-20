#!/bin/bash
# This script exports the temporary AWS credential to the default profile
# Steps from https://aws.amazon.com/premiumsupport/knowledge-center/aws-cli-call-store-saml-credentials

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 \"arn:aws:iam::123456789012:role/role_name\" \"arn:aws:iam::123456789012:saml-provider/saml_provider_name\" <saml_response_file>"
    exit 1
fi

role_arn=$1
principal_arn=$2
saml_response_file=$3

# Get credentials from SAML response
aws sts assume-role-with-saml --role-arn $role_arn --principal-arn $principal_arn --saml-assertion file://${saml_response_file} | awk -F:  '
                BEGIN { RS = "[,{}]" ; print "[default]"}
                /:/{ gsub(/"/, "", $2) }
                /AccessKeyId/{ print "aws_access_key_id = " $2 }
                /SecretAccessKey/{ print "aws_secret_access_key = " $2 }
                /SessionToken/{ print "aws_session_token = " $2 }' > ~/.aws/credentials
