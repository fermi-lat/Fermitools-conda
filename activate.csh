#!/bin/tcsh

set condaname="fermitools"

# This instructs the Fermi ST where to find their data

setenv INST_DIR ${CONDA_PREFIX}/share/$condaname
setenv BASE_DIR ${INST_DIR}
setenv EXTFILESSYS ${CONDA_PREFIX}/share/$condaname/refdata/fermi
setenv GENERICSOURCESDATAPATH ${CONDA_PREFIX}/share/$condaname/data/genericSources
setenv TIMING_DIR ${CONDA_PREFIX}/share/$condaname/refdata/fermi/jplephem
setenv PFILES ${CONDA_PREFIX}/share/$condaname/syspfiles

# Keep a copy of the current path so we can restore 
# upon deactivation
setenv FERMI_OLD_PATH $PATH

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
    if ($PFILES =~ *;*) then
        
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

# We need to add the path to the ST library dir to the 
# path that ROOT will search for libraries, because ROOT
# does not honor RPATH

cat << EOF | root -b -l
TString old_value=gEnv->GetValue("Unix.*.Root.DynamicPath", "hey");
if(!old_value.Contains("lib/${condaname}")) 
{ 
    TString new_value = old_value + TString(":${CONDA_PREFIX}/lib/${condaname}/");
    gEnv->SetValue("Unix.*.Root.DynamicPath", new_value);
    gEnv->SaveLevel(kEnvGlobal);
}
exit();
EOF

# We need to add the path to the ST library dir to the 
# path that ROOT will search for libraries, because ROOT
# does not honor RPATH

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
