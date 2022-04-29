#!/usr/bin/env bash

# -*- mode: jinja-shell -*-

set -xeuo pipefail
export FEEDSTOCK_ROOT="${FEEDSTOCK_ROOT:-/home/conda/feedstock_root}"
source ${FEEDSTOCK_ROOT}/.scripts/logging_utils.sh


( endgroup "Start Docker" ) 2> /dev/null

( startgroup "Configuring conda" ) 2> /dev/null

export PYTHONUNBUFFERED=1
export RECIPE_ROOT="${RECIPE_ROOT:-/home/conda/recipe_root}"
export SCRIPT_DIR="${FEEDSTOCK_ROOT}/.scripts"
export CI_SUPPORT="${FEEDSTOCK_ROOT}/.ci_support"
export CONFIG_FILE="${CI_SUPPORT}/${CONFIG}.yaml"

cat >~/.condarc <<CONDARC

conda-build:
 root-dir: ${FEEDSTOCK_ROOT}/build_artifacts

CONDARC

echo -e "\n\nInstalling conda-build and boa."
mamba install --update-specs --quiet --yes --channel conda-forge \
  conda-build pip boa jq conda\>=4.3 conda-env anaconda-client shyaml requests \
  ruamel_yaml
mamba update --update-specs --yes --quiet --channel conda-forge \
  conda-build pip boa jq conda\>=4.3 conda-env anaconda-client shyaml requests \
  ruamel_yaml

echo -e "\n\nRunning the build setup script."
source ${SCRIPT_DIR}/build_setup_linux.sh

( endgroup "Configuring conda" ) 2> /dev/null

conda mambabuild -c fermi -c conda-forge "${RECIPE_ROOT}" -m "${CI_SUPPORT}/${CONFIG}.yaml" 

# ( startgroup "Validating outputs" ) 2> /dev/null
#
# validate_recipe_outputs "${FEEDSTOCK_NAME}"
#
# ( endgroup "Validating outputs" ) 2> /dev/null
#
# ( startgroup "Uploading packages" ) 2> /dev/null
#
# if [[ "${UPLOAD_PACKAGES}" != "False" ]] && [[ "${IS_PR_BUILD}" == "False" ]]; then
#     upload_package --validate --feedstock-name="${FEEDSTOCK_NAME}"  "${FEEDSTOCK_ROOT}" "${RECIPE_ROOT}" "${CONFIG_FILE}"
# fi
#
# ( endgroup "Uploading packages" ) 2> /dev/null

( startgroup "Final checks" ) 2> /dev/null

touch "${FEEDSTOCK_ROOT}/build_artifacts/conda-forge-build-done-${CONFIG}"
