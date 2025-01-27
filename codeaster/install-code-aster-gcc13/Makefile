ROOT := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
PREFIX ?= $(ROOT)/install
INSTALL_DIR := $(realpath $(PREFIX))

# Export variables
export ROOT
export PREFIX
$(mkdir -p ${PREFIX})

# Targets
all: .installed/general .installed/cmake .installed/python .installed/lapack .installed/boost .installed/configSource

# Yum requirements
.installed/general :
	$(ROOT)/utils/general.sh
	mkdir -p .installed
	touch .installed/general


# CMake installation
.installed/cmake: .installed/general
	$(ROOT)/src/cmake.sh
	mkdir -p .installed
	mkdir -p $(ROOT)/build
	touch .installed/cmake

# Python installation
.installed/python: .installed/general
	$(ROOT)/src/python.sh
	mkdir -p .installed
	mkdir -p $(ROOT)/build
	touch .installed/python

# LAPACK installation
.installed/lapack: .installed/general
	$(ROOT)/src/lapack.sh
	mkdir -p .installed
	mkdir -p $(ROOT)/build
	touch .installed/lapack

# Boost installation
.installed/boost: .installed/cmake .installed/python .installed/general
	$(ROOT)/src/boost.sh
	mkdir -p .installed
	mkdir -p $(ROOT)/build
	touch .installed/boost

.installed/configSource : .installed/cmake .installed/python .installed/lapack .installed/boost
	echo '#!/bin/bash' > ${ROOT}/configSource.txt
	DUMP_PRECONFIG=1 ${ROOT}/env/python.sh
	DUMP_PRECONFIG=1 ${ROOT}/env/cmake.sh
	DUMP_PRECONFIG=1 ${ROOT}/env/lapack.sh
	DUMP_PRECONFIG=1 ${ROOT}/env/boost.sh
	mv ${ROOT}/configSource.txt ${PREFIX}/configSource.sh

	mkdir -p .installed
	touch .installed/configSource

# Clean target to remove build and installed files
.PHONY: clean all install

clean:
	rm -rf $(ROOT)/.installed $(ROOT)/build
