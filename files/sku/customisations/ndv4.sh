#!/bin/bash -eu

# Link the NDv4 topology file, no graph for this machine type
ln -sf "$TOPOLOGY_SRC_DIR"/topology/ndv4-topo.xml "$TOPOLOGY_FILE"
rm -f "$TOPOLOGY_GRAPH"

# Apply NDv4 specific NCCL configurations
echo "NCCL_IB_PCI_RELAXED_ORDERING=1" >> "$NCCL_CONF"

## NVIDIA Fabric manager
systemctl enable nvidia-fabricmanager
systemctl start nvidia-fabricmanager
systemctl is-active --quiet nvidia-fabricmanager

error_code=$?
if [ ${error_code} -ne 0 ]; then
    echo "NVIDIA Fabric Manager Inactive!"
    exit ${error_code}
fi
