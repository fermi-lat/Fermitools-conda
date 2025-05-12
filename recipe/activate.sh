#!/bin/bash

export condaname="fermitools"

# This instructs the Fermi ST where to find their data
export INST_DIR=$CONDA_PREFIX/share/${condaname}
export FERMI_DIR=$INST_DIR
export FERMI_INST_DIR=$INST_DIR
export BASE_DIR=$INST_DIR
export EXTFILESSYS=$CONDA_PREFIX/share/${condaname}/refdata/fermi
export GENERICSOURCESDATAPATH=$CONDA_PREFIX/share/${condaname}/data/genericSources
export TIMING_DIR=$CONDA_PREFIX/share/${condaname}/refdata/fermi/jplephem

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

# Setup PFILES

# Save old value (this will be the empty string if PFILES is not set)
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

# Temporary change to address a permissions issue with pyburstanalysisgui (GtBurst)
chmod u+x $CONDA_PREFIX/lib/python3.11/site-packages/fermitools/GtBurst/gtapps_mp/*.py > /dev/null 2>&1
# # Issue warnings if PYTHONPATH, LD_LIBRARY_PATH, or DYLD_LIBRARY_PATH are set
# if [ ! -z ${DYLD_LIBRARY_PATH+x} ]; then
#     echo "You have DYLD_LIBRARY_PATH set. This might interfere with the correct functioning of conda and the Fermitools."
# fi
# if [ ! -z ${LD_LIBRARY_PATH+x} ]; then
#     echo "You have LD_LIBRARY_PATH set. This might interfere with the correct functioning of conda and the Fermitools."
# fi
# if [ ! -z ${PYTHONPATH+x} ]; then
#     echo "You have PYTHONPATH set. This might interfere with the correct functioning of conda and the Fermitools."
# fi
