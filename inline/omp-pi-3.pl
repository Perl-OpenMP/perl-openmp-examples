#!/usr/bin/env perl
use strict;
use warnings;
use Alien::OpenMP       ();
use OpenMP::Environment ();

$|++;    # autoflush

#
# Open Question to be solved - %ENV "fixed" ...
#
# Example shows how even when using Inline::C, the
# the state of %ENV is "fixed" once the linked lib
# is loaded.
#
# While this is behaving exactly like an external
# binary being loaded, it'd be very convenient for
# these Inline'd methods to be made environmentally
# sensitive (limitation of GOMP/OpenMP standard).
#

BEGIN {
    my $omp = OpenMP::Environment->new;
    $omp->omp_num_threads(8);
    use Inline (
        C    => 'DATA',
        with => qw/Alien::OpenMP/,
    );
}

my $omp = OpenMP::Environment->new;
for my $np (qw/1 2 4 8 16/) {
    printf( " attempting to run on %d threads: ", $np );
    $omp->omp_num_threads($np);
    my $pi = pi(0);
}

exit;

__DATA__
 
__C__
#include <omp.h>
#include <stdio.h>
#include <stdlib.h>
// fork of gist, stole from:
//   https://gist.github.com/oodler577/556e3f15920ac747145f52e9153a6251
double pi (int xxx) {
    int i,j;
    double x, pi, sum; 
    double start, delta;
    double step;
    static long steps = 1000000000;
    step = 1.0/(double) steps;
    sum = 0.0;
    j =omp_get_num_threads();
    start = omp_get_wtime();
    #pragma omp parallel for reduction(+:sum) private(x)
    for (i=0; i < steps; i++) {
        x = (i+0.5)*step;
        sum += 4.0 / (1.0+x*x); 
    }
    #pragma omp parallel
    #pragma omp master
    printf("!!Actual num_threads: %d !!!\n", omp_get_num_threads());
    // Out of the parallel region, finialize computation
    pi = step * sum;
    delta = omp_get_wtime() - start;
    printf("PI = %.16g computed in %.4g seconds\n", pi, delta);
    return pi;
}
