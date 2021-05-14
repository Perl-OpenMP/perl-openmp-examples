#include <omp.h>
#include <stdio.h>
#include <stdlib.h>
// fork of gist, stole from:
//   https://gist.github.com/oodler577/556e3f15920ac747145f52e9153a6251
static long steps = 1000000000;
double step;
int main (int argc, const char *argv[]) {
    int i,j, num_threads;
    double x, pi, sum = 0.0;
    double start, delta;
    step = 1.0/(double) steps;
    sum = 0.0;
    start = omp_get_wtime();
    #pragma omp parallel 
    #pragma omp master
    { 
       j = omp_get_num_threads(); // <- query ENV for OMP_NUM_THREADS
       printf(" running on %d threads: ", j);
    } 
    #pragma omp parallel for reduction(+:sum) private(x)
    for (i=0; i < steps; i++) {
        x = (i+0.5)*step;
        sum += 4.0 / (1.0+x*x); 
    }
    // Out of the parallel region, finialize computation
    pi = step * sum;
    delta = omp_get_wtime() - start;
    printf("PI = %.16g computed in %.4g seconds\n", pi, delta);
}
