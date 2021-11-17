export condaname="fermitools"

# REPOMAN! #
repoman --remote-base https://github.com/fermi-lat checkout-list packageList.txt

# Add optimization
export CFLAGS="${CFLAGS}"
export CXXFLAGS="-std=c++17 ${CXXFLAGS}"

# Add rpaths needed for our compilation
export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib/${condaname}:${PREFIX}/lib"

if [ "$(uname)" == "Darwin" ]; then

    # If Mac OSX then set sysroot flag (see conda_build_config.yaml)
    export CFLAGS="-isysroot ${CONDA_BUILD_SYSROOT} ${CFLAGS}"
    export CXXFLAGS="-isysroot ${CONDA_BUILD_SYSROOT} -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET} ${CXXFLAGS}"
    export LDFLAGS="${LDFLAGS} -headerpad_max_install_names"

fi

if scons -C ScienceTools \
      --site-dir=../SConsShared/site_scons \
      --conda=${CONDA_PREFIX} \
      --use-path \
      -j ${CPU_COUNT} \
      --with-cc="${CC}" \
      --with-cxx="${CXX}" \
      --ccflags="${CFLAGS}" \
      --cxxflags="${CXXFLAGS}" \
      --ldflags="${LDFLAGS}" \
      --compile-opt \
      all; then
  echo "scons build successful."
else
  find . -name config.log
  cat config.log
  exit 1
fi

# Install in a place where conda will find the ST

# Libraries
mkdir -p $PREFIX/lib/${condaname}
if [ -d "lib/debianstretch/sid-x86_64-64bit-gcc75-Optimized" ]; then
    echo "Subdirectory Found! (Lib)"
    pwd
    ls lib/
    ls lib/debianstretch/
    ls lib/debianstretch/sid-x86_64-64bit-gcc75-Optimized/
    cp -R lib/*/*/* $PREFIX/lib/${condaname}
else
    echo "Subdirectory Not Found! (Lib)"
    cp -R lib/*/* $PREFIX/lib/${condaname}
fi

# Headers
mkdir -p $PREFIX/include/${condaname}
if [ -d "include/debianstretch/sid-x86_64-64bit-gcc75-Optimized" ]; then
    echo "Subdirectory Found! (Include)"
    cp -R include/*/* $PREFIX/include/${condaname}
else
    echo "Subdirectory Not Found! (Include)"
    cp -R include/* $PREFIX/include/${condaname}
fi

# Binaries
mkdir -p $PREFIX/bin/${condaname}
if [ -d "exe/debianstretch/sid-x86_64-64bit-gcc75-Optimized" ]; then
    echo "Subdirectory Found! (bin)"
    cp -R exe/*/*/* $PREFIX/bin/${condaname}
else
    echo "Subdirectory Not Found! (bin)"
    cp -R exe/*/* $PREFIX/bin/${condaname}
fi

# Python packages
# Figure out the path to the site-package directory
export sitepackagesdir=$(python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")
# Create our package there
mkdir -p $sitepackagesdir/${condaname}
# Making an empty __init__.py makes our directory a python package
echo "" > $sitepackagesdir/${condaname}/__init__.py
# Copy all our stuff there
cp -R python/* $sitepackagesdir/${condaname}
# There are python libraries that are actually under /lib, so let's
# add a .pth file so that it is not necessary to setup PYTHONPATH
# (which is discouraged by conda)
echo "$PREFIX/lib/${condaname}" > $sitepackagesdir/${condaname}.pth
# In order to support things like "import UnbinnedAnalysis" instead of
# "from fermitools import UnbinnedAnalysis" we need to
# also add the path to the fermitools package
echo "${sitepackagesdir}/fermitools" >> $sitepackagesdir/${condaname}.pth

# Pfiles
mkdir -p $PREFIX/share/${condaname}/syspfiles
cp -R syspfiles/* $PREFIX/share/${condaname}/syspfiles

# Xml
mkdir -p $PREFIX/share/${condaname}/xml
cp -R xml/* $PREFIX/share/${condaname}/xml

# Data
mkdir -p $PREFIX/share/${condaname}/data
cp -R data/* $PREFIX/share/${condaname}/data

# fhelp
mkdir -p $PREFIX/share/${condaname}/help
cp -R fermitools-fhelp/* $PREFIX/share/${condaname}/help
rm -f $PREFIX/share/${condaname}/help/README.md #Remove the git repo README

# Copy also the activate and deactivate scripts
mkdir -p $PREFIX/etc/conda/activate.d
mkdir -p $PREFIX/etc/conda/deactivate.d

cp $RECIPE_DIR/activate.sh $PREFIX/etc/conda/activate.d/activate_${condaname}.sh
cp $RECIPE_DIR/deactivate.sh $PREFIX/etc/conda/deactivate.d/deactivate_${condaname}.sh

cp $RECIPE_DIR/activate.csh $PREFIX/etc/conda/activate.d/activate_${condaname}.csh
cp $RECIPE_DIR/deactivate.csh $PREFIX/etc/conda/deactivate.d/deactivate_${condaname}.csh
