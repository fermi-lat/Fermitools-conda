# -*- mode: sh -*-

export condaname="fermitools"


if [ "$(uname)" == "Darwin" ]; then
    # If Mac OSX then set sysroot flag (see conda_build_config.yaml)
    export CXXFLAGS="-mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET} ${CXXFLAGS} -I/Applications/Xcode_15.4.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk/usr/include/c++/v1/"
    export LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
    export TOOLCHAIN_FILE="${RECIPE_DIR}/toolchain/cross-osx.cmake"
    echo "Commandline tools:" 
    ls /Applications/Xcode_15.4.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk/usr/include/c++
else
    export TOOLCHAIN_FILE="${RECIPE_DIR}/toolchain/cross-linux.cmake"
fi

######
echo "PYTHONPATH: "
echo $PYTHONPATH
echo "which python: "
which python
echo "python version: "
python --version
######

cmake -S . \
  -B Release \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH="${PREFIX}" \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DPython3_EXECUTABLE="${BUILD_PREFIX}/bin/python3" \
  -DPython3_NumPy_INCLUDE_DIR="${SP_DIR}/numpy/core/include" \
  -DCMAKE_TOOLCHAIN_FILE="${TOOLCHAIN_FILE}" \
  ${CMAKE_ARGS}

cmake --build Release --parallel ${CPU_COUNT:-2} --target=install


# Copy the activate and deactivate scripts
mkdir -p $PREFIX/etc/conda/activate.d
mkdir -p $PREFIX/etc/conda/deactivate.d

cp $RECIPE_DIR/activate.sh $PREFIX/etc/conda/activate.d/activate_${condaname}.sh
cp $RECIPE_DIR/deactivate.sh $PREFIX/etc/conda/deactivate.d/deactivate_${condaname}.sh

cp $RECIPE_DIR/activate.csh $PREFIX/etc/conda/activate.d/activate_${condaname}.csh
cp $RECIPE_DIR/deactivate.csh $PREFIX/etc/conda/deactivate.d/deactivate_${condaname}.csh
