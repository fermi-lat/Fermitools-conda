export condaname="fermitools"

# REPOMAN! #
# Syntax Help:
# To checkout master instead of the release tag add '--develop' after checkout
# To checkout arbitrary other refs (Tag, Branch, Commit) add them as a space
#   delimited list after 'conda' in the order of priority.
#   e.g. ScienceTools highest_priority_commit middle_priority_ref branch1 branch2 ... lowest_priority
repoman --remote-base https://github.com/fermi-lat checkout --force ScienceTools conda

# condaforge fftw is in a different spot
mkdir -p ${PREFIX}/include/fftw
ln -s ${PREFIX}/include/fftw3.* ${PREFIX}/include/fftw

# link to tinfo instead of termcap (provides the same functions)
# FIXME
#ln -s ${PREFIX}/lib/libtinfo.so ${PREFIX}/lib/libtermcap.so

# Add optimization
export CFLAGS="-O2 ${CFLAGS}"
export CXXFLAGS="-O2 ${CXXFLAGS}"

scons -C ScienceTools --site-dir=../SConsShared/site_scons --conda=${PREFIX} --use-path -j ${CPU_COUNT} --rpath="${PREFIX}/lib:${PREFIX}/lib/root:${PREFIX}/lib/${condaname}" --ccflags="${CFLAGS}" --cxxflags="${CXXFLAGS}" all

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


