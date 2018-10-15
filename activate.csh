#!/bin/tcsh

set condaname="fermitools"

# This instructs the Fermi ST where to find their data

setenv INST_DIR ${CONDA_PREFIX}/share/$condaname
setenv FERMI_DIR ${INST_DIR}
setenv BASE_DIR ${INST_DIR}
setenv EXTFILESSYS ${CONDA_PREFIX}/share/$condaname/refdata/fermi
setenv GENERICSOURCESDATAPATH ${CONDA_PREFIX}/share/$condaname/data/genericSources
setenv TIMING_DIR ${CONDA_PREFIX}/share/$condaname/refdata/fermi/jplephem
setenv PFILES ${CONDA_PREFIX}/share/$condaname/syspfiles

# Keep a copy of the current path so we can restore 
# upon deactivation
setenv FERMI_OLD_PATH $PATH

# Keep a copy of the CALDB path if it exists so
# we can restore upon deactivation
if ($?CALDB) then
    setenv CALDB_OLD_PATH $CALDB
endif

# Set necessary CALDB variables
setenv CALDBALIAS $FERMI_DIR/data/caldb/software/tools/alias_config.fits
setenv CALDBCONFIG $FERMI_DIR/data/caldb/software/tools/caldb.config
setenv CALDBROOT $FERMI_DIR/data/caldb
setenv CALDB $FERMI_DIR/data/caldb


# Add path for the ST binaries
setenv PATH ${CONDA_PREFIX}/bin/${condaname}:${PATH}

# Setup PFILES

# Save old value (this will be the empty string if
# PFILES is not set)
setenv FERMI_OLD_PFILES $PFILES

if (! $?PFILES) then 
    # PFILES is unset, set it appropriately
    `mkdir -p $HOME/pfiles`
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

# Make sure there is no ROOTSYS (which would confuse ROOT)
unsetenv ROOTSYS

# Check whether the .rootrc file exists in the user home,
# if not create it

if ( -f ${HOME}/.rootrc ) then

    # Make it read/write
    chmod u+rw ${HOME}/.rootrc

else

    # File does not exist. Copy the system.rootrc file
    cp ${CONDA_PREFIX}/etc/root/system.rootrc ${HOME}/.rootrc
    
    # Make it read/write
    chmod u+rw ${HOME}/.rootrc

endif

# We need to make sure that the path to the ST library dir is
# contained in the paths that ROOT will search for libraries, 
# because the dynamic loader of ROOT does not honor RPATH

cat <<- EOF | root -b -l
// I am using "default" as default value because I was having problems
// using the empty string.
TString old_value=gEnv->GetValue("Unix.*.Root.DynamicPath", "default");

// The formatting with the { at the end of the line is NECESSARY
// for this to work properly (as this is input for the stdin of
// root)

if(!old_value.Contains("lib/${condaname}")) { 
    TString new_value = old_value + TString(":${CONDA_PREFIX}/lib/${condaname}/");
    gEnv->SetValue("Unix.*.Root.DynamicPath", new_value);
    gEnv->SaveLevel(kEnvUser);
}
exit();
EOF

# Add aliases for python executables
set sitepackagesdir=`python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())"`

alias gtburst "python $sitepackagesdir/$condaname/gtburst.py"
alias ModelEditor "python $sitepackagesdir/$condaname/ModelEditor.py"
alias ObsSim "python $sitepackagesdir/$condaname/ObsSim.py"
 
# # Issue warnings if PYTHONPATH and/or LD_LIBRARY_PATH are set

if ($?LD_LIBRARY_PATH) then 
    # Issue warning
    echo "You have LD_LIBRARY_PATH set. This might interfere with the correct functioning of conda and the Fermi ST"
endif

if ($?PYTHONPATH) then 
    # Issue warning
    echo "You have PYTHONPATH set. This might interfere with the correct functioning of conda and the Fermi ST"
endif
