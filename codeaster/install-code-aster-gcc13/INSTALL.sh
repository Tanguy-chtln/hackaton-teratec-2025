#!/bin/sh

# STEP 0: load what is already installed on the machine, and set
# environment variables
module use /tools/acfl/24.04/modulefiles
module use modulefiles
module load binutils/13.2.0
module load gnu/13.2.0
module load openmpi/gnu/13.2
module load openblas/gnu/13.2.0

export CC=gcc
export CXX=g++
export FC=gfortran

export OMPI_CC=gcc
export OMPI_CXX=g++
export OMPI_FC=gfortran

export MPICC=mpicc
export MPICXX=mpicxx
export MPICH_F90=gfortran


# Our installation is moving the system's python binary because of some conflict issues.
# However, yum need it to install packages, so if another installation (the armclang one for instance),
# has alredy moved this binary, we move the binary back so that yum can find it
if [ -f '/usr/bin/python.bak' ]
then
    if [ ! -f '/usr/bin/python' ]
    then
        sudo mv /usr/bin/python.bak /usr/bin/python
    fi
fi

if [ -f '/usr/bin/python3.bak' ]
then
    if [ ! -f '/usr/bin/python3' ]
    then
        sudo mv /usr/bin/python3.bak /usr/bin/python3
    fi
fi

# STEP 1: bootstrap the environment, install some indirect dependencies required
# by Code Aster's direct dependencies
prefix="$HOME/opt0"

mkdir -p "$prefix"
make PREFIX="$prefix"

# Default python is conflicting with python3.9 local installation 
if [ -f '/usr/bin/python' ]
then
    sudo mv /usr/bin/python /usr/bin/python.bak
fi

if [ -f '/usr/bin/python3' ]
then
    sudo mv /usr/bin/python3 /usr/bin/python3.bak
fi

source "${prefix}/configSource.sh"

# STEP 2: install the direct dependencies
if [ ! -f 'codeaster-prerequisites-20240327-oss.tar.gz' ]
then
    wget 'https://www.code-aster.org/FICHIERS/prerequisites/codeaster-prerequisites-20240327-oss.tar.gz'
    tar xzf 'codeaster-prerequisites-20240327-oss.tar.gz'

    rm -rf dependencies
    mv codeaster-prerequisites-20240327-oss dependencies

    # Rectify metis installation scripts and archives
    cp metis-5.1.1.tar.gz dependencies/archives/
    cp VERSION dependencies/

    # Apply patches to the src files
    for patch in $(ls patches)
    do
	base=$(echo "$patch" | cut -d'.' -f1)
	patch "dependencies/src/${base}.sh" -i "patches/$patch"
    done
fi

# Compile and install the dependencies of Code Aster
cd dependencies
make ROOT="$HOME/opt1" ARCH=gcc13-openblas-ompi RESTRICTED=0
cd ..

source "$HOME/opt1/20240327/gcc13-openblas-ompi/$(hostname)_mpi.sh"

#STEP 3: install Code Aster
git clone https://gitlab.com/codeaster/src.git code_aster_src
cd code_aster_src
./configure CC=mpicc CXX=mpicxx CF=mpif90 --prefix "$HOME/dev/codeaster/install" --python="${prefix}/install/python-3.9/bin/python3.9" --enable-mpi --enable-openmp
./waf install --jobs=$(nproc)

cat <<EOF
===================================================================
|                     READY TO RUN CODE ASTER                     |
===================================================================

Environment to be sourced :

module use /tools/acfl/24.04/modulefiles
module use modulefiles
module load binutils/13.2.0
module load gnu/13.2.0
module load openmpi/gnu/13.2
module load openblas/gnu/13.2.0
source ${prefix}/configSource.sh
source ${HOME}/opt1/20240327/gcc13-openblas-ompi/$(hostname)_mpi.sh

===================================================================
|                   CODE ASTER INSTALLED AT :                     |
===================================================================

$HOME/dev/codeaster/install

EOF
