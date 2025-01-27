#!/bin/bash

# Installing python 3.9 from github

source "${ROOT}/compiling-env/python.sh"

rm -rf "${ROOT}/${PYTHON_BUILD_DIR}"
git clone --branch 3.9 --depth 1 https://github.com/python/cpython.git "${ROOT}/${PYTHON_BUILD_DIR}"
[ $? -eq 0 ] || exit 1
cd "${ROOT}/${PYTHON_BUILD_DIR}"

./configure --enable-optimizations --enable-shared --with-pymalloc --with-valgrind --prefix="${PREFIX}/${PYTHON_INSTALL_DIR}" 
[ $? -eq 0 ] || exit 1
make -j$(nproc)
[ $? -eq 0 ] || exit 1
make altinstall
[ $? -eq 0 ] || exit 1


# Upgrading and installing required python packages (numpy, pyyaml, cython)

PIP="${PREFIX}/${PYTHON_INSTALL_DIR}/bin/pip3.9"
source "${ROOT}/env/python.sh"

[ $? -eq 0 ] || exit 1
${PIP} install --upgrade pip
[ $? -eq 0 ] || exit 1
${PIP} install numpy pyyaml cython
[ $? -eq 0 ] || exit 1

ln -s ${PREFIX}/${PYTHON_INSTALL_DIR}/bin/python3.9 ${PREFIX}/${PYTHON_INSTALL_DIR}/bin/python
ln -s ${PREFIX}/${PYTHON_INSTALL_DIR}/bin/python3.9 ${PREFIX}/${PYTHON_INSTALL_DIR}/bin/python3

rm -rf "${ROOT}/${PYTHON_BUILD_DIR}"
