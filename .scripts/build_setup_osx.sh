export CPU_COUNT="${CPU_COUNT:-2}"
export PYTHONUNBUFFERED=1

CI_SUPPORT=$PWD/.ci_support
SCRIPT_DIR=$PWD/.scripts
RECIPE_DIR=$PWD/recipe

conda config --env --set show_channel_urls true
conda config --env --set auto_update_conda false
conda config --env --set add_pip_as_python_dependency false
conda config --env --append aggressive_update_packages ca-certificates
conda config --env --remove-key aggressive_update_packages
conda config --env --append aggressive_update_packages ca-certificates
conda config --env --append aggressive_update_packages certifi

# CONDA_PREFIX might be unset
export CONDA_PREFIX="${CONDA_PREFIX:-$(conda info --json | jq -r .root_prefix)}"

echo "OSX SDK DIR 1: ${OSX_SDK_DIR}"

if [[ "${OSX_SDK_DIR:-}" == "" ]]; then
  OSX_SDK_DIR="$(xcode-select -p)/Platforms/MacOSX.platform/Developer/SDKs"
  USING_SYSTEM_SDK_DIR=1
fi

echo "OSX SDK DIR 2: ${OSX_SDK_DIR}"
ls $OSX_SDK_DIR

source ${SCRIPT_DIR}/cross_compile_support.sh
source ${SCRIPT_DIR}/download_osx_sdk.sh
echo "SDK Path:"
ls /Applications/Xcode_15.4.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk
source ${SCRIPT_DIR}/increment_fermi_version.sh
# source ${SCRIPT_DIR}/increment_build_number.sh

if [[ "$MACOSX_DEPLOYMENT_TARGET" == 10.* && "${USING_SYSTEM_SDK_DIR:-}" == "1" ]]; then
  # set minimum sdk version to our target
  plutil -replace MinimumSDKVersion -string ${MACOSX_SDK_VERSION} $(xcode-select -p)/Platforms/MacOSX.platform/Info.plist
  plutil -replace DTSDKName -string macosx${MACOSX_SDK_VERSION}internal $(xcode-select -p)/Platforms/MacOSX.platform/Info.plist
fi

if [ ! -z "$CONFIG" ]; then
    if [ ! -z "$CI" ]; then
        echo "CI:" >> ${CI_SUPPORT}/${CONFIG}.yaml
        echo "- ${CI}" >> ${CI_SUPPORT}/${CONFIG}.yaml
        echo "" >> ${CI_SUPPORT}/${CONFIG}.yaml
    fi
    cat ${CI_SUPPORT}/${CONFIG}.yaml
fi

conda info
conda config --env --show-sources
conda list --show-channel-urls

if [[ "${CI:-}" == "azure" ]]; then
    PATH=$(echo $PATH | sed 's#/Users/runner/.yarn/bin:##g')
    PATH=$(echo $PATH | sed 's#/Users/runner/Library/Android/sdk/tools:##g')
    PATH=$(echo $PATH | sed 's#/Users/runner/Library/Android/sdk/platform-tools:##g')
    PATH=$(echo $PATH | sed 's#/Users/runner/Library/Android/sdk/ndk-bundle:##g')
    PATH=$(echo $PATH | sed 's#/usr/local/lib/ruby/gems/2.7.0/bin:##g')
    PATH=$(echo $PATH | sed 's#/usr/local/opt/ruby@2.7/bin:##g')
    PATH=$(echo $PATH | sed 's#/Users/runner/.cargo/bin:##g')
    PATH=$(echo $PATH | sed 's#/usr/local/opt/curl/bin:##g')
    PATH=$(echo $PATH | sed 's#/usr/local/opt/pipx_bin##g')
    PATH=$(echo $PATH | sed 's#/Users/runner/.dotnet/tools:##g')
    PATH=$(echo $PATH | sed 's#/Users/runner/.ghcup/bin:##g')
    PATH=$(echo $PATH | sed 's#/Users/runner/hostedtoolcache/stack/2.7.3/x64:##g')
    export PATH
fi


