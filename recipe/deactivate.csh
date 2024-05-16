#!/bin/tcsh

if ($?INST_DIR) then
    unsetenv INST_DIR
endif

if ($?BASE_DIR) then
    unsetenv BASE_DIR
endif

if ($?FERMI_OLD_PFILES) then
    setenv PFILES $FERMI_OLD_PFILES
else
    unsetenv PFILES
endif

if ($?CALDB_OLD_PATH) then
    setenv CALDB $CALDB_OLD_PATH
else
    unsetenv CALDB
endif

unsetenv CALDBALIAS
unsetenv CALDBCONFIG
unsetenv CALDBROOT
unsetenv CALDB_OLD_PATH
unsetenv FERMI_OLD_PFILES
unsetenv FERMI_DIR
unsetenv FERMI_INST_DIR
unsetenv EXTFILESSYS
unsetenv GENERICSOURCESDATAPATH
unsetenv TIMING_DIR
