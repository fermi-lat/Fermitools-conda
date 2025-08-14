# -*- mode: sh -*-

export condaname="fermitools"


if [ "$(uname)" == "Darwin" ]; then
    # If Mac OSX then set sysroot flag (see conda_build_config.yaml)
    export CXXFLAGS="-mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET} -std=c++17 ${CXXFLAGS}" 
    #echo "CXX FLAGS:"
    #echo $CXXFLAGS
    # -I/Applications/Xcode_15.4.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk/usr/include/c++/4.2.1/"
    export LDFLAGS="${LDFLAGS}  -lstdc++ -headerpad_max_install_names"
    #echo "LD FLAGS:"
    #echo $LDFLAGS
    # -L/Applications/Xcode_15.4.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk/usr/include/c++/4.2.1/
    export TOOLCHAIN_FILE="$RECIPE_DIR/toolchain/cross-osx.cmake"
    # echo "Commandline tools:" 
    # ls /Applications/Xcode_15.4.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk/usr/include/c++/4.2.1
    # export CC="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang"
    # export CXX="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang++"
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
echo "PREFIX: "
echo $PREFIX

######

#echo "SDK dir:"
#ls /Applications/Xcode_15.4.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/

echo "Install conda-forge cxx compiler directly:"
conda install --yes conda-forge::cxx-compiler

#echo "g++ build.sh version:"
#g++ --version

cmake -S . \
  -B Release \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN_FILE \
  -DCMAKE_PREFIX_PATH="${PREFIX}" \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DPython3_EXECUTABLE="${BUILD_PREFIX}/bin/python3" \
  -DPython3_NumPy_INCLUDE_DIR="${SP_DIR}/numpy/core/include" \
  ${CMAKE_ARGS}

#cmake --build Release --clean-first --parallel ${CPU_COUNT:-2} --target=install 
cmake --build Release --clean-first --target=install --verbose
# Copy the activate and deactivate scripts
mkdir -p $PREFIX/etc/conda/activate.d
mkdir -p $PREFIX/etc/conda/deactivate.d

cp $RECIPE_DIR/activate.sh $PREFIX/etc/conda/activate.d/activate_${condaname}.sh
cp $RECIPE_DIR/deactivate.sh $PREFIX/etc/conda/deactivate.d/deactivate_${condaname}.sh

cp $RECIPE_DIR/activate.csh $PREFIX/etc/conda/activate.d/activate_${condaname}.csh
cp $RECIPE_DIR/deactivate.csh $PREFIX/etc/conda/deactivate.d/deactivate_${condaname}.csh

# Delete the cmake build directory
rm -rf Release 

# Determine which conda env we are in. If it's base than we could "exit" conda.
echo "Conda env $CONDA_PREFIX"
# activate.sh:export INST_DIR=$CONDA_PREFIX/share/${condaname}
echo "List Conda env"
conda env list --json
# Play it safe
conda deactivate
# Don't do any conda clean here
# conda clean -ap
