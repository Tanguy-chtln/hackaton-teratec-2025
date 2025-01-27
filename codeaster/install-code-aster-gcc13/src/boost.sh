#!/bin/bash


source "${ROOT}/compiling-env/boost.sh"
source "${ROOT}/compiling-env/python.sh"
source "${ROOT}/env/cmake.sh"
source "${ROOT}/env/python.sh"

cd ${ROOT}/archives
wget https://archives.boost.io/release/1.75.0/source/boost_1_75_0.tar.gz 
cd ${ROOT}

tar xvf "${ROOT}/${BOOST_ARCHIVE}" -C "${ROOT}/${BOOST_BUILD_DIR}"
[ $? -eq 0 ] || exit 1
cd ${ROOT}/${BOOST_BUILD_DIR}/boost_1_75_0

./bootstrap.sh  --with-python-root="${PREFIX}/${PYTHON_INSTALL_DIR}"  --prefix="${PREFIX}/${BOOST_INSTALL_DIR}" --with-python-version=3.9  --with-libraries=all
[ $? -eq 0 ] || exit 1
echo 'using mpi ;' >> project-config.jam 
./b2 install # --layout=versioned 
#[ $? -eq 0 ] || exit 1

rm -rf "${ROOT}/${BOOST_BUILD_DIR}"
