#!/usr/bin/perl -w

# Reads a graph in the dimacs format and converts to the dot format to
# visualize using graphviz.

# Author: Ali Dasdan

use strict;

if (defined($ARGV[0])) {
    my $infile = $ARGV[0];
    unless (open(INFILE, "$infile")) {
        die("Error: can't open input file $infile.\n");
    }
} else {
    die("Usage: $0 infile [limit]\n");
}

# option 'limit' to turn off generating dot files for digraphs whose
# nnodes is larged than limit (because the command 'dot' takes too
# much time to generate a pdf file).
my $limit = 500;
if (defined($ARGV[1])) {
    $limit = $ARGV[1];
}

my $nnodes = 0;
my $nedges = 0;

my $line;
while (defined($line = <INFILE>)) {
    chomp($line);
    my @words = split(/[-\s]+/, $line);

    if ($words[0] eq "a") {
        #                0 1 2 3 4
        # input format:  a s t w ttime
        # output format: a s t w ttime

        my $src = $words[1];
        my $tar = $words[2];
        my $weight = $words[3];
        my $ttime = $words[4];

        # skip printing transit time for the edge
        printf("\t$src -> $tar [label=\"w=$weight\"];\n");

    } elsif ($words[0] eq "p") {
        #                0 1         2    3 4
        # input format:  p prob_name-seed n m
        # output format: p prob_name-seed n m

        if (!defined($words[4])) {
            die("Error: Probably missing srand see. Expected: p prob_name-seed n m");
        }

        my $name = $words[1];
        my $seed = $words[2];
        $nnodes = $words[3];
        $nedges = $words[4];

        if ($nnodes > $limit) {
            printf("Warning: nnodes=$nnodes larger than limit=$limit.\n");
            $nnodes = 0;
            last;
        }

        # remove "save" and "seed" from the graph name
        if ($name =~ /([^\.]+)\.save/) {
            $name = $1;
        }
        printf("digraph $name {\n");
        printf("label=\"(name=$name,n=$nnodes,m=$nedges)\";\n");

    } elsif ($words[0] eq "c") {

        next;

    }
}

close(INFILE);

# print nodes
if ($nnodes > 0) {
    for (my $i = 0; $i < $nnodes; $i++) {
        my $node = $i + 1;
        printf("\t$node [label=\"$node\"];\n");
    }
    printf("}\n");
}

# end of file
