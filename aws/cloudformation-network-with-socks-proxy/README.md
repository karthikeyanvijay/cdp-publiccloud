# Deploy AWS Network stack

- Ensure that your AWS CLI v2 is configured. You can do this running the command `aws sts get-caller-identity`
- Ensure that the default profile points to the right region - `aws configure get region`
- Make a copy of the `config_file.template` with the name `config_file`. Run the following command
    ```
    cp config_file.template config_file
    ```
- Update the configurations in the `config_file`. The configuration details from the file will be used in the subsequent wrapper scripts.
- Update the `cloudformation-tags.json` with the required tags.
- To create or update the stack run the command 
    ```
    ./deploy-cloudformation-stack.sh
    ```
- Once you are done, clean up the environment using the following script.
    ```
    ./delete-cloudformation-stack.sh
    ```