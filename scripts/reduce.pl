#!/usr/bin/perl -w

# Reduce the arc weights and ttimes in the input file.

use strict;

if (defined($ARGV[0])) {
    my $infile = $ARGV[0];
    unless (open(INFILE, "$infile")) {
        die("Error: can't open input file $infile.\n");
    }
} else {
    die("Usage: $0 infile max_weight max_ttime\n");
}

my $max_weight = 300;
if (defined($ARGV[1])) {
    $max_weight = $ARGV[1];
}

my $max_ttime = 10;
if (defined($ARGV[2])) {
    $max_ttime = $ARGV[2];
}

my $line;
while (defined($line = <INFILE>)) {
    chomp($line);
    my @words = split(/[-\s]+/, $line);

    if ($words[0] eq "a") {
        #                0 1 2 3 4
        # input format:  a s t w ttime
        # output format: a s t w ttime
        my $weight = int(rand $max_weight) + 1;
        my $ttime = int(rand $max_ttime) + 1;
        printf("a $words[1] $words[2] $weight $ttime\n")
    } elsif ($words[0] eq "p") {
        #                0 1         2    3 4
        # input format:  p prob_name-seed n m
        # output format: p prob_name-seed n m
        my $seed;
        if (defined($ARGV[3])) {
            $seed = $ARGV[3];
        } else {
            $seed = $words[2];
        }
        srand($seed);
        printf("$line\n");
    }
}

close(INFILE);

# end of file
