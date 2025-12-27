#!/usr/bin/env python3
"""Convert DIMACS .d format to the format expected by the partitioning programs."""

import sys

def convert_file(input_file, output_file):
    """Convert a single DIMACS file to the expected format."""
    with open(input_file, 'r') as f:
        lines = [line.strip() for line in f if line.strip()]
    
    # Parse header
    header = None
    edges = []
    
    for line in lines:
        if line.startswith('p '):
            parts = line.split()
            if len(parts) >= 4:
                try:
                    nodes = int(parts[2])
                    num_edges = int(parts[3])
                    header = (nodes, num_edges)
                except ValueError:
                    print(f"Error parsing header in {input_file}: {line}", file=sys.stderr)
                    return False
        elif line.startswith('a '):
            parts = line.split()
            if len(parts) >= 5:
                try:
                    from_node = int(parts[1])
                    to_node = int(parts[2])
                    weight = abs(int(parts[3]))  # Use absolute value for graph partitioning
                    edges.append((from_node, to_node, weight))
                except ValueError:
                    print(f"Error parsing edge in {input_file}: {line}", file=sys.stderr)
                    continue
    
    if not header:
        print(f"No header found in {input_file}", file=sys.stderr)
        return False
    
    nodes, num_edges = header
    
    # Nodes in DIMACS format are 1-indexed, convert to 0-indexed
    edges_converted = [(f-1, t-1, w) for f, t, w in edges]
    
    # Write output file
    with open(output_file, 'w') as f:
        # Line 1: number of cells
        f.write(f"{nodes}\n")
        # Line 2: number of nets/edges
        f.write(f"{len(edges_converted)}\n")
        
        # Edge lines: weight, num_pins, from, to
        for from_node, to_node, weight in edges_converted:
            f.write(f"{weight} 2 {from_node} {to_node}\n")
        
        # Cell weights (all 1)
        for i in range(nodes):
            f.write("1\n")
    
    return True

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: convert_dimacs_to_input.py <input.d> <output>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    
    if convert_file(input_file, output_file):
        print(f"Converted {input_file} -> {output_file}")
    else:
        print(f"Failed to convert {input_file}", file=sys.stderr)
        sys.exit(1)
