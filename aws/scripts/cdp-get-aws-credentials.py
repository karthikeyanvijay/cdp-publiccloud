#!/usr/bin/env python3
import sys
import requests
import os
from argparse import ArgumentParser
from requests_kerberos import HTTPKerberosAuth
import urllib3

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Parse Arguments
parser = ArgumentParser(description="Arguments for the script")
paramRequiredGrp = parser.add_argument_group("paramRequiredGrp", "Mandatory arguments")
paramRequiredGrp.add_argument(
    "--id-broker-hostname",
    required=True,
    action="store",
    dest="id_broker_host",
    help="ID Broker Hostname",
)

paramOptionalGrp = parser.add_argument_group("paramOptionalGrp", "Optional arguments")
paramOptionalGrp.add_argument(
    "--group-name",
    required=False,
    action="store",
    dest="group_name",
    default="",
    help="If credentials are required for a specify group name here",
)
args = parser.parse_args()


r = requests.get(
    "https://" + args.id_broker_host + ":8444/gateway/dt/knoxtoken/api/v1/token",
    auth=HTTPKerberosAuth(),
    verify=False,
)
if r.status_code != 200:
    print('Unable to get token from ID Broker. Get a kerberos ticket before executing this script. HTTP resonse code: '+ str(r.status_code))
    sys.exit(1)

if args.group_name == "":
    # Get credentials for default group
    url = (
        "https://"
        + args.id_broker_host
        + ":8444/gateway/aws-cab/cab/api/v1/credentials"
    )
else:
    # Get credentials specific to group
    url = (
        "https://"
        + args.id_broker_host
        + ":8444/gateway/aws-cab/cab/api/v1/credentials/group/"
        + args.group_name
    )

headers = {
    "Authorization": "Bearer " + r.json()["access_token"],
    "cache-control": "no-cache",
}

# Parse response to get the credentials
response = requests.request("GET", url, headers=headers, verify=False)
if response.status_code != 200:
    print('Unable to get credentials from ID Broker. HTTP resonse code: '+ str(response.status_code))
    sys.exit(1)

AWS_ACCESS_KEY = response.json()["Credentials"]["AccessKeyId"]
AWS_SECRET_KEY = response.json()["Credentials"]["SecretAccessKey"]
AWS_SESSION_TOKEN = response.json()["Credentials"]["SessionToken"]

# print("ACCESS_KEY:"+ ACCESS_KEY)
# print("SECRET_KEY:"+ SECRET_KEY)
# print("SESSION_TOKEN:"+ SESSION_TOKEN)

# Export credentials to default profile
os.system("aws configure set aws_access_key_id " + AWS_ACCESS_KEY)
os.system("aws configure set aws_secret_access_key " + AWS_SECRET_KEY)
os.system("aws configure set aws_session_token " + AWS_SESSION_TOKEN)
print("Temporary credentials exported to default profile. You can now use AWS CLI")
