#!/bin/tcsh

set condaname="fermitools"

if ($?INST_DIR) then
    unset INST_DIR
endif

if ($?BASE_DIR) then
    unset BASE_DIR
endif

if ($?FERMI_OLD_PATH) then
    setenv PATH $FERMI_OLD_PATH
    unset FERMI_OLD_PATH
endif

if ($?FERMI_OLD_PFILES) then
    setenv PFILES $FERMI_OLD_PFILES
else
    unset PFILES
endif

unalias gtburst
unalias ModelEditor
unalias ObsSim

# We need to remove the path to the ST library dir from the 
# path that ROOT will search for libraries

# cat << EOF | root -b -l

# TString old_value=gEnv->GetValue("Unix.*.Root.DynamicPath", "default");

# TString new_value;

# TObjArray *tx=old_value.Tokenize(":");

# for (Int_t i = 0; i < tx->GetEntries(); i++) {

#     TString this_string(((TObjString *)(tx->At(i)))->String());
    
#     if (!this_string.Contains("lib/${condaname}")) new_value += this_string += ":";

# }

# gEnv->SetValue("Unix.*.Root.DynamicPath", new_value);

# gEnv->SaveLevel(kEnvGlobal);

# exit();

# EOF
