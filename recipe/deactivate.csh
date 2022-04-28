#!/bin/tcsh

if ($?INST_DIR) then
    unset INST_DIR
endif

if ($?BASE_DIR) then
    unset BASE_DIR
endif

if ($?FERMI_OLD_PATH) then
    setenv PATH $FERMI_OLD_PATH
    unset FERMI_OLD_PATH
endif

if ($?FERMI_OLD_PFILES) then
    setenv PFILES $FERMI_OLD_PFILES
else
    unset PFILES
endif

if ($?CALDB_OLD_PATH) then
    setenv CALDB $CALDB_OLD_PATH
else
    unset CALDB
endif

unset CALDBALIAS
unset CALDBCONFIG
unset CALDBROOT
