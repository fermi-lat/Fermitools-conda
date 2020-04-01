export condaname="fermitools"
export LC_ALL=en_US.utf8
export LANG=en_US.utf8

# REPOMAN! #
# Syntax Help:
# To checkout master instead of the release tag add '--develop' after checkout
# To checkout arbitrary other refs (Tag, Branch, Commit) add them as a space
#   delimited list after 'conda' in the order of priority.
#   e.g. ScienceTools highest_priority_commit middle_priority_ref branch1 branch2 ... lowest_priority
repoman --remote-base https://github.com/fermi-lat checkout --force --develop ScienceTools python3_updates conda 
# repoman --remote-base https://github.com/fermi-lat checkout --force --develop ScienceTools conda STGEN-182


# condaforge fftw is in a different spot
mkdir -p ${PREFIX}/include/fftw
if [ ! -e ${PREFIX}/include/fftw/fftw3.h ] ; then

    ln -s ${PREFIX}/include/fftw3.* ${PREFIX}/include/fftw

fi

#CXXFLAGS=${CXXFLAGS//c++17/c++11}

# Add optimization
export CFLAGS="-O2 ${CFLAGS}"
export CXXFLAGS="-O2 ${CXXFLAGS}"

# Add rpaths needed for our compilation
export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib,-rpath,${PREFIX}/lib/root,-rpath,${PREFIX}/lib/${condaname}"

if [ "$(uname)" == "Darwin" ]; then
    
    #std=c++11 required for use with the Mac version of CLHEP in conda-forge
    export CFLAGS="${CFLAGS} -isysroot ${CONDA_BUILD_SYSROOT} -mmacosx-version-min=10.9"
    export CXXFLAGS="${CXXFLAGS} -isysroot ${CONDA_BUILD_SYSROOT} -mmacosx-version-min=10.9" 
    export LDFLAGS="${LDFLAGS} -headerpad_max_install_names -fopenmp"
    echo "Compiling without openMP, not supported on Mac"
    
else
    
    # This is needed on Linux
    export CXXFLAGS="${CXXFLAGS}" 
    export LDFLAGS="${LDFLAGS} -fopenmp"

fi

#ln -s ${cc} ${PREFIX}/bin/gcc

#ln -s ${CXX} ${PREFIX}/bin/g++

scons -C ScienceTools \
      --site-dir=../SConsShared/site_scons \
      --conda=${PREFIX} \
      --use-path \
      -j ${CPU_COUNT} \
      --with-cc="${CC}" \
      --with-cxx="${CXX}" \
      --ccflags="${CFLAGS}" \
      --cxxflags="${CXXFLAGS}" \
      --ldflags="${LDFLAGS}" \
      all

rm -rf ${PREFIX}/bin/gcc

rm -rf ${PREFIX}/bin/g++

# Remove the links to fftw3
rm -rf ${PREFIX}/include/fftw

# Install in a place where conda will find the ST

# Libraries
mkdir -p $PREFIX/lib/${condaname}
if [ -d "lib/debianstretch/sid-x86_64-64bit-gcc73" ]; then
    echo "Subdirectory Found! (Lib)"
    pwd 
    ls lib/
    ls lib/debianstretch/
    ls lib/debianstretch/sid-x86_64-64bit-gcc73/
    cp -R lib/*/*/* $PREFIX/lib/${condaname}
else
    echo "Subdirectory Not Found! (Lib)"
    echo "PWD:"
    pwd
    echo "ls:"
    ls
    echo "ls lib/"
    ls lib/
    cp -R lib/*/* $PREFIX/lib/${condaname}
fi

# Headers
mkdir -p $PREFIX/include/${condaname}
if [ -d "include/debianstretch/sid-x86_64-64bit-gcc73" ]; then
    echo "Subdirectory Found! (Include)"
    cp -R include/*/* $PREFIX/include/${condaname}
else
    echo "Subdirectory Not Found! (Include)"
    cp -R include/* $PREFIX/include/${condaname}
fi

# Binaries
mkdir -p $PREFIX/bin/${condaname}
if [ -d "exe/debianstretch/sid-x86_64-64bit-gcc73" ]; then
    echo "Subdirectory Found! (bin)"
    cp -R exe/*/*/* $PREFIX/bin/${condaname}
else
    echo "Subdirectory Not Found! (bin)"
    cp -R exe/*/* $PREFIX/bin/${condaname}
fi

# Python packages
# Figure out the path to the site-package directory
export sitepackagesdir=$(python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")
echo "sitepackagesdir =" $sitepackagesdir
export sitepackagesdir=$PREFIX/lib/python3.7/site-packages
echo "sitepackagesdir =" $sitepackagesdir
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
echo ${condaname}.pth ":"
cat $sitepackagesdir/${condaname}.pth

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
