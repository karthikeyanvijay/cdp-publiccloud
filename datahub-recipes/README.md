# Cloudera Data Hub receipes
This repo is a collection of CDP Public Cloud Data Hub receipe scripts. The scripts can generally be used as a standalone script on Cloudera Private Cloud Base cluster.

* [Setup root Access on Datahub](get-root-access.sh) - Can be used a `post-cluster-install` recipe to grant limited root access to developers on gateway host. Edit the group names & the command set before deploying 
* [Setup Conda - Python & R environments](setup-anaconda.sh) - Can be used a `post-cluster-install` recipe to install Anaconda3 on gateway host. Edit the parameters in the beginning section of the script to deploy 