#!/usr/bin/perl -w

# Reads a graph in the dimacs format and converts the weights from
# uniform to weibull distribution.

# Author: Ali Dasdan

use strict;

my $infile;
if (defined($ARGV[0])) {
    $infile = $ARGV[0];
    unless (open(INFILE, "$infile")) {
        die("Error: can't open input file $infile.\n");
    }
} else {
    die("Usage: $0 infile alpha1 beta1 alpha2 beta2 [seed]\n");
}

if (! defined($ARGV[2])) {
    die("Usage: weibull.pl infile alpha1 beta1 alpha2 beta2 [seed]\n");
}

# alpha and beta for weight 
my $alpha1 = $ARGV[1];
my $beta1 = $ARGV[2];

# alpha and beta for ttime
my $alpha2 = $ARGV[3];
my $beta2 = $ARGV[4];

my $line;
while (defined($line = <INFILE>)) {
    chomp($line);
    my @words = split(/[-\s]+/, $line);

    if ($words[0] eq "a") {
        #                0 1 2 3 4
        # input format:  a s t w ttime
        # output format: a s t w ttime

        # generate a weibull distribution
        my $num;
        while (1) {
            $num = rand;
            if ((0.0 < $num) && ($num < 1.0)) {
                last;
            }
        }
        my $weight = int(exp((log(-log(1.0 - $num)/$alpha1)) / $beta1)) + 1;
        my $ttime = int(exp((log(-log(1.0 - $num)/$alpha2)) / $beta2)) + 1;

        printf("a $words[1] $words[2] $weight $ttime\n")

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
