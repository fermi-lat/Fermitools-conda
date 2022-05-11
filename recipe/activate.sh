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

# Issue warnings if PYTHONPATH, LD_LIBRARY_PATH, or DYLD_LIBRARY_PATH are set
if [ ! -z ${DYLD_LIBRARY_PATH+x} ]; then
    echo "You have DYLD_LIBRARY_PATH set. This might interfere with the correct functioning of conda and the Fermitools."
fi
if [ ! -z ${LD_LIBRARY_PATH+x} ]; then
    echo "You have LD_LIBRARY_PATH set. This might interfere with the correct functioning of conda and the Fermitools."
fi
if [ ! -z ${PYTHONPATH+x} ]; then
    echo "You have PYTHONPATH set. This might interfere with the correct functioning of conda and the Fermitools."
fi
### This looping construction works in bash, but not zsh.
# for env_var in "DYLD_LIBRARY_PATH" "LD_LIBRARY_PATH" "PYTHONPATH"
# do
#   if [ ! -z ${!env_var+x} ]; then
#       echo "You have ${env_var} set. This might interfere with the correct functioning of conda and the Fermitools"
#   fi
# done
