#!/bin/bash -eu

# Link the NDv2 topology file, no graph for this machine type
ln -sf "$TOPOLOGY_SRC_DIR"/topology/ndv2-topo.xml "$TOPOLOGY_FILE"
rm -f "$TOPOLOGY_GRAPH"

