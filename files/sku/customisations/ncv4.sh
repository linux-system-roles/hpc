#!/bin/bash -eu

# Set up the NCv4 topology and graph files
ln -sf "$TOPOLOGY_SRC_DIR"/topology/ncv4-topo.xml "$TOPOLOGY_FILE"
ln -sf "$TOPOLOGY_SRC_DIR"/topology/ncv4-graph.xml "$TOPOLOGY_GRAPH"
