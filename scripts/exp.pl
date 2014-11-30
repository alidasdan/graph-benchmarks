#!/usr/bin/perl -w

# Reads a graph in the dimacs format and converts the weights from
# uniform to exponential distribution.

# Author: Ali Dasdan

use strict;

if (defined($ARGV[0])) {
    my $infile = $ARGV[0];
    unless (open(INFILE, "$infile")) {
        die("Error: can't open input file $infile.\n");
    }
} else {
    die("Usage: $0 infile mean mean2 [seed]\n");
}

if (! defined($ARGV[2])) {
    die("Usage: $0 infile mean mean2 [seed]\n");
}

# mean for the arc weight.
my $mean = $ARGV[1];

# mean for the arc transit time.
my $mean2 = $ARGV[2];

my $line;
while (defined($line = <INFILE>)) {
    chomp($line);
    my @words = split(/[-\s]+/, $line);

    if ($words[0] eq "a") {
        #                0 1 2 3 4
        # input format:  a s t w ttime
        # output format: a s t w ttime

        # generator for exp distribution
        my $num;
        while (1) {
            $num = rand;
            if ($num > 0.0) {
                last;
            }
        }
        my $weight = int($mean * (-log($num)));
        my $ttime = 1 + int($mean2 * (-log($num)));

        printf("a $words[1] $words[2] $weight $ttime\n");

    } elsif ($words[0] eq "p") {
        #                0 1         2    3 4
        # input format:  p prob_name-seed n m
        # output format: p prob_name-seed n m

        if (!defined($words[4])) {
            die("Error: Probably missing srand see. Expected: p prob_name-seed n m");
        }

        my $name = $words[1];

        my $seed = -1;
        if (defined($ARGV[3])) {
            $seed = $ARGV[3];
        } else {
            $seed = $words[2];
        }
        if (-1 == $seed) {
            # the RHS is taken from the book "Programming Perl".
            $seed = time() ^ ($$ + ($$ << 15)); 
        }
        srand($seed);

        my $nnodes = $words[3];
        my $nedges = $words[4];

        printf("p $name-$seed $nnodes $nedges\n");

    } elsif ($words[0] eq "c") {

        printf("$line\n");

    }
}

close(INFILE);

# end of file
