export condaname="fermitools"

# REPOMAN! #
# Syntax Help:
# To checkout master instead of the release tag add '--develop' after checkout
# To checkout arbitrary other refs (Tag, Branch, Commit) add them as a space
#   delimited list after 'conda' in the order of priority.
#   e.g. ScienceTools highest_priority_commit middle_priority_ref branch1 branch2 ... lowest_priority
repoman --remote-base https://github.com/fermi-lat checkout --force --develop ScienceTools conda

# repoman --remote-base https://github.com/fermi-lat checkout --force --develop ScienceTools conda STGEN-178


# condaforge fftw is in a different spot
mkdir -p ${PREFIX}/include/fftw
if [ ! -e ${PREFIX}/include/fftw/fftw3.h ] ; then

    ln -s ${PREFIX}/include/fftw3.* ${PREFIX}/include/fftw

fi

# Add optimization
export CFLAGS="-O2 ${CFLAGS}"
export CXXFLAGS="-O2 ${CXXFLAGS}"

# Add rpaths needed for our compilation
export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib:${PREFIX}/lib/root:${PREFIX}/lib/${condaname}"

if [ "$(uname)" == "Darwin" ]; then
    
    #std=c++11 required for use with the Mac version of CLHEP in conda-forge
    export CXXFLAGS="-std=c++11 ${CXXFLAGS}" 
    echo "Compiling without openMP, not supported on Mac"
    
else
    
    # This is needed on Linux
    
    export LDFLAGS="${LDFLAGS} -fopenmp"

fi

scons -C ScienceTools \
      --site-dir=../SConsShared/site_scons \
      --conda=${PREFIX} \
      --use-path \
      -j ${CPU_COUNT} \
      --ccflags="${CFLAGS}" \
      --cxxflags="${CXXFLAGS}" \
      --ldflags="${LDFLAGS}" \
      all

# Remove the links to fftw3
rm -rf ${PREFIX}/include/fftw

# Install in a place where conda will find the ST

# Libraries
mkdir -p $PREFIX/lib/${condaname}
cp -R lib/*/* $PREFIX/lib/${condaname}

# Headers
mkdir -p $PREFIX/include/${condaname}
cp -R include/* $PREFIX/include/${condaname}

# Binaries
mkdir -p $PREFIX/bin/${condaname}
cp -R exe/*/* $PREFIX/bin/${condaname}

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

# Data
mkdir -p $PREFIX/share/${condaname}/data
cp -R data/* $PREFIX/share/${condaname}/data

# Copy also the activate and deactivate scripts
mkdir -p $PREFIX/etc/conda/activate.d
mkdir -p $PREFIX/etc/conda/deactivate.d

cp $RECIPE_DIR/activate.sh $PREFIX/etc/conda/activate.d/activate_${condaname}.sh
cp $RECIPE_DIR/deactivate.sh $PREFIX/etc/conda/deactivate.d/deactivate_${condaname}.sh


