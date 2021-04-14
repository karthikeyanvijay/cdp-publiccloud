#!/bin/bash -e

ANACONDA_PATH=/hadoopfs/fs1/anaconda3
ANACONDA_DOWNLOAD_FILE=Anaconda3-2020.11-Linux-x86_64.sh
ANACONDA_DOWNLOAD_URL=https://repo.anaconda.com/archive/${ANACONDA_DOWNLOAD_FILE}
ANACONDA_DOWNLOAD_PATH=/tmp
USER_GROUP_ADMIN=sandbox-default-ps-admin
USER_GROUP_1=ps-sandbox-aws-env-user-group
USER_GROUP_2=cdp_sandbox_workers_ww
TAR_FILE_PATH=/hadoopfs/fs1

echo "#!/bin/bash -e
# Install Anaconda Binaries
mkdir -p ${ANACONDA_PATH}
chown root:${USER_GROUP_ADMIN} ${ANACONDA_PATH}
chmod 775 ${ANACONDA_PATH}
setfacl -d -m group:${USER_GROUP_ADMIN}:rwx ${ANACONDA_PATH}
setfacl -d -m group:${USER_GROUP_1}:rwx ${ANACONDA_PATH}
setfacl -d -m group:${USER_GROUP_2}:rwx ${ANACONDA_PATH}
wget ${ANACONDA_DOWNLOAD_URL} -P ${ANACONDA_DOWNLOAD_PATH}
chmod u+x ${ANACONDA_DOWNLOAD_PATH}/${ANACONDA_DOWNLOAD_FILE}
bash ${ANACONDA_DOWNLOAD_PATH}/${ANACONDA_DOWNLOAD_FILE} -u -b -p ${ANACONDA_PATH}
export PATH="${ANACONDA_PATH}/bin:$PATH"
conda init bash" > /tmp/setup-conda-binaries.sh

echo "#!/bin/bash -e
# Setup Python environment
export PATH=\"${ANACONDA_PATH}/bin:$PATH\"
conda create -y -n spark_python37_env python=3.7 
conda create -y -n spark_python37_env -c pandas conda-pack scikit-learn matplotlib picklable-itertools statsmodels
conda install -y -n spark_python37_env -c conda-forge pyarrow
eval \"\$(conda shell.bash hook)\"
conda activate spark_python37_env
pip install xgboost
conda pack -n spark_python37_env -f -o ${TAR_FILE_PATH}/spark_python37_env.tar.gz
conda deactivate
chown root:${USER_GROUP_ADMIN} ${TAR_FILE_PATH}/spark_python37_env.tar.gz
chmod 775 ${TAR_FILE_PATH}/spark_python37_env.tar.gz" > /tmp/setup-conda-pythonenv.sh

echo "#!/bin/bash -e
# Setup R environment 
export PATH=\"${ANACONDA_PATH}/bin:$PATH\"
conda create -y -n r_env r r-essentials r-base r-sparklyr conda-pack
conda install -y -n r_env -c conda-forge r-xgboost r-arrow
cd ${ANACONDA_PATH}/envs
eval \"\$(conda shell.bash hook)\"
conda activate r_env
conda pack -o ${TAR_FILE_PATH}/r_env.tar.gz -d ./r_env
conda deactivate
chown root:${USER_GROUP_ADMIN} ${TAR_FILE_PATH}/r_env.tar.gz
chmod 775 ${TAR_FILE_PATH}/r_env.tar.gz"> /tmp/setup-conda-renv.sh

chmod u+x /tmp/setup-conda-*.sh
bash /tmp/setup-conda-binaries.sh
bash /tmp/setup-conda-pythonenv.sh
bash /tmp/setup-conda-renv.sh

echo "Anaconda Setup complete" > /tmp/recipes-install-anaconda.log

