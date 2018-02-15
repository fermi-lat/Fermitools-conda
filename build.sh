
repoman --remote-base https://github.com/fermi-lat checkout --force --develop ScienceTools conda

scons -C ScienceTools --site-dir=../SConsShared/site_scons --conda=${PREFIX} all
