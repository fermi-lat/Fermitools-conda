#!/bin/bash

export condaname="fermitools"

if [ -z ${INST_DIR+x} ]; then : ; else unset INST_DIR; fi
if [ -z ${BASE_DIR+x} ]; then : ; else unset BASE_DIR; fi

if [ -z ${FERMI_OLD_PATH+x} ]; then

    :

else

    export PATH=${FERMI_OLD_PATH}
    unset FERMI_OLD_PATH

fi

if [ -z ${FERMI_OLD_PFILES} ]; then
    
    # PFILES was not set before activation
    
    unset PFILES

else
    
    # Restore to previous value
    
    export PFILES=$FERMI_OLD_PFILES

fi


unalias gtburst
unalias ModelEditor
unalias ObsSim
