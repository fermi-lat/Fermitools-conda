#!/bin/bash

# Original Author Joe Asercion
# Additional Author Alex Reustle
#
# Usage:
# $ multi_release TAG_VERSION TAG_MESSAGE

for f in *; do

    echo "Tagging $f..."

    pushd $f

    (git tag -f -m "$1" $2)

    if [ $? -ne 0 ]; then
      exit 128
    fi

    (git push --tags --force)

    if [ $? -ne 0 ]; then
      exit 128
    fi

    popd

done
