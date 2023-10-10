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
mamba install --update-specs --quiet --yes --channel conda-forge \
  conda-build pip boa jq conda\>=4.3 conda-env anaconda-client shyaml requests \
  ruamel_yaml git cctools=949.*
mamba update --update-specs --yes --quiet --channel conda-forge \
  conda-build pip boa jq conda\>=4.3 conda-env anaconda-client shyaml requests \
  ruamel_yaml git cctools=949.*

# echo -e "\n\nMangling homebrew in the CI to avoid conflicts."
# source .scripts/mangle_homebrew.sh

echo -e "\n\nRunning the build setup script."
source .scripts/build_setup_osx.sh

( endgroup "Configuring conda" ) 2> /dev/null

( startgroup "Building Fermitools" ) 2> /dev/null

if [[ "${HOST_PLATFORM}" != "${BUILD_PLATFORM}" ]]; then
    EXTRA_CB_OPTIONS="${EXTRA_CB_OPTIONS:-} --no-test"
fi

######
echo "PYTHONPATH: "
echo $PYTHONPATH
echo "which python: "
which python

conda mambabuild \
  -c fermi \
  -c conda-forge \
  ./recipe \
  -m ./.ci_support/${CONFIG}.yaml \
  ${EXTRA_CB_OPTIONS:-} 

( endgroup "Building Fermitools" ) 2> /dev/null

( startgroup "Uploading packages" ) 2> /dev/null

if [[ "${UPLOAD_PACKAGES}" != "False" ]]; then

  echo -e "Uploading Packages"

  find ${MINIFORGE_HOME}/conda-bld -name "fermitools-*.tar.bz2" 

  find ${MINIFORGE_HOME}/conda-bld -name "fermitools-*.tar.bz2" -exec anaconda -v -t ${ANACONDA_TOKEN} upload -u fermi --label=dev --no-progress --force \{\} \;

  echo -e "$?"
else
  echo -e "Skipping Upload."
fi

( endgroup "Uploading packages" ) 2> /dev/null

echo -e "Uploaded ${FERMITOOLS_VERSION}"
