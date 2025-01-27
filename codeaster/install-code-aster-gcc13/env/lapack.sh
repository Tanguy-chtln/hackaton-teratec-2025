#!/bin/bash

#ROOT=$(dirname "$(dirname "$(realpath "$0")")")
source "${ROOT}/compiling-env/lapack.sh"

LAPACK_INSTALL_DIR="${PREFIX}/${LAPACK_INSTALL_DIR}"

# Set environment variables
export LAPACK_ROOT="${LAPACK_INSTALL_DIR}"
export LAPACK_INCLUDE_DIR="${LAPACK_INSTALL_DIR}/include"
export LAPACK_LIB_DIR="${LAPACK_INSTALL_DIR}/lib64"

# Prepend paths to the environment variables
export LD_LIBRARY_PATH="${LAPACK_INSTALL_DIR}/lib64:${LD_LIBRARY_PATH}"
export LIBRARY_PATH="${LAPACK_INSTALL_DIR}/lib64:${LIBRARY_PATH}"
export CPATH="${LAPACK_INSTALL_DIR}/include:${CPATH}"
export PKG_CONFIG_PATH="${LAPACK_INSTALL_DIR}/lib64/pkgconfig:${PKG_CONFIG_PATH}"

# Check if DUMP_PRECONFIG is set to 1
if [[ "${DUMP_PRECONFIG}" == "1" ]]; then
    # Compute the full paths
    FULL_LAPACK_INSTALL_DIR=$(realpath "${LAPACK_INSTALL_DIR}")
    
    {
        echo "export LAPACK_ROOT=\"${FULL_LAPACK_INSTALL_DIR}\""
        echo "export LAPACK_INCLUDE_DIR=\"${FULL_LAPACK_INSTALL_DIR}/include\""
        echo "export LAPACK_LIB_DIR=\"${FULL_LAPACK_INSTALL_DIR}/lib64\""
        echo "export LD_LIBRARY_PATH=\"${FULL_LAPACK_INSTALL_DIR}/lib64:\${LD_LIBRARY_PATH}\""
        echo "export LIBRARY_PATH=\"${FULL_LAPACK_INSTALL_DIR}/lib64:\${LIBRARY_PATH}\""
        echo "export CPATH=\"${FULL_LAPACK_INSTALL_DIR}/include:\${CPATH}\""
        echo "export PKG_CONFIG_PATH=\"${FULL_LAPACK_INSTALL_DIR}/lib64/pkgconfig:\${PKG_CONFIG_PATH}\""
} >> ${ROOT}/configSource.txt
else
    # Normal behavior
    :
fi
