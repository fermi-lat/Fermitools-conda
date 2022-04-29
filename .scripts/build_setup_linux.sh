#!/bin/bash

export PYTHONUNBUFFERED=1

conda config --env --set show_channel_urls true
conda config --env --set auto_update_conda false
conda config --env --set add_pip_as_python_dependency false
# Otherwise packages that don't explicitly pin openssl in their requirements
# are forced to the newest OpenSSL version, even if their dependencies don't
# support it.
conda config --env --append aggressive_update_packages ca-certificates # add something to make sure the key exists
conda config --env --remove-key aggressive_update_packages
conda config --env --append aggressive_update_packages ca-certificates
conda config --env --append aggressive_update_packages certifi

export "CONDA_BLD_PATH=${FEEDSTOCK_ROOT}/build_artifacts"

set +u

export CPU_COUNT="${CPU_COUNT:-2}"

if [ ! -z "$CONFIG" ]; then
    if [ ! -z "$CI" ]; then
        echo "" >> ${CI_SUPPORT}/${CONFIG}.yaml
        echo "CI:" >> ${CI_SUPPORT}/${CONFIG}.yaml
        echo "- ${CI}" >> ${CI_SUPPORT}/${CONFIG}.yaml
        echo "" >> ${CI_SUPPORT}/${CONFIG}.yaml
    fi
    cat ${CI_SUPPORT}/${CONFIG}.yaml
fi

set -u

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${SCRIPT_DIR}/cross_compile_support.sh

conda info
conda config --env --show-sources
conda list --show-channel-urls
