# CDP Public Cloud scripts for AWS

- `cdp-get-aws-credentials.py` - This script gets temporary AWS credentials from ID broker. Users need to get a kerberos ticket before running this script. Usage -
    ```
    ./cdp-get-aws-credentials.py --id-broker-hostname <ID-BROKER-HOSTNAME>
    (or)
    ./cdp-get-aws-credentials.py --id-broker-hostname <ID-BROKER-HOSTNAME> --group-name <GROUP-NAME>
    ```

- `getAWSCredentials.scala` - Similar to `cdp-get-aws-credentials.py` but in scala. Can be used to access other AWS services like Secrets manager using the AWS Java SDK.  

- `get-dladmin-access.sh` - This scripts can be used to validate IAM permissions . Copy the script to the ID broker host. Modify the `role_arn` in the script to match the datalake admin role. Run the script. You can then use AWS CLI to validate the permissions. Usage -
    ```
    aws s3 -cp sample.txt s3://<bucketname-path>/<path> --profile dladmin
    ```

