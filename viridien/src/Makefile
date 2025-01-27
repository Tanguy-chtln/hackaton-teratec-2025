# Tunable Variables
PROG ?= bsm
CC ?= armclang
# These default macro values are the ones that give the best performance
# according to our benchmarks. The default precision is double, for using simple
# precision, add -DUSE_FLOAT to compile flags.
CFLAGS ?= -O3 -DNDEBUG -DGAUSSIAN=VSL_RNG_METHOD_GAUSSIAN_BOXMULLER2 -DRNG=VSL_BRNG_MCG59 -DRAND_BUFFER_SIZE=134217728

# Non-tunable Variables
__CFLAGS = -fopenmp -Wall -Wextra -D_ISOC11_SOURCE -std=c99 -march=armv8-a+sve2+rng
__LDFLAGS = -fopenmp
__LIBS = -larmpl -lamath -lm

$(PROG): bsm.o
	$(CC) $(__LDFLAGS) $(__LIBS) $(LDFLAGS) $(LIBS) -o $@ $^

bsm.o: bsm.c
	$(CC) $(__CFLAGS) $(CFLAGS) -c -o $@ $<
