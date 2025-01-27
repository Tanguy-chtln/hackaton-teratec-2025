# Code Aster installation

We are giving you two ways of compiling Code Aster. One using gcc 13 and OpenMPI 4, and one using armclang and OpenMPI 5. For the first one, we have tested it so it should work as long as the OpenBLAS and OpenMPI libraries given in your */tools* directory are same than the one we had. For the second one, we did not have the time to test the installation, but it should work at least until the end of the prerequisites installation. However, we did not manage to configure, compile and install Code Aster's core, so the installation script might fail at this stage, but we recommend you to give it a try, as we may have fixed the issue.

## Compile & Install Code Aster

From this directory, you can either compile Code Aster with **gcc 13** and **OpenMPI 4** by running :
```
cd install-code-aster-gcc13 
./INSTALL.sh
```


Or you can try the **armclang** and **OpenMPI 5** installation :
```
cd install-code-aster-armclang
./INSTALL.sh
```

**WARNING : If you have already download and install one version of Code Aster, and sourced its corresponding files, we highly recommend you to clear all your environment by reopening a clean bash shell before running the other installation. Otherwise, we can not affirm the successfulness of the installation**

The installation script must be runned from its own repository, do not try to launch it from elsewhere. Once an installation is completed, the modules and files to source as well as the folder in which Code Aster has been installed are printed out by the script. You must source the given modules and files before running any Code Aster binary.

## Validating the installation


Once an installation has been completed successully, you can test it by running :
```
# Source the needed modules and files printed by the installation script :
source ...

# Go to Code Aster's installation directory, that is printed by the installation script :
cd ...

# Run the validation tests :
./bin/run_ctest -L submit -LE need_data --resutest=/tmp/resu_submit --timefactor=5
```

## Installation steps 

Both scripts are running the following installation steps :
- Update yum packages, install the needed packages, remove the system libboost
- Compile and install cmake 3.31.4, Python 3.9, ScaLAPACK 3.12.1 and boost 1.75.0
- Move ```/usr/bin/{python,python3}``` to ```/usr/bin/{python,python3}.bak```
- Download, patch, compile and install the prerequisites 
- Download, configure, compile and install Code Aster's core 

We are moving the python binaries as they are conflicting with the local installation. In fact, even though we modified the *PATH* environment variable, and used the ```hash -r``` command to reset bash's cache, we did not manage to make ```which python``` point towards our local binary. We know the choice of moving the python binaries is harsh, but we could not find another solution in the given time. Therefore, you have to be warned that your python binaries will still be moved to their *.bak* versions after the end of the installation script. Once you are done using our Code Aster project, we recommend to move back the two binaries to their original names.

## Installation folder 

Here is a brief explanation of the directories in the installation folders :
- **archives** contains the source code we use to install cmake, ScaLAPACK and boost. For python, we are cloning its github repository
- **compiling-env, env, utils, src, Makefile** are containing the bash scripts and environments variables used to install cmake, python, ScaLAPACK and boost 
- **modulefiles** folder contain the modulefiles to load the OpenBLAS and OpenMPI libraries stored in your */tools* directory 
- **VERSION, patches, metis-5.1.1.tar.gz** are the modifications we make to the prerequisites. In fact, the script downloads the prerequisites from source, so modifications are to be made. Therefore, in the original prerequisites, we are replacing the *VERSION* file, as the version of the metis library has changed. Indeed, we are replacing the archive of metis as the old one can not be decompressed. Finally, we are applying some patches to the *src* directory of the prerequisites. All the patches we apply are written in the *patches* directory.


