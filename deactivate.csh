#!/bin/tcsh

set condaname="fermitools"

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

unalias gtburst
unalias ModelEditor
unalias ObsSim
