#!/bin/bash

sudo yum update -y
sudo yum groupinstall "Development Tools" -y
sudo yum install gcc gcc-c++ make zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel xz xz-devel libffi-devel wget git valgrind gdb valgrind-devel.aarch64 valgrind-openmpi.aarch64 -y
sudo yum remove boost

mkdir -p build install
