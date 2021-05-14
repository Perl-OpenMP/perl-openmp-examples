#!/usr/bin/env perl
use strict;
use warnings;
use Alien::OpenMP ();

$|++;    # autoflush

use Inline (
    C    => 'DATA',
    with => qw/Alien::OpenMP/,
);

for my $np (qw/1 2 4 8 16/) {
    printf( " running on %d threads: ", $np );
    my $pi = pi($np);
}

exit;

__DATA__
 
__C__
#include <omp.h>
#include <stdio.h>
#include <stdlib.h>
// fork of gist, stole from:
//   https://gist.github.com/oodler577/556e3f15920ac747145f52e9153a6251
double pi (int j) {
    int i;
    double x, pi, sum; 
    double start, delta;
    double step;
    static long steps = 1000000000;
    step = 1.0/(double) steps;
    sum = 0.0;
    start = omp_get_wtime();
    omp_set_num_threads(j);
    #pragma omp parallel for reduction(+:sum) private(x)
    for (i=0; i < steps; i++) {
        x = (i+0.5)*step;
        sum += 4.0 / (1.0+x*x); 
    }
    // Out of the parallel region, finialize computation
    pi = step * sum;
    delta = omp_get_wtime() - start;
    printf("PI = %.16g computed in %.4g seconds\n", pi, delta);
    return pi;
}
