export VERSION=$(cat ${RECIPE_DIR}/meta.yaml | \
  grep '{% set version =' | awk '{ print $5 }' | tr -d \")

export BUILD_NUMBER="${BUILD_NUMBER:-$(conda search \
  -c fermi/label/dev/osx-64 \
  -c fermi/label/dev/osx-arm64 \
  -c fermi/label/dev/linux-aarch64 \
  -c fermi/label/dev/linux-64 \
  fermitools=${VERSION} --info --json | jq -r '.fermitools | max .build_number+1')}"
