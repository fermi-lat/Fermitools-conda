
repoman --remote-base https://github.com/fermi-lat checkout --force --develop ScienceTools conda

# condaforge fftw is in a different spot
mkdir ${PREFIX}/include/fftw
ln -s ${PREFIX}/include/fftw3.* ${PREFIX}/include/fftw



scons -C ScienceTools --site-dir=../SConsShared/site_scons --conda=${PREFIX} \
  --with-cxx=`which gcc`\
  --with-cc= `which gcc`\
  all


# link to tinfo instead of termcap (provides the same functions)
# add
