#!/bin/bash

function string_replace {
    echo "${1/\*/$2}"
}

# This instructs the Fermi ST where to find their data

export INST_DIR=$CONDA_PREFIX/share/fermist
export BASE_DIR=$INST_DIR

# Keep a copy of the current path so we can restore 
# upon deactivation
export FERMIST_OLD_PATH=$PATH

# Add path for the ST binaries
export PATH=$CONDA_PREFIX/bin/fermist:${PATH}

# Setup PFILES

# Save old value (this will be the empty string if
# PFILES is not set)
export FERMIST_OLD_PFILES=$PFILES

if [ -z ${PFILES+x} ]; then 
    
    # PFILES is unset, set it appropriately
    mkdir -p $HOME/pfiles
    
    export PFILES=".:${HOME}/pfiles;${INST_DIR}/syspfiles"
    
else 
    
    if [[ $1 == *[';']* ]]; then
        
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

# Make sure there is no ROOTSYS (which would confuse ROOT)
unset ROOTSYS

# We need to add the path to the ST library dir to the 
# path that ROOT will search for libraries, because ROOT
# does not honor RPATH

cat << EOF | root -b -l

TString old_value=gEnv->GetValue("Unix.*.Root.DynamicPath", "hey");

if(!old_value.Contains("lib/fermist")) 
{ 
    TString new_value = old_value + TString(":${CONDA_PREFIX}/lib/fermist/");

    gEnv->SetValue("Unix.*.Root.DynamicPath", new_value);

    gEnv->SaveLevel(kEnvGlobal);
}

exit();

EOF


# Add aliases for python executables
sitepackagesdir=$(python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")

alias gtburst="python $sitepackagesdir/fermist/gtburst.py"
alias ModelEditor="python $sitepackagesdir/fermist/ModelEditor.py"
alias ObsSim="python $sitepackagesdir/fermist/ObsSim.py"

# These aliases are a convenience to activates the compatibility mode
# for python scripts and packages written for the old system (before conda)
# where packages are imported as "import UnbinnedAnalysis" instead of
# "from fermist import UnbinnedAnalysis"
alias fermist_compatibility_mode_on="export PYTHONPATH=${sitepackagesdir}/fermist:${PYTHONPATH}"
alias fermist_compatibility_mode_off='export PYTHONPATH=${PYTHONPATH/"${sitepackagesdir}/fermist"/}'

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
