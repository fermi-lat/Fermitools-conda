#!/bin/tcsh

set condaname="fermitools"

# This instructs the Fermi ST where to find their data
setenv INST_DIR ${CONDA_PREFIX}/share/$condaname
setenv FERMI_DIR ${INST_DIR}
setenv FERMI_INST_DIR ${INST_DIR}
setenv BASE_DIR ${INST_DIR}
setenv EXTFILESSYS ${CONDA_PREFIX}/share/$condaname/refdata/fermi
setenv GENERICSOURCESDATAPATH ${CONDA_PREFIX}/share/$condaname/data/genericSources
setenv TIMING_DIR ${CONDA_PREFIX}/share/$condaname/refdata/fermi/jplephem

# Keep a copy of the current path so we can restore upon deactivation
#setenv FERMI_OLD_PATH $PATH

# Keep a copy of the CALDB path if it exists so we can restore upon deactivation
if ($?CALDB) then
    setenv CALDB_OLD_PATH $CALDB
endif

# Set necessary CALDB variables
setenv CALDBALIAS $FERMI_DIR/data/caldb/software/tools/alias_config.fits
setenv CALDBCONFIG $FERMI_DIR/data/caldb/software/tools/caldb.config
setenv CALDBROOT $FERMI_DIR/data/caldb
setenv CALDB $FERMI_DIR/data/caldb


# Add path for the ST binaries
#setenv PATH ${CONDA_PREFIX}/bin/${condaname}:${PATH}

# Setup PFILES

# Save old value (this will be the empty string if
# PFILES is not set)
if ($?PFILES) then
   setenv FERMI_OLD_PFILES $PFILES
endif

if (! $?PFILES) then 
    # PFILES is unset, set it appropriately
    mkdir -p $HOME/pfiles
    setenv PFILES ".:${HOME}/pfiles;${INST_DIR}/syspfiles"
else 
    if ("$PFILES" =~ "*;*") then
	# current value already contains a ';', which
	# separates read-write pfiles path to read-only
	# pfiles path. Just add the ST one
	setenv PFILES "${PFILES}:${INST_DIR}/syspfiles"
    else
	# Current value doesn't have any read-only
	# pfiles path. Add the ST one.
	setenv PFILES "${PFILES};${INST_DIR}/syspfiles"
    endif
endif

# Temporary change to address a permissions issue with pyburstanalysisgui (GtBurst)
chmod u+x $CONDA_PREFIX/lib/python3.11/site-packages/fermitools/GtBurst/gtapps_mp/*.py >& /dev/null

# Issue warnings if PYTHONPATH, LD_LIBRARY_PATH, or DYLD_LIBRARY_PATH are set
# if ($?DYLD_LIBRARY_PATH) then 
#     echo "You have DYLD_LIBRARY_PATH set. This might interfere with the correct functioning of conda and the Fermitools."
# endif
# if ($?LD_LIBRARY_PATH) then 
#     echo "You have LD_LIBRARY_PATH set. This might interfere with the correct functioning of conda and the Fermitools."
# endif
# if ($?PYTHONPATH) then 
#     echo "You have PYTHONPATH set. This might interfere with the correct functioning of conda and the Fermitools."
# endif
