export VERSION=$(cat ${RECIPE_DIR}/meta.yaml | shyaml get-value version.0 0)
export BUILD_NUMBER="${BUILD_NUMBER:-$(conda search \
  -c fermi/label/dev/osx-64 \
  -c fermi/label/dev/osx-arm64 \
  -c fermi/label/dev/linux-aarch64 \
  -c fermi/label/dev/linux-64 \
  fermitools=${VERSION} --info --json | jq -r '.fermitools | max .build_number+1')}"
#
# conda search -c fermi/label/dev/osx-64 -c fermi/label/dev/osx-arm64 -c fermi/label/dev/linux-aarch64 -c fermi/label/dev/linux-64 fermitools=2.1.0 --info --json | jq -r '.fermitools | max .build_number+1'
