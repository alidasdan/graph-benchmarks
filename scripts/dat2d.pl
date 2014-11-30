#!/usr/bin/perl -w

# Reads a graph in the dat format (the same format as the dimacs
# format but without a transit_time per arc) and prints out the same
# graph in the dimacs format.

# This program may have a side effect if no srand seed is given in the
# input file. The side effect in this case is random regeneration of
# arc weights.

# Author: Ali Dasdan

use strict;

if (defined($ARGV[0])) {
    my $infile = $ARGV[0];
    unless (open(INFILE, "$infile")) {
        die("Error: can't open input file $infile.\n");
    }
} else {
    die("Usage: $0 infile [seed] [reset]\n");
}

my $new_seed = -1;
if (defined($ARGV[1])) {
    $new_seed = $ARGV[1];
}
# if -1 is given by the user, find a new seed.
if (-1 == $new_seed) {
    # the RHS is taken from the book "Programming Perl".
    $new_seed = time() ^ ($$ + ($$ << 15));                
}

# if reset = 1, re-generate all weights
my $reset = 0;
if (defined($ARGV[2])) {
    $reset = 1;
}

# these upper bounds were selected many years ago to ensure the sum of
# arc weights and ttimes were still an integer.
my $max_weight = 3000;
my $max_ttime = 30;

my $line;
while (defined($line = <INFILE>)) {
    chomp($line);
    my @words = split(/[-\s]+/, $line);
    
    my $has_seed = 0;
    if ($line =~ /-/) {
        $has_seed = 1;
    }

    if ($words[0] eq "a") {
        #                0 1 2 3 4
        # input format:  a s t w
        # output format: a s t w ttime

        my $src = $words[1];
        my $tar = $words[2];
        my $weight = $words[3];
        if ($reset) {
            $weight = int(rand $max_weight) + 1;
        }
        my $ttime = int(rand $max_ttime) + 1;

        printf("a $src $tar $weight $ttime\n");

    } elsif ($words[0] eq "p") {
        #                0 1         2    3 4
        # input format:  p prob_name-seed n m
        # output format: p prob_name-seed n m

        my $name = $words[1];
        my $nnodes;
        my $nedges;

        my $prev_seed = -1;
        if ($has_seed) {
            $prev_seed = $words[2];
            $nnodes = $words[3];
            $nedges = $words[4];
        } else {
            # $prev_seed = -1;
            $nnodes = $words[2];
            $nedges = $words[3];
        }

        my $seed = -1;
        if ($reset) {
            $seed = $new_seed;
        } else {
            if (-1 == $prev_seed) {
                # this is the side effect; if no seed in the file, we
                # cannot know the seed used to randomly generate
                # weights, hence, we need to re-generate the weights
                # too as a side effect. the reason for this is that we
                # have to use only a single seed for both weight and
                # ttime.
                $seed = $new_seed;
                $reset = 1;
            } else {
                $seed = $prev_seed;
            }
        }
        if (-1 == $seed) {
            die("Error: seed is not set.\n");
        }
        srand($seed);

        printf("p $name-$seed $nnodes $nedges\n");

    } elsif ($words[0] eq "c") {
        next;
    }
}

close(INFILE);

# end of file
