#!/bin/bash 

source "${ROOT}/compiling-env/python.sh"

export PYTHONPATH="${PREFIX}/${PYTHON_INSTALL_DIR}:${PYTHONPATH}"
export PYTHON_HOME="${PREFIX}/${PYTHON_INSTALL_DIR}:${PYTHON_HOME}"
export PYTHON_DIR="${PREFIX}/${PYTHON_INSTALL_DIR}:${PYTHON_DIR}"
export PYTHON_BIN="${PREFIX}/${PYTHON_INSTALL_DIR}/bin:${PYTHON_BIN}"
export PYTHON_LIB="${PREFIX}/${PYTHON_INSTALL_DIR}/lib:${PYTHON_LIB}"
export PYTHON_INC="${PREFIX}/${PYTHON_INSTALL_DIR}/include:${PYTHON_INC}"

export PATH="${PREFIX}/${PYTHON_INSTALL_DIR}/bin:${PATH}"
export LD_LIBRARY_PATH="${PREFIX}/${PYTHON_INSTALL_DIR}/lib:${LD_LIBRARY_PATH}"
export INCLUDE="${PREFIX}/${PYTHON_INSTALL_DIR}/include:${INCLUDE}"
export MANPATH="${PREFIX}/${PYTHON_INSTALL_DIR}/share/man:${MANPATH}"
export PKG_CONFIG_PATH="${PREFIX}/${PYTHON_INSTALL_DIR}/lib/pkgconfig:${PKG_CONFIG_PATH}"

# Check if DUMP_PRECONFIG is set to 1
if [[ "${DUMP_PRECONFIG}" == "1" ]]; then
    # Compute the full paths
    FULL_PYTHON_DIR=$(realpath "${PREFIX}/${PYTHON_INSTALL_DIR}")
    
    {
        echo "export PYTHONPATH=\"${FULL_PYTHON_DIR}:\${PYTHONPATH}\""
        echo "export PYTHON_HOME=\"${FULL_PYTHON_DIR}:\${PYTHON_HOME}\""
        echo "export PYTHON_DIR=\"${FULL_PYTHON_DIR}:\${PYTHON_DIR}\""
        echo "export PYTHON_BIN=\"${FULL_PYTHON_DIR}/bin:\${PYTHON_BIN}\""
        echo "export PYTHON_LIB=\"${FULL_PYTHON_DIR}/lib:\${PYTHON_LIB}\""
        echo "export PYTHON_INC=\"${FULL_PYTHON_DIR}/include:\${PYTHON_INC}\""
        echo "export PATH=\"${FULL_PYTHON_DIR}/bin:\${PATH}\""
        echo "export LD_LIBRARY_PATH=\"${FULL_PYTHON_DIR}/lib:\${LD_LIBRARY_PATH}\""
        echo "export INCLUDE=\"${FULL_PYTHON_DIR}/include:\${INCLUDE}\""
        echo "export MANPATH=\"${FULL_PYTHON_DIR}/share/man:\${MANPATH}\""
        echo "export PKG_CONFIG_PATH=\"${FULL_PYTHON_DIR}/lib/pkgconfig:\${PKG_CONFIG_PATH}\""
    } >> ${ROOT}/configSource.txt
else
    # Normal behavior
    :
fi
