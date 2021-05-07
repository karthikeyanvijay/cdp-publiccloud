# Deploy AWS Network stack

## Pre-Requisites
- Ensure that your AWS CLI v2 is configured. You can do this running the command `aws sts get-caller-identity`
- Ensure that the default profile points to the right region - `aws configure get region`
- If you do not have a AWS keypair, then you can create one 
    ```
    KeyPairName=<set-name-here>

    aws ec2 create-key-pair --key-name ${KeyPairName} \
        --query 'KeyMaterial' --output text > ${KeyPairName}.pem
    ```
- Identify your public IP using the command `curl -s https://checkip.amazonaws.com`
- Decide if you want to deploy private subnets & a bastion host

## Deploy stack
- Make a copy of the `config_file.template` with the name `config_file`. Run the following command
    ```
    cp config_file.template config_file
    ```
- Update the configurations in the `config_file`. The configuration details from the file will be used in the subsequent wrapper scripts.
    * `EnvironmentPrefix` - String to be prefixed to names of AWS resource names
    * `MyIpAddressCIDR` - Public IP address identified in the Pre-Requisites step
    * `DeployPrivateSubnets` - Can be `true` or `false`
    * `DeployBastionHost` - Can be `true` or `false`
    * `SSHKeyName` - AWS SSH Keypair name created in Pre-Requisites step.
    * `LinuxAMIId` - Pick an AMI ID from [here](https://wiki.centos.org/Cloud/AWS)
- Update the `cloudformation-tags.json` file with the required tags. This IP address will be used to allow access to the bastion host.
- To create or update the stack run the command 
    ```
    ./deploy-cloudformation-stack.sh
    ```

## Cleanup
- Once you are done, clean up the environment using the following script.
    ```
    ./delete-cloudformation-stack.sh
    ```
- If you have created any SSH Keypairs, then delete it by running the following command
    ```
    KeyPairName=<set-name-here>
    aws ec2 delete-key-pair --key-name ${KeyPairName}
    ```