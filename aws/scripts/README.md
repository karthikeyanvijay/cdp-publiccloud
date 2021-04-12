# ÇDP Public Cloud scripts for AWS

- `get-dladmin-access.sh` - This scripts can be used to validate IAM permissions . Copy the script to the ID broker host. Modify the `role_arn` in the script to match the datalake admin role. Run the script. You can then use AWS CLI to validate the permissions. Sample command - 
    ```
    aws s3 -cp sample.txt s3://<bucketname-path>/<path> --profile dladmin
    ```
