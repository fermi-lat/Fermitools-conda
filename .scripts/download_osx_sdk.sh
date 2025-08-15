if [ -f ${CI_SUPPORT}/${CONFIG}.yaml ]; then
   export MACOSX_DEPLOYMENT_TARGET=$(cat ${CI_SUPPORT}/${CONFIG}.yaml | shyaml get-value MACOSX_DEPLOYMENT_TARGET.0 10.9)
fi

export MACOSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET:-10.9}

# Some project require a new SDK version even though they can target older versions
if [ -f ${CI_SUPPORT}/${CONFIG}.yaml ]; then
    export MACOSX_SDK_VERSION=$(cat ${CI_SUPPORT}/${CONFIG}.yaml | shyaml get-value MACOSX_SDK_VERSION.0 0)
    export WITH_LATEST_OSX_SDK=$(cat ${CI_SUPPORT}/${CONFIG}.yaml | shyaml get-value WITH_LATEST_OSX_SDK.0 0)
    if [[ "${WITH_LATEST_OSX_SDK}" != "0" ]]; then
        echo "Setting WITH_LATEST_OSX_SDK is removed. Use MACOSX_SDK_VERSION to specify an explicit version for the SDK."
        export MACOSX_SDK_VERSION=11.3
    fi
fi

if [[ "${MACOSX_SDK_VERSION:-0}" == "0" ]]; then
    export MACOSX_SDK_VERSION=$MACOSX_DEPLOYMENT_TARGET
fi

export CONDA_BUILD_SYSROOT="${OSX_SDK_DIR}/MacOSX${MACOSX_SDK_VERSION}.sdk"

if [[ "$OSX_FORCE_SDK_DOWNLOAD"== "1" || ! -d ${CONDA_BUILD_SYSROOT} ]]; then
    echo "Downloading ${MACOSX_SDK_VERSION} sdk"
    curl -L -O https://github.com/phracker/MacOSX-SDKs/releases/download/11.3/MacOSX${MACOSX_SDK_VERSION}.sdk.tar.xz
    mkdir -p "$(dirname "$CONDA_BUILD_SYSROOT")"
    tar -xf MacOSX${MACOSX_SDK_VERSION}.sdk.tar.xz -C "$(dirname "$CONDA_BUILD_SYSROOT")"
fi

if [ ! -z "$CONFIG" ]; then
   echo "" >> ${CI_SUPPORT}/${CONFIG}.yaml
   echo "CONDA_BUILD_SYSROOT:" >> ${CI_SUPPORT}/${CONFIG}.yaml
   echo "- ${CONDA_BUILD_SYSROOT}" >> ${CI_SUPPORT}/${CONFIG}.yaml
   echo "" >> ${CI_SUPPORT}/${CONFIG}.yaml
fi

if [[ -d "${CONDA_BUILD_SYSROOT}" ]]; then
   echo "Found CONDA_BUILD_SYSROOT: ${CONDA_BUILD_SYSROOT}"
else
   echo "Missing CONDA_BUILD_SYSROOT: ${CONDA_BUILD_SYSROOT}"
   exit 1
fi
