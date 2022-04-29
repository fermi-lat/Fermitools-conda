#!/usr/bin/env bash

# -*- mode: jinja-shell -*-

source .scripts/logging_utils.sh

set -xe

MINIFORGE_HOME=${MINIFORGE_HOME:-${HOME}/miniforge3}

( startgroup "Installing a fresh version of Miniforge" ) 2> /dev/null

MINIFORGE_URL="https://github.com/conda-forge/miniforge/releases/latest/download"
MINIFORGE_FILE="Mambaforge-MacOSX-$(uname -m).sh"
curl -L -O "${MINIFORGE_URL}/${MINIFORGE_FILE}"
rm -rf ${MINIFORGE_HOME}
bash $MINIFORGE_FILE -b -p ${MINIFORGE_HOME}

( endgroup "Installing a fresh version of Miniforge" ) 2> /dev/null

( startgroup "Configuring conda" ) 2> /dev/null

source ${MINIFORGE_HOME}/etc/profile.d/conda.sh
conda activate base

echo -e "\n\nInstalling conda-build and boa."
mamba install --update-specs --quiet --yes --channel conda-forge conda-build pip boa
mamba update --update-specs --yes --quiet --channel conda-forge conda-build pip boa


echo -e "\n\nSetting up the condarc and mangling the compiler."
conda config --env --remove channels defaults
conda config --env --add channels fermi conda-forge

echo -e "\n\nMangling homebrew in the CI to avoid conflicts."
source .scripts/mangle_homebrew.sh

echo -e "\n\nRunning the build setup script."
source .scripts/build_setup_osx.sh

( endgroup "Configuring conda" ) 2> /dev/null

conda mambabuild ./recipe -m ./.ci_support/${CONFIG}.yaml

# ( startgroup "Validating outputs" ) 2> /dev/null
#
# validate_recipe_outputs "${FEEDSTOCK_NAME}"
#
# ( endgroup "Validating outputs" ) 2> /dev/null
#
# ( startgroup "Uploading packages" ) 2> /dev/null
#
# if [[ "${UPLOAD_PACKAGES}" != "False" ]] && [[ "${IS_PR_BUILD}" == "False" ]]; then
#   upload_package --validate --feedstock-name="${FEEDSTOCK_NAME}" ./ ./recipe ./.ci_support/${CONFIG}.yaml
# fi
#
# ( endgroup "Uploading packages" ) 2> /dev/null
