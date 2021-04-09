#!/bin/bash -e

echo "# Added for development environment
# Command Aliases
Cmnd_Alias ALLOW_RESTRICTED = /hadoopfs/fs1/anaconda3/bin/conda, /bin/yum
Cmnd_Alias ALLOW_PERMISSION_CHANGE = /bin/chmod [0-7][0-7][0-7] /hadoopfs/fs1/*, /bin/chown * /hadoopfs/fs1/*

# Grant permissions
%cdp_sandbox_workers_ww ALL=(ALL) ALLOW_RESTRICTED, ALLOW_PERMISSION_CHANGE
%sandbox-default-ps-admin ALL=(ALL) ALL" > /etc/sudoers.d/custom-sudoers

echo "Adding custom sudoers complete" > /tmp/recipes-get-root-access.log
