#!/usr/bin/perl -w

# Convert the output of netd2graph.pl to the dimacs format. See
# trans.sh for its usage.

# Author: Ali Dasdan

use strict;

if (defined($ARGV[0])) {
    my $file = $ARGV[0];
    open(INFILE, "$file") ||
        die("Error: can't open input file $file.\n");
} else {
    die("Usage: $0 file [offset]\n");
}

my $offset = 0;
if (defined($ARGV[1])) {
    $offset = $ARGV[1];
}

my $line = <INFILE>;
chomp($line);
my @words = split(/[\s]+/, $line);
my $seed = $words[1];
if ($words[0] ne "XXXS") {
    die("Error: can't get seed from line '$words[0] $words[1]'\n");
}

$line = <INFILE>;
chomp($line);
@words = split(/[\s]+/, $line);
my $problem = $words[1];
if ($words[0] ne "XXXP") {
    die("Error: can't get problem name from line '$words[0] $words[1]'\n");
}

$line = <INFILE>;
chomp($line);
@words = split(/[\s]+/, $line);
my $num_nodes = $words[1];
if ($words[0] ne "XXXN") {
    die("Error: can't get number of nodes from line '$words[0] $words[1]'\n");
}

$line = <INFILE>;
chomp($line);
@words = split(/[\s]+/, $line);
my $num_edges = $words[1];
if ($words[0] ne "XXXM") {
    die("Error: can't get number of edges from line '$words[0] $words[1]'\n");
}

printf("p $problem-$seed $num_nodes $num_edges\n");

if (0 == $offset) {
    while (defined($line = <INFILE>)) {
        chop($line);
        my @words = split(/[\s]+/, $line);
        printf("a $words[1] $words[2] $words[3] $words[4]\n");
    }
} else {
    while (defined($line = <INFILE>)) {
        chop($line);
        @words = split(/[\s]+/, $line);
        my $new_weight = $words[3] - $offset;
        printf("a $words[1] $words[2] $new_weight $words[4]\n");
    }
}

close(INFILE);

# end of file
