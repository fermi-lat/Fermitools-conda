#!/bin/bash

if [ -z ${INST_DIR+x} ]; then : ; else unset INST_DIR; fi
if [ -z ${BASE_DIR+x} ]; then : ; else unset BASE_DIR; fi

if [ -z ${FERMIST_OLD_PATH+x} ]; then

    :

else

    export PATH=${FERMIST_OLD_PATH}
    unset FERMIST_OLD_PATH

fi

if [ -z ${FERMIST_OLD_PFILES} ]; then
    
    # PFILES was not set before activation
    
    unset PFILES

else
    
    # Restore to previous value
    
    export PFILES=$FERMIST_OLD_PFILES

fi


unalias gtburst
unalias ModelEditor
unalias ObsSim
unalias fermist_compatibility_mode_on
unalias fermist_compatibility_mode_off

# We need to remove the path to the ST library dir from the 
# path that ROOT will search for libraries

cat << EOF | root -b -l

TString old_value=gEnv->GetValue("Unix.*.Root.DynamicPath", "default");

TString new_value;

TObjArray *tx=old_value.Tokenize(":");

for (Int_t i = 0; i < tx->GetEntries(); i++) {

    TString this_string(((TObjString *)(tx->At(i)))->String());
    
    if (!this_string.Contains("lib/fermist")) new_value += this_string += ":";

}

gEnv->SetValue("Unix.*.Root.DynamicPath", new_value);

gEnv->SaveLevel(kEnvGlobal);

exit();

EOF
