# -*- mode: sh -*-

export condaname="fermitools"


if [ "$(uname)" == "Darwin" ]; then
    # If Mac OSX then set sysroot flag (see conda_build_config.yaml)
    export CXXFLAGS="-mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET} ${CXXFLAGS}"
    export LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
    export TOOLCHAIN_FILE="${RECIPE_DIR}/toolchain/cross-osx.cmake"
else
    export TOOLCHAIN_FILE="${RECIPE_DIR}/toolchain/cross-linux.cmake"
fi

cmake -S . \
  -B Release \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH="${PREFIX}" \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DPython3_EXECUTABLE="${BUILD_PREFIX}/bin/python3" \
  -DCMAKE_TOOLCHAIN_FILE="${TOOLCHAIN_FILE}" \
  ${CMAKE_ARGS} \
  -DBUILD_SHARED_LIBS=OFF

cmake --build Release --parallel ${CPU_COUNT:-2} --target=install


# Copy the activate and deactivate scripts
mkdir -p $PREFIX/etc/conda/activate.d
mkdir -p $PREFIX/etc/conda/deactivate.d

cp $RECIPE_DIR/activate.sh $PREFIX/etc/conda/activate.d/activate_${condaname}.sh
cp $RECIPE_DIR/deactivate.sh $PREFIX/etc/conda/deactivate.d/deactivate_${condaname}.sh

cp $RECIPE_DIR/activate.csh $PREFIX/etc/conda/activate.d/activate_${condaname}.csh
cp $RECIPE_DIR/deactivate.csh $PREFIX/etc/conda/deactivate.d/deactivate_${condaname}.csh
