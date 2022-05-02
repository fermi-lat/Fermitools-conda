export FERMITOOLS_VERSION=$(cat ${RECIPE_DIR}/meta.yaml | \
  grep '{% set version =' | awk '{ print $5 }' | tr -d \")

echo -e "Fermitools Version: ${FERMITOOLS_VERSION}"

export BUILD_NUMBER="${BUILD_NUMBER:-$(conda search \
  -c fermi/label/dev/osx-64 \
  -c fermi/label/dev/osx-arm64 \
  -c fermi/label/dev/linux-aarch64 \
  -c fermi/label/dev/linux-64 \
  fermitools=${FERMITOOLS_VERSION} --info --json | jq -r '.fermitools | [.[] | .build_number] | max + 1')}"

echo -e "Version Build Number: ${BUILD_NUMBER}"
