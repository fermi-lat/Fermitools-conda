#!/bin/bash

# Original Author Joe Asercion
# Additional Author Alex Reustle
#
# Usage:
# $ multi_release TAG_VERSION TAG_MESSAGE

for f in *; do

    echo "Tagging $f..."

    cd $f

    (git tag -m "$2" $1)

    if [ $? -ne 0 ]; then
      exit 128
    fi

    (git push --tags)

    if [ $? -ne 0 ]; then
      exit 128
    fi

    cd ../

done
