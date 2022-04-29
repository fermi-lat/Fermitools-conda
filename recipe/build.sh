

export condaname="fermitools"
# sed -i -E 's|("timestamp": [0-9]+)\.|\1|' $CONDA_PREFIX/conda-meta/*.json

# Add optimization
export CFLAGS="${CFLAGS}"
export CXXFLAGS="${CXXFLAGS}"

# Add rpaths needed for our compilation
export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib/${condaname}:${PREFIX}/lib:${CONDA_BUILD_SYSROOT}/usr/lib:${CONDA_BUILD_SYSROOT}/usr/local/lib:${CONDA_BUILD_SYSROOT}/usr/lib/system"


if [ "$(uname)" == "Darwin" ]; then

    # If Mac OSX then set sysroot flag (see conda_build_config.yaml)
    export CFLAGS="-isysroot ${CONDA_BUILD_SYSROOT} ${CFLAGS}"
    export CXXFLAGS="-isysroot ${CONDA_BUILD_SYSROOT} -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET} ${CXXFLAGS}"
    export LDFLAGS="${LDFLAGS} -L${CONDA_BUILD_SYSROOT}/usr/lib -headerpad_max_install_names"

fi

cmake -S . \
  -B Release \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=${PKG_CONFIG_PATH} \
  -DPKG_CONFIG_USE_CMAKE_PREFIX_PATH=On \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DPython3_EXECUTABLE="$PYTHON" \
  -DCMAKE_INSTALL_LIBDIR=lib \
  ${CMAKE_ARGS}



cmake --build Release --verbose --parallel ${CPU_COUNT:-2} \
  --target=facilities --target=py_facilities --target=test_env --target=test_time --target=test_Util


cmake --install "Release/facilities"


# Copy the activate and deactivate scripts
mkdir -p $PREFIX/etc/conda/activate.d
mkdir -p $PREFIX/etc/conda/deactivate.d

cp $RECIPE_DIR/activate.sh $PREFIX/etc/conda/activate.d/activate_${condaname}.sh
cp $RECIPE_DIR/deactivate.sh $PREFIX/etc/conda/deactivate.d/deactivate_${condaname}.sh

cp $RECIPE_DIR/activate.csh $PREFIX/etc/conda/activate.d/activate_${condaname}.csh
cp $RECIPE_DIR/deactivate.csh $PREFIX/etc/conda/deactivate.d/deactivate_${condaname}.csh
