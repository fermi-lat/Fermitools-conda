#!/usr/bin/env bash

source .scripts/increment_version.sh
source .scripts/version_lessthan.sh

export RECIPE_DIR=${RECIPE_DIR:- "$1"}

export META_VERSION=$(cat ${RECIPE_DIR}/meta.yaml | \
  grep '{% set version =' | awk '{ print $5 }' | tr -d \")

echo -e "Fermitools meta.yaml Version: ${META_VERSION}"

export LATEST_DEV_VERSION=$(conda search \
  -c fermi \
  -c fermi/label/dev \
  -c fermi/label/dev/osx-64 \
  -c fermi/label/dev/osx-arm64 \
  -c fermi/label/dev/linux-aarch64 \
  -c fermi/label/dev/linux-64 \
  fermitools --info --json | jq -r '.fermitools | [.[] | .version] | max')

echo -e "Fermitools latest dev Version: ${LATEST_DEV_VERSION}"

if $(version_less_than_equal ${META_VERSION} ${LATEST_DEV_VERSION}); then
  echo "META_VERSION <= LATEST_DEV_VERSION: Incrementing LATEST_DEV_VERSION patch num."
  export FERMITOOLS_VERSION="$(increment_version ${LATEST_DEV_VERSION} 2)"
else
  echo "META_VERSION > LATEST_DEV_VERSION: Not Incrementing."
  export FERMITOOLS_VERSION="${META_VERSION}"
fi

echo -e "New Fermitools Version: ${FERMITOOLS_VERSION}"
