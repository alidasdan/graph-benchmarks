#!/usr/bin/perl -w
#
# netd2graph : netD to graph converter
#
# Usage: netd2graph ibmXX.netD > ibmXX.graph
#
# netD Format:
#  0
#  num_pins
#  num_nets
#  num_modules (= num_nodes = num_cells + num_pads)
#  pad_offset (= num_cells - 1)
#  [net_src s X cell_1 X cell_2 X ... cell_k X] -> this net has k cells
#  ... 
#  X is either I, or O, or B.

# NOTE: pipe the run thru 'grep -v DEBUG' to eliminate debug strings
# and get the final graph output. Also see trans.sh for its usage.

# Author: Ali Dasdan

use strict;

my @inputs = (); # array to hold input nodes of a net
my @outputs = (); # array to hold output nodes of a net

my $num_nodes = 0;
my $num_edges = 0;
my $num_pads = 0;
my $max_weight;
my $max_ttime;

# subroutines

sub print_edges()
{
    if ((@inputs != 0) || (@outputs != 0)) {

        # if the net has no inputs or outputs, designate the last
        # output or input as an input or output, respectively.
        if (0 == @inputs) {
            push(@inputs, pop(@outputs));
        } elsif (0 == @outputs) {
            push(@outputs, pop(@inputs));
        }

        unless ((0 != @inputs) && (0 != @outputs)) {
            die("Error: incorrect number of pins for net.\n");
        }

        # print edges. because of the bi-directional nets, some nets
        # can have more than one driver. do not generate unnecessary
        # self-loops.
        for (my $i = 0; $i < @inputs; $i++) {
            for (my $j = 0; $j < @outputs; $j++) {
                if ($inputs[$i] != $outputs[$j]) {
                    my $edge_weight = int(rand $max_weight) + 1;
                    my $edge_ttime = int(rand $max_ttime) + 1;
                    printf("DEBUGA $inputs[$i] $outputs[$j] $edge_weight $edge_ttime\n");
                    $num_edges++;
                }
            }
        }

        # re-initialize arrays and num_pads.
        @inputs = ();
        @outputs = ();
        $num_pads = 0;
    }
}  # print_edges

# read the file name
my $file;
if (defined($ARGV[0])) {
    $file = $ARGV[0];
    unless (open(INFILE, "$file")) {
        die("Error: can't open input file $file.\n");
    }
} else {
    die("Usage: $0 file [max_edge_weight max_ttime [seed]]\n");
}

# set max edge weight
$max_weight = 3000;
if (defined($ARGV[1])) {
    $max_weight = $ARGV[1];
} 

# set max edge ttime
$max_ttime = 30;
if (defined($ARGV[2])) {
    $max_ttime = $ARGV[2];
} 

# init random number generator. the RHS is taken from the book
# "Programming Perl".
my $seed = time() ^ ($$ + ($$ << 15));
if (defined($ARGV[3])) {
    $seed = $ARGV[3];
} 
printf("DEBUGS $seed\n");
srand($seed);

# parse netlist header

# 0. ignored.
my $line = <INFILE>;

# num_pins
$line = <INFILE>;  

# num_nets
$line = <INFILE>; 

# num_modules (= num_nodes = num_cells + num_pads)
$line = <INFILE>; 
chomp($line);
my @words = split(/[\s]+/, $line);
$num_nodes = $words[0];

# pad_offset
$line = <INFILE>; 
chomp($line);
@words = split(/[\s]+/, $line);
my $pad_offset = $words[0];

printf("DEBUGP $file\n");
printf("DEBUGN $num_nodes\n");

# parse nets and printing edges.  

# One edge is generated for each (O, I) pin of a net. That is, if a
# net has p pins, there will be (p - 1) edges generated for this net.

my $num_lines = 5; # number of lines seen so far

while (defined($line = <INFILE>)) {
    chomp($line);

    # if in the beginning of a new net, print the previous one and
    # initialize arrays.
    if ($line =~ /s/) {
        print_edges();
    }

    # get node number.
    my @words = split(/[\sap]+/, $line);
    my $num = $words[1] + 1;
    if ($line =~ /p/) {
        $num_pads++;
        $num += $pad_offset;
    }

    # check number of nodes
    unless ($num <= $num_nodes) {
        die("Error: number of nodes is wrong.\n");
    }

    # update inputs and outputs arrays.
    if ($line =~ /B/) {
        push(@inputs, $num);
        push(@outputs, $num);
    } elsif ($line =~ /O/) {
        push(@inputs, $num);
    } elsif ($line =~ /I/) {
        push(@outputs, $num);
    } else {
        die("Error: a net pin must be B, O, or I only.\n");
    }

    $num_lines++;
} # while

# print last net.
print_edges();

# print number of edges
printf("DEBUGM $num_edges\n");

# close file
close(INFILE);
    
# end of file
