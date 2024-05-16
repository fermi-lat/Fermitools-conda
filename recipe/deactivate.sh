#!/bin/bash

if [ -z ${INST_DIR+x} ]; then : ; else unset INST_DIR; fi
if [ -z ${BASE_DIR+x} ]; then : ; else unset BASE_DIR; fi

if [ -z ${FERMI_OLD_PFILES} ]; then
    
    # PFILES was not set before activation
    unset PFILES

else
    
    # Restore to previous value
    export PFILES=$FERMI_OLD_PFILES

fi

if [ -z ${CALDB_OLD_PATH} ]; then
    unset CALDB
else
    export CALDB=$CALDB_OLD_PATH
fi

# Unset these environment variables that were set in the activation script.
unset condaname
unset CALDBALIAS
unset CALDBCONFIG
unset CALDBROOT
unset CALDB_OLD_PATH
unset FERMI_OLD_PFILES
unset FERMI_DIR
unset FERMI_INST_DIR
unset EXTFILESSYS
unset GENERICSOURCESDATAPATH
unset TIMING_DIR
