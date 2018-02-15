
repoman --remote-base https://github.com/fermi-lat checkout --force --develop ScienceTools conda

# condaforge fftw is in a different spot
mkdir ${PREFIX}/include/fftw
ln -s ${PREFIX}/include/fftw3.* ${PREFIX}/include/fftw

# link to tinfo instead of termcap (provides the same functions)
ln -s ${PREFIX}/lib/libtinfo.so ${PREFIX}/lib/libtermcap.so

scons -C ScienceTools --site-dir=../SConsShared/site_scons --conda=${PREFIX} --use-path all -j ${CPU_COUNT}

# Remove the links to fftw3
rm -rf ${PREFIX}/include/fftw

# Install in a place where conda will find the ST

# Libraries
mkdir -p $PREFIX/lib/fermist
cp -R lib/*/* $PREFIX/lib/fermist

# Headers
mkdir -p $PREFIX/include/fermist
cp -R include/* $PREFIX/include/fermist

# Binaries
mkdir -p $PREFIX/bin/fermist
cp -R exe/*/* $PREFIX/bin/fermist

# Python packages
export sitepackagesdir=$(python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")
mkdir -p $sitepackagesdir/fermist
echo "" > $sitepackagesdir/fermist/__init__.py
cp -R python/* $sitepackagesdir/fermist
# There are python libraries that are actually under /lib, so let's
# add a .pth file so that it is not necessary to setup PYTHONPATH
# (which is discouraged by conda)
echo "$PREFIX/lib/fermist" > $sitepackagesdir/fermist.pth

# Pfiles
mkdir -p $PREFIX/share/fermist/syspfiles
cp -R syspfiles/* $PREFIX/share/fermist/syspfiles

# Data
mkdir -p $PREFIX/share/fermist/data
cp -R data/* $PREFIX/share/fermist/data

# Copy also the activate and deactivate scripts
mkdir -p $PREFIX/etc/conda/activate.d
mkdir -p $PREFIX/etc/conda/deactivate.d

cp $RECIPE_DIR/activate_fermist.sh $PREFIX/etc/conda/activate.d/activate_fermist.sh
cp $RECIPE_DIR/deactivate_fermist.sh $PREFIX/etc/conda/deactivate.d/deactivate_fermist.sh


