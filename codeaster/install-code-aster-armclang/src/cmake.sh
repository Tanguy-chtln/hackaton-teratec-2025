#!/bin/bash

set -x

#ROOT=$(dirname "$(dirname "$(realpath "$0")")")

source "${ROOT}/compiling-env/cmake.sh"
tar xvf "${ROOT}/${CMAKE_ARCHIVE}" -C "${ROOT}/${CMAKE_BUILD_DIR}"
[ $? -eq 0 ] || exit 1
cd ${ROOT}/${CMAKE_BUILD_DIR}/cmake-3.31.4

./bootstrap --prefix="${PREFIX}/${CMAKE_INSTALL_DIR}"
[ $? -eq 0 ] || exit 1
make -j$(nproc)
[ $? -eq 0 ] || exit 1
make install
[ $? -eq 0 ] || exit 1


rm -rf "${ROOT}/${CMAKE_BUILD_DIR}"
