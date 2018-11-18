#include <stdio.h>
#include <math.h>
#include <sys/time.h>
#include <time.h>
#include <stdint.h>
#include <inttypes.h>
#include <unistd.h>

double function(double x)
{
    return exp(-x * x);
}

double integration(double a, double b, int n)
{
    double h = (b - a) / n;
    double s = 0.0;

    for (int i = 0; i < n; i++) {
        s += function(a + h * (i + 0.5));
    }
    s *= h;

    return s;
}

static inline uint64_t rdtsc()
{
	uint32_t high, low;
	__asm__ __volatile__ (
		"xorl %%eax, %%eax\n"
		"cpuid\n"
		"rdtsc\n"
		"movl %%edx, %0\n"
		"movl %%eax, %1\n"
		: "=r" (high), "=r" (low) 
		:: "%rax", "rbx", "%rcx", "%rdx"
	);
	return ((uint64_t)high << 32) | low;
}

double w_time()
{
	struct timeval tv;
	gettimeofday(&tv, NULL);
	return tv.tv_sec + tv.tv_usec * 1E-6;
}

double E(double sum_time, int n) 
{ 
    return sum_time / n; 
}

double absolute_error(double *all_time, double E_time, int n)
{
	double sum = 0;
	for (int i = 0; i < n; i++)
		sum += fabsf(all_time[i] - E_time);
	return sum / n;
}

double relative_error(double abs_err_time, double E_time)
{
	return (abs_err_time / E_time) * 100;
}

void print_array(double *array, int n)
{
    for (int i = 0; i < n; i++) {
        printf("%d %.6f\n", i, array[i]);
    }
    printf("\n");
}

double get_sum_doubles(double *array, int n)
{
    double sum = 0;
    for (int i = 0; i < n; i++) {
        sum += array[i];
    }

    return sum;
}

int main(void)
{
    const double a = -4.0;
    const double b = 4.0;
    const int n = 1000000;

    const int count_itaration = 100;

    double times_clock[count_itaration];
    double times_ticks[count_itaration];
    double times_wtime[count_itaration];

    for (int i = 0; i < count_itaration; i++) {
        clock_t start_clock = clock();
        double result = pow(integration(a, b, n), 2);
        clock_t stop_clock = clock();
        double time_clock = (stop_clock - start_clock) / (double)CLOCKS_PER_SEC;
        // printf("clock: %.12f\n", time_clock);
        times_clock[i] = time_clock;

        uint64_t start_ticks = rdtsc();
        result = pow(integration(a, b, n), 2);
        uint64_t stop_ticks = rdtsc();
        double Hz = 1.6 * pow(10, 9);
        double time_ticks = (stop_ticks - start_ticks) / Hz;
        // printf("ticks: %.12f\n", time_ticks);
        times_ticks[i] = time_ticks;

        double start_wtime = w_time();
        result = pow(integration(a, b, n), 2);
        double stop_wtime = w_time();
        double time_wtime = stop_wtime - start_wtime;
        // printf("wtime: %.12f\n", time_wtime);
        times_wtime[i] = time_wtime;
    }

    print_array(times_clock, count_itaration);
    print_array(times_ticks, count_itaration);
    print_array(times_wtime, count_itaration);

    double sum_clock = get_sum_doubles(times_clock, count_itaration);
    double sum_ticks = get_sum_doubles(times_ticks, count_itaration);
    double sum_wtime = get_sum_doubles(times_wtime, count_itaration);

	double E_clock = E(sum_clock, count_itaration);
	double E_ticks = E(sum_ticks, count_itaration);
    double E_wtime = E(sum_wtime, count_itaration);

	double abs_err_clock = absolute_error(times_clock, E_clock, count_itaration);
	double abs_err_ticks = absolute_error(times_ticks, E_ticks, count_itaration);
    double abs_err_wtime = absolute_error(times_wtime, E_wtime, count_itaration);

	printf("Absolute error(clock) = %.6f sec.\n", abs_err_clock);
	printf("Absolute error(tsc) = %.6f sec.\n", abs_err_ticks);
    printf("Absolute error(wrime) = %.6f sec.\n", abs_err_wtime);

	double rel_err_clock = relative_error(abs_err_clock, E_clock);
	double rel_err_ticks = relative_error(abs_err_ticks, E_ticks);
    double rel_err_wtime = relative_error(abs_err_wtime, E_wtime);

	printf("----------------------\n");
	printf("Relative error(clock) = %.3f%c\n", rel_err_clock, (char) 37);
	printf("Relative error(tsc) = %.3f%c\n", rel_err_ticks, (char) 37);
	printf("Relative error(wtime) = %.3f%c\n", rel_err_wtime, (char) 37);

    return 0;
}