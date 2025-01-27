#!/bin/bash

#ROOT=$(dirname "$(dirname "$(realpath "$0")")")
source "${ROOT}/compiling-env/cmake.sh"

export PATH="${PREFIX}/${CMAKE_INSTALL_DIR}/bin:${PATH}"
export MANPATH="${PREFIX}/${CMAKE_INSTALL_DIR}/share/man:${MANPATH}"

# Check if DUMP_PRECONFIG is set to 1
if [[ "${DUMP_PRECONFIG}" == "1" ]]; then
    # Compute the full paths
    FULL_PATH=$(realpath "${PREFIX}/${CMAKE_INSTALL_DIR}/bin")
    FULL_MANPATH=$(realpath "${PREFIX}/${CMAKE_INSTALL_DIR}/share/man")
    
    # Write the export lines to a file
    echo "export PATH=\"${FULL_PATH}:\${PATH}\"" >> ${ROOT}/configSource.txt
    echo "export MANPATH=\"${FULL_MANPATH}:\${MANPATH}\"" >> ${ROOT}/configSource.txt
else
    # Normal behavior
    :
fi
