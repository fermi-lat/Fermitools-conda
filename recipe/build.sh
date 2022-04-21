

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
  -DCMAKE_INSTALL_PREFIX=${PREFIX}


cmake --build Release --parallel --target=install

# # Install in a place where conda will find the ST

# # There are python libraries that are actually under /lib, so let's
# # add a .pth file so that it is not necessary to setup PYTHONPATH
# # (which is discouraged by conda)
# echo "$PREFIX/lib/${condaname}" > $sitepackagesdir/${condaname}.pth
# # In order to support things like "import UnbinnedAnalysis" instead of
# # "from fermitools import UnbinnedAnalysis" we need to
# # also add the path to the fermitools package
# echo "${sitepackagesdir}/fermitools" >> $sitepackagesdir/${condaname}.pth
#
# # Pfiles
# mkdir -p $PREFIX/share/${condaname}/syspfiles
# cp -R syspfiles/* $PREFIX/share/${condaname}/syspfiles
#
# # Xml
# mkdir -p $PREFIX/share/${condaname}/xml
# cp -R xml/* $PREFIX/share/${condaname}/xml
#
# # Data
# mkdir -p $PREFIX/share/${condaname}/data
# cp -R data/* $PREFIX/share/${condaname}/data
#
# # fhelp
# mkdir -p $PREFIX/share/${condaname}/help
# cp -R fermitools-fhelp/* $PREFIX/share/${condaname}/help
# rm -f $PREFIX/share/${condaname}/help/README.md #Remove the git repo README
#
# # Copy also the activate and deactivate scripts
# mkdir -p $PREFIX/etc/conda/activate.d
# mkdir -p $PREFIX/etc/conda/deactivate.d
#
# cp $RECIPE_DIR/activate.sh $PREFIX/etc/conda/activate.d/activate_${condaname}.sh
# cp $RECIPE_DIR/deactivate.sh $PREFIX/etc/conda/deactivate.d/deactivate_${condaname}.sh
#
# cp $RECIPE_DIR/activate.csh $PREFIX/etc/conda/activate.d/activate_${condaname}.csh
# cp $RECIPE_DIR/deactivate.csh $PREFIX/etc/conda/deactivate.d/deactivate_${condaname}.csh
