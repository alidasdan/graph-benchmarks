#!/usr/bin/perl -w

# grand generates a random, weighted, and directed graph with
# num_nodes and num_edges. The edge weights are uniformly distributed
# between 1 and 3000.

# Author: Ali Dasdan

use strict;

if (@ARGV <= 0) {
    die("Usage: $0 num_nodes num_edges [max-weight max_ttime [seed]]\n");
}

my $num_nodes = $ARGV[0];
my $num_edges = $ARGV[1];

if ($num_edges < $num_nodes) {
    die("Error: number of edges must be >= $num_nodes.\n");
}

# read max edge weight
my $max_weight = 300;
if (defined($ARGV[2])) {
    $max_weight = $ARGV[2];
}

# read max edge ttime
my $max_ttime = 30;
if (defined($ARGV[3])) {
    $max_ttime = $ARGV[3];
}

# init random number generator. 
my $seed = -1;
if (defined($ARGV[4])) {
    $seed = $ARGV[4];
}
if ($seed < 0) {
    # the RHS is taken from the book "Programming Perl".
    $seed = time() ^ ($$ + ($$ << 15)); 
}
srand($seed);

printf("p random_graph-$seed $num_nodes $num_edges\n");

my @list;

for (my $e = 0; $e < ($num_nodes - 1); $e++) {
    my $u = $e + 1;
    my $v = $u + 1;
    $list[$u]{$v} = "";
    my $edge_weight = int(rand $max_weight) + 1;
    my $ttime = int(rand $max_ttime) + 1;
    printf("a $u $v $edge_weight $ttime\n");
}

{
    my $u = $num_nodes;
    my $v = 1;
    $list[$u]{$v} = "";
    my $edge_weight = int(rand $max_weight) + 1;
    my $ttime = int(rand $max_ttime) + 1;
    printf("a $u $v $edge_weight $ttime\n");
}

my $upper = $num_nodes * ($num_nodes - 1) / 2;

my $e = $num_nodes; 
while ($e < $num_edges) {
    my $u;
    my $v;

    my $ntry = 0;
    do {
        $u = int(rand $num_nodes) + 1;
        $v = int(rand $num_nodes) + 1;
        if (++$ntry > $upper) {
            printf("ERROR: Cannot randomly assign edges.\n");
            exit;
        }
    } while (($u == $v) || (defined($list[$u]{$v})));

    $list[$u]{$v} = "";
    my $edge_weight = int(rand $max_weight) + 1;
    my $ttime = int(rand $max_ttime) + 1;
    printf("a $u $v $edge_weight $ttime\n");
    $e++;
}

exit;

# end of file
