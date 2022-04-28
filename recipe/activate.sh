#!/bin/bash

export condaname="fermitools"

function string_replace {
    echo "${1/\*/$2}"
}

# This instructs the Fermi ST where to find their data

export INST_DIR=$CONDA_PREFIX/share/${condaname}
export FERMI_DIR=$INST_DIR
export FERMI_INST_DIR=$INST_DIR
export BASE_DIR=$INST_DIR
export EXTFILESSYS=$CONDA_PREFIX/share/${condaname}/refdata/fermi
export GENERICSOURCESDATAPATH=$CONDA_PREFIX/share/${condaname}/data/genericSources
export TIMING_DIR=$CONDA_PREFIX/share/${condaname}/refdata/fermi/jplephem
#export PFILES=$CONDA_PREFIX/share/${condaname}/syspfiles

# Keep a copy of the current path so we can restore
# upon deactivation
export FERMI_OLD_PATH=$PATH

# Keep a copy of the CALDB path if it exists so                                                                                                                                   
# we can restore upon deactivation                                                                                                                                                 
if [ "CALDB" ]; then
    export CALDB_OLD_PATH=$CALDB
fi

# Set necessary CALDB variables                                                                                                                                                    
export CALDBALIAS=$FERMI_DIR/data/caldb/software/tools/alias_config.fits
export CALDBCONFIG=$FERMI_DIR/data/caldb/software/tools/caldb.config
export CALDBROOT=$FERMI_DIR/data/caldb
export CALDB=$FERMI_DIR/data/caldb


# The new path to check or add
NEW_FERMI_PATH=$CONDA_PREFIX/bin/${condaname}

# Check that the new path is not already a member of the $PATH
if [[ ${PATH} != *"${NEW_FERMI_PATH}"* ]]; then

    # Add the new fermi path to the $PATH
    export PATH=${NEW_FERMI_PATH}:${PATH}

fi

# Add path for the ST binaries

# Setup PFILES

# Save old value (this will be the empty string if
# PFILES is not set)
export FERMI_OLD_PFILES=$PFILES

if [ -z ${PFILES+x} ]; then

    # PFILES is unset, set it appropriately
    mkdir -p $HOME/pfiles

    export PFILES=".:${HOME}/pfiles;${INST_DIR}/syspfiles"

else

    if [[ ${PFILES} == *[';']* ]]; then

        # current value already contains a ';', which
        # separates read-write pfiles path to read-only
        # pfiles path. Just add the ST one

        export PFILES="${PFILES}:${INST_DIR}/syspfiles"

    else

        # Current value doesn't have any read-only
        # pfiles path. Add the ST one.

        export PFILES="${PFILES};${INST_DIR}/syspfiles"

    fi


fi

# Add aliases for python executables
#TODO Make these entrypoints
# sitepackagesdir=$(python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")
# alias ModelEditor="python $sitepackagesdir/${condaname}/ModelEditor.py"
# alias ObsSim="python $sitepackagesdir/${condaname}/ObsSim.py"

# Issue warnings if PYTHONPATH and/or LD_LIBRARY_PATH are set

if [ -z ${LD_LIBRARY_PATH+x} ]; then

    :

else

    # Issue warning
    echo "You have LD_LIBRARY_PATH set. This might interfere with the correct functioning of conda and the Fermi ST"

fi

if [ -z ${PYTHONPATH+x} ]; then

    :

else

    # Issue warning
    echo "You have PYTHONPATH set. This might interfere with the correct functioning of conda and the Fermi ST"

fi
