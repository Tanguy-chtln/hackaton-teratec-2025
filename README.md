# Environment

On the AWS cluster we used, the following pre-installed modules are needed for
compiling and running the program. The order matters !

``` shell
module load acfl/24.10.1
module load armpl/24.10.1
```

# Compiling

The preferred compiler is Clang tuned for ARM.

```
/tools/acfl/24.10/arm-linux-compiler-24.10.1_AmazonLinux-2/bin/armclang
```

Most makefile variables are tunable from command line. See the content
of `src/Makefile`. In order to suppress default variable definitions,
which are likely not to work, it is recommended to run `make -rR` in
`src` in order to compile our program.
