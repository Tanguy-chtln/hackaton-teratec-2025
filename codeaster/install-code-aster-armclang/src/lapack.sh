#!/bin/bash

set -x

#ROOT=$(dirname "$(dirname "$(realpath "$0")")")

source "${ROOT}/compiling-env/lapack.sh"
source "${ROOT}/env/cmake.sh"

tar xvf "${ROOT}/${LAPACK_ARCHIVE}" -C "${ROOT}/${LAPACK_BUILD_DIR}"
[ $? -eq 0 ] || exit 1
cd ${ROOT}/${LAPACK_BUILD_DIR}/lapack-3.12.1

cmake -S . -B build -DCMAKE_INSTALL_PREFIX="${PREFIX}/${LAPACK_INSTALL_DIR}"
[ $? -eq 0 ] || exit 1
cmake --build build -j$(nproc) 
[ $? -eq 0 ] || exit 1
cmake --install build
[ $? -eq 0 ] || exit 1

rm -rf "${ROOT}/${LAPACK_BUILD_DIR}"
