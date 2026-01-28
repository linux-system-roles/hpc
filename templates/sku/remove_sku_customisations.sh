#!/bin/bash -eu
# This is a template, not an actual shell script, so tell shellcheck to
# ignore the problematic templated parts
# shellcheck disable=all
{{ ansible_managed | comment }}
{{ "system_role:hpc" | comment(prefix="", postfix="") }}
# shellcheck enable=all

export TOPOLOGY_SRC_DIR="{{ __hpc_azure_resource_dir }}"
export TOPOLOGY_RUNTIME_DIR="{{ __hpc_azure_runtime_dir }}/topology"

# Stop nvidia fabric manager
if systemctl is-active --quiet nvidia-fabricmanager ; then
	systemctl stop nvidia-fabricmanager
	systemctl disable nvidia-fabricmanager
fi

# Remove NVIDIA peer memory module
if lsmod | grep nvidia_peermem &> /dev/null ; then
	rmmod nvidia_peermem
fi

# Clear topo and graph files
rm -rf "$TOPOLOGY_RUNTIME_DIR"

# Clear contents of nccl.conf
cat /dev/null > /etc/nccl.conf
