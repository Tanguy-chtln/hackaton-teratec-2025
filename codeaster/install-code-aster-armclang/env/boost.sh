#!/bin/bash

#ROOT=$(dirname "$(dirname "$(realpath "$0")")")
source "${ROOT}/compiling-env/boost.sh"

BOOST_VERSION=1.75.0

export BOOST_ROOT="${PREFIX}/${BOOST_INSTALL_DIR}"
export BOOST_VERSION="${BOOST_VERSION}"

export PATH="${PREFIX}/${BOOST_INSTALL_DIR}/bin:${PATH}"
export LD_LIBRARY_PATH="${PREFIX}/${BOOST_INSTALL_DIR}/lib:${LD_LIBRARY_PATH}"
export LIBRARY_PATH="${PREFIX}/${BOOST_INSTALL_DIR}/lib:${LIBRARY_PATH}"
export CMAKE_PREFIX_PATH="${PREFIX}/${BOOST_INSTALL_DIR}:${CMAKE_PREFIX_PATH}"
export CPATH="${PREFIX}/${BOOST_INSTALL_DIR}/include:${CPATH}"

export BOOST_PYTHON_DIR="${PREFIX}/${BOOST_INSTALL_DIR}"
export PYTHONPATH="${PREFIX}/${BOOST_INSTALL_DIR}/lib:${PYTHONPATH}"

# Check if DUMP_PRECONFIG is set to 1
if [[ "${DUMP_PRECONFIG}" == "1" ]]; then
    # Compute the full paths
    FULL_BOOST_ROOT=$(realpath "${PREFIX}/${BOOST_INSTALL_DIR}")
    
    {
        echo "export BOOST_ROOT=\"${FULL_BOOST_ROOT}\""
        echo "export BOOST_VERSION=\"${BOOST_VERSION}\""
        echo "export PATH=\"${FULL_BOOST_ROOT}/bin:\${PATH}\""
        echo "export LD_LIBRARY_PATH=\"${FULL_BOOST_ROOT}/lib:\${LD_LIBRARY_PATH}\""
        echo "export LIBRARY_PATH=\"${FULL_BOOST_ROOT}/lib:\${LIBRARY_PATH}\""
        echo "export CMAKE_PREFIX_PATH=\"${FULL_BOOST_ROOT}:\${CMAKE_PREFIX_PATH}\""
        echo "export CPATH=\"${FULL_BOOST_ROOT}/include:\${CPATH}\""
        echo "export BOOST_PYTHON_DIR=\"${FULL_BOOST_ROOT}\""
        echo "export PYTHONPATH=\"${FULL_BOOST_ROOT}/lib:\${PYTHONPATH}\""
    } >> ${ROOT}/configSource.txt
else
    # Normal behavior
    :
fi
