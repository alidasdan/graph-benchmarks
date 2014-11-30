#!/usr/bin/perl -w

# gnoloop generates a random, weighted, and directed acyclic graph
# with num_nodes and num_edges. The edge weights are uniformly
# distributed between 1 and 3000.

# Author: Ali Dasdan

use strict;

if (@ARGV < 2) {
    die("Usage: $0 num_nodes num_edges [max-weight max_ttime [seed]]\n");
}

my $num_nodes = $ARGV[0];
my $num_edges = $ARGV[1];

if ($num_nodes < 2) {
    die("Error: must have >= 2 nodes.\n");
}

if ($num_edges < 0) {
    die("Error: must have >= 0 edges.\n");
}

my $max_num_edges = $num_nodes * ($num_nodes - 1) / 2;
if ($num_edges > $max_num_edges) {
    die("Error: must have <= $max_num_edges edges.\n");
}

# read max edge weight
my $max_weight = 3000;
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

print("p random_acyc_graph-$seed $num_nodes $num_edges\n");

# do not generate more than nedges.
my $nedges = $num_edges;

# seen is used to prevent generation of multiedges.
my @seen;

# assume that nodes are numbered from 1 to n. generate edges from i to
# i+1 for all i, 1 <= i <= n-1.
for (my $u = 1; $u <= ($num_nodes - 1); $u++) {
    if (0 == $nedges) {
        last;
    }

    my $v = $u + 1;
    $seen[$u]{$v} = 1;

    my $edge_weight = int(rand $max_weight) + 1;
    my $ttime = int(rand $max_ttime) + 1;
    print("a $u $v $edge_weight $ttime\n");
    $nedges--;
}  # for

# generate the remaining edges between randomly selected u and v such
# that num(u) < num(v).
while (0 < $nedges) {
    my $done = 0;
    my $u;
    my $v;

    do {
        $u = int(rand $num_nodes) + 1;
        $v = int(rand $num_nodes) + 1;
    } while (($u >= $v) || (defined($seen[$u]{$v})));


    if (0) {
        # to be used when the loop above takes lots of time.
        $u = int(rand $num_nodes) + 1;
        for (my $ui = 0; $ui < $num_nodes; $ui++) {
            $v = int(rand $num_nodes) + 1;
            for (my $vi = 0; $vi < $num_nodes; $vi++) {
                if (($u < $v) && (defined($seen[$u]{$v}))) {
                    goto done;
                }
                $v = ($v + 1) % $num_nodes;
            }
            $u = ($u + 1) % $num_nodes;
        }
    }

  done:
    # u < v here
    $seen[$u]{$v} = 1;
    my $edge_weight = int(rand $max_weight) + 1;
    my $ttime = int(rand $max_ttime) + 1;
    printf("a $u $v $edge_weight $ttime\n");
    $nedges--;
}  # while

# end of file
