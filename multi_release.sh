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
    (git push --tags)
    if [ ! $? ]; then
      exit $?
    fi
    cd ../
done
