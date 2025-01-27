/*
   Monte Carlo Hackathon created by Hafsa Demnati and Patrick Demichel @
   Viridien 2024 The code compute a Call Option with a Monte Carlo method and
   compare the result with the analytical equation of Black-Scholes Merton :
   more details in the documentation

   Compilation : g++ -O BSM.cxx -o BSM

   Exemple of run: ./BSM #simulations #runs

   ./BSM 100 1000000
   Global initial seed: 21852687      argv[1]= 100     argv[2]= 1000000
   value= 5.136359 in 10.191287 seconds

   ./BSM 100 1000000
   Global initial seed: 4208275479      argv[1]= 100     argv[2]= 1000000
   value= 5.138515 in 10.223189 seconds

   We want the performance and value for largest # of simulations as it will
   define a more precise pricing If you run multiple runs you will see that the
   value fluctuate as expected The large number of runs will generate a more
   precise value then you will converge but it require a large computation

   give values for ./BSM 100000 1000000
   for ./BSM 1000000 1000000
   for ./BSM 10000000 1000000
   for ./BSM 100000000 1000000

   We give points for best performance for each group of runs

   You need to tune and parallelize the code to run for large # of simulations
*/

#include <armpl.h>
#include <math.h>
#include <omp.h>
#include <amath.h>
#include <arm_sve.h>
/* We need uint64_t because the C99 standard does not
   require "unsigned long" to be 64-bit numbers */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>

/* The RNG can be tuned at compile time, see the openrng.h header of ARMPL for a
   list of available options. */
#ifndef GAUSSIAN
#define GAUSSIAN VSL_RNG_METHOD_GAUSSIAN_BOXMULLER
#endif

#ifndef RNG
#define RNG VSL_BRNG_MCG31
#endif

/* Data type can be also tuned at compile time, either simple or double
   precicion may be used. Half precision cannot be used for reasons we do not
   explain here but in our report. */
#ifdef USE_FLOAT
typedef float money_t;

#define money_t_sqrt sqrtf
#define money_t_exp  expf
#define money_t_log  logf

#define svdup_money_t svdup_f32
#define svcntmoney_t svcntw
#define svptrue_bmoney_t svptrue_b32
#define svld1_money_t svld1_f32
#define svcntp_bmoney_t svcntp_b32
#define svmad_money_t_x svmad_f32_x
#define svmul_money_t_x svmul_f32_x
#define svsub_money_t_x svsub_f32_x
#define svadd_money_t_x svadd_f32_x
#define svaddv_money_t svaddv_f32 
#define svmoney_t svfloat32_t
#define svcompact_money_t svcompact_f32
#define svexp_money_t _ZGVsMxv_expf

#else // USE_FLOAT

typedef double money_t;

#define money_t_sqrt sqrt
#define money_t_exp  exp
#define money_t_log  log

#define svdup_money_t svdup_f64
#define svcntmoney_t svcntd
#define svptrue_bmoney_t svptrue_b64
#define svld1_money_t svld1_f64
#define svcntp_bmoney_t svcntp_b64
#define svmad_money_t_x svmad_f64_x
#define svmul_money_t_x svmul_f64_x
#define svsub_money_t_x svsub_f64_x
#define svadd_money_t_x svadd_f64_x
#define svaddv_money_t svaddv_f64 
#define svmoney_t svfloat64_t
#define svcompact_money_t svcompact_f64
#define svexp_money_t _ZGVsMxv_exp

#endif // USE_FLOAT

/* State of the random number generator, private to each thread */
VSLStreamStatePtr rand_stream;
money_t *rand_numbers;
uint64_t rand_index;
uint64_t num_iterations;

#ifndef RAND_BUF_SIZE
#define RAND_BUF_SIZE num_iterations
#endif

#pragma omp threadprivate(rand_stream, rand_numbers, rand_index, num_iterations)

double dml_micros(void)
{
	static struct timeval tv;
	gettimeofday(&tv, NULL);
	return (tv.tv_sec * 1000000) + tv.tv_usec;
}

/* Non-exhaustive error checking for the ARMPL RNG routines */
void vslVerify(const char *src, int err)
{
	const char *msg;

	switch (err) {
	case VSL_ERROR_OK:
		return;
	case VSL_ERROR_FEATURE_NOT_IMPLEMENTED:
		msg = "feature not implemented";
		break;
	case VSL_RNG_ERROR_INVALID_BRNG_INDEX:
		msg = "invalid BRNG index";
		break;
	case VSL_RNG_ERROR_BRNGS_INCOMPATIBLE:
		msg = "incompatible BRNGs";
		break;
	case VSL_RNG_ERROR_BAD_STREAM:
		msg = "bad stream";
		break;
	case VSL_RNG_ERROR_BAD_MEM_FORMAT:
		msg = "unknown stream format";
		break;
	case VSL_RNG_ERROR_NONDETERM_NOT_SUPPORTED:
		msg = "non-deterministic generator unsopprted";
		break;
	default:
		msg = "unknown error";
		break;
	}

	fprintf(stderr, "%s: %s\n", src, msg);
	exit(EXIT_FAILURE);
}

/* Re-populate the random numbers buffer and reset the index to zero */
void rand_regen(void)
{
#ifndef MOCK_RNG
#ifdef USE_FLOAT
	int err =
	    vsRngGaussian(GAUSSIAN, rand_stream, RAND_BUF_SIZE, rand_numbers, 0, 1);
#else  /* USE_FLOAT */
	int err =
	    vdRngGaussian(GAUSSIAN, rand_stream, RAND_BUF_SIZE, rand_numbers, 0, 1);
#endif /* USE_FLOAT */
	vslVerify("vRngGaussian", err);
#else  /* MOCK_RNG */
	memset(rand_numbers, 1, count * sizeof(money_t));
#endif /* MOCK_RNG */
	rand_index = 0;
}

/* Generate Gaussian noise using the Box-Muller transform. Always called from
   OpenMP parallel regon. The function name contains "box_muller", but depending
   on the value of RNG set at compile-time, the Box-Muller transform may not
   actually be used. */
money_t gaussian_box_muller(void)
{
	if (rand_index >= RAND_BUF_SIZE)
		rand_regen();

	return rand_numbers[rand_index++];
}

inline void masked_store(money_t *mem_addr, svbool_t mask, svmoney_t data)
{
	// Step 1: Compact the elements of 'data' based on the predicate 'mask'
	svmoney_t compressed = svcompact_money_t(mask, data);

	// Step 2: Store the compressed elements to memory
	// Note: svst1 stores only the active elements based on the predicate
	svst1(svptrue_bmoney_t(), mem_addr, compressed);
}

/* Function to calculate the Black-Scholes call option price using a
   Monte-Carlo-based method */
money_t black_scholes_monte_carlo(
    uint64_t S0, uint64_t K, money_t alpha, money_t beta)
{
	volatile money_t sum_payoffs = 0;

#pragma omp parallel
	{
		money_t local_sum_payoffs = 0;

		/* constant values */
		money_t threshold = (money_t_log((money_t)K / (money_t)S0) - alpha) / beta;
		svmoney_t vec_threshold = svdup_money_t(threshold);
		svmoney_t vec_S0        = svdup_money_t((money_t)S0);
		svmoney_t vec_K         = svdup_money_t((money_t)K);
		svmoney_t vec_alpha     = svdup_money_t(alpha);
		svmoney_t vec_beta      = svdup_money_t(beta);

		/* number of elements per vector register */
		const uint64_t elem_reg = svcntmoney_t();
		svmoney_t vec_sum_payoffs = svdup_money_t((money_t)0);
		svbool_t pg = svptrue_bmoney_t(); // All true predicate
		money_t *arg_buffer = aligned_alloc(4096, sizeof(double) * num_iterations);
		uint64_t buf_count = 0;
		uint64_t i;

		for (i = 0; i + elem_reg <= num_iterations; i += elem_reg) {
			svmoney_t vec_Z = svld1_money_t(pg, rand_numbers + rand_index);
			rand_index += elem_reg;
			svbool_t mask = svcmpgt(pg, vec_Z, vec_threshold);
			masked_store(arg_buffer + buf_count, mask, vec_Z);
			buf_count += svcntp_bmoney_t(pg, mask);

			if (rand_index >= RAND_BUF_SIZE - elem_reg)
				rand_regen();
		}

		for (; i < num_iterations; i++) {
		  money_t Z = rand_numbers[rand_index++];
		  if (Z > threshold)
		    arg_buffer[buf_count++] = Z;

		  if (rand_index >= RAND_BUF_SIZE)
		    rand_regen();
		}

		// we should have the arg bufer filled with the Zs to exp
		for (i = 0; i + elem_reg <= buf_count; i += elem_reg) {
			svmoney_t vec_Z           = svld1_money_t(pg, arg_buffer + i);
			svmoney_t vec_exp_term    = svmad_money_t_x(pg, vec_beta, vec_Z, vec_alpha);
			svmoney_t vec_exponential = svexp_money_t(vec_exp_term, pg);
			svmoney_t vec_ST = svmul_money_t_x(pg, vec_S0, vec_exponential);
			vec_ST = svsub_money_t_x(pg, vec_ST, vec_K);
			vec_sum_payoffs = svadd_money_t_x(pg, vec_sum_payoffs, vec_ST);
		}

		for (; i < buf_count; i++) {
			local_sum_payoffs += arg_buffer[i];
		}

		local_sum_payoffs += svaddv_money_t(pg, vec_sum_payoffs);
		free(arg_buffer);

#pragma omp critical
		sum_payoffs += local_sum_payoffs;
	}

	return sum_payoffs;
}

int main(int argc, char *argv[])
{
	if (argc != 3) {
		fprintf(stderr, "Usage: %s NUM_SIMULATIONS NUM_RUNS\n", argv[0]);
		return EXIT_FAILURE;
	}

	char *endptr             = NULL;
	uint64_t num_simulations = strtoll(argv[1], &endptr, 10);

	if ((endptr && *endptr != '\0') || (argv[1][0] == '-')) {
		fprintf(stderr, "%s: wrong value of NUM_SIMULATIONS\n", argv[0]);
		exit(EXIT_FAILURE);
	}

	endptr            = NULL;
	uint64_t num_runs = strtoll(argv[2], &endptr, 10);

	if ((endptr && *endptr != '\0') || (argv[2][0] == '-')) {
		fprintf(stderr, "%s: wrong value of NUM_RUNS\n", argv[0]);
		exit(EXIT_FAILURE);
	}

	/* Input parameters */
	uint64_t S0   = 100;  /* Initial stock price */
	uint64_t K    = 110;  /* Strike price */
	money_t T     = 1.0;  /* Time to maturity (1 year) */
	money_t r     = 0.06; /* Risk-free interest rate */
	money_t sigma = 0.2;  /* Volatility */
	money_t q     = 0.03; /* Dividend yield */

	int global_seed = rand();
	money_t sum     = 0;

#pragma omp parallel
	{
		int num_threads         = omp_get_max_threads();
		unsigned int thread_num = omp_get_thread_num();
		num_iterations          = num_simulations / num_threads;
		uint64_t rest = num_simulations - num_iterations * num_threads;

		/* distribute the remaining iterations */
		if (thread_num < rest)
			num_iterations++;

		rand_numbers = malloc(RAND_BUF_SIZE * sizeof(money_t));

		int vslErr = vslNewStream(&rand_stream, RNG, global_seed * thread_num);
		vslVerify("vslNewStream", vslErr);

		rand_regen();
	}

	double t0 = dml_micros();

	/* Pre-compute constant coefficients */
	money_t alpha = T * (r - q - sigma * sigma * 0.5);
	money_t beta  = sigma * money_t_sqrt(T);

	for (uint64_t run = 0; run < num_runs; run++)
		sum += black_scholes_monte_carlo(S0, K, alpha, beta);

	/* Apply final multiplication only once instead of once per iteration */
	sum = exp(-r * T) * (sum / num_simulations);

	double t1           = dml_micros();
	double elapsed_time = (t1 - t0) / 1000000.0; /* in seconds */

#pragma omp parallel
	{
		int vslErr = vslDeleteStream(&rand_stream);
		vslVerify("vslDeleteStream", vslErr);
		free(rand_numbers);
	}

	printf("Seed\t%d\n", global_seed);
	printf("Number of simulations\t%lu\n", num_simulations);
	printf("Number of runs\t%lu\n", num_runs);
	printf("Value\t%.6lf\n", sum / num_runs);
	printf("Time(s)\t%.6lf\n", elapsed_time);

	return EXIT_SUCCESS;
}
