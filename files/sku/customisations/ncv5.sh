#!/bin/bash -eu

# there are no current topology optimisations for this hardware.
rm -f "$TOPOLOGY_FILE"
rm -f "$TOPOLOGY_GRAPH"

# Attempt to work around NVLink initialisation bug
if nvidia-smi nvlink --status | grep -qa inActive; then
	# Ensure Hyper-V PCI devices is ready
	#
	# We have to do this the hard way with a regex per file because
	# the ansible linter errors out when you use the simple one liner
	# 'ls |grep {regex}' pattern.
	for ((retries = 0; retries <= 5; retries++)); do
		found=0
		for f in *; do
			if [[ "$f" =~ [0-9a-f]{8}- ]]; then
				found=1;
				break;
			fi
		done

		[ "$found" -ne 0 ] && break;
		echo "Waiting for Hyper-V PCI devices..."
		sleep 1
	done

	if [ "$found" -eq 0 ]; then
	    echo "Hyper-V PCI devices Inactive!"
	    exit 1
	fi

	# Ensure NVIDIA GPU PCI devices is ready
	retries=0
	while ! lspci | grep -qi nvidia; do
		error_code=$?
		if (( retries++ >= 5 )); then
			echo "NVIDIA GPU PCI Inactive!"
			exit ${error_code}
		fi
		echo "Waiting for NVIDIA GPU PCI devices..."
		sleep 1
	done

	echo "Reloading NVIDIA kernel modules..."
	sudo systemctl stop nvidia-dcgm.service
	sudo modprobe -r nvidia_drm nvidia_modeset gdrdrv nvidia_peermem nvidia_uvm nvidia  
	sudo modprobe nvidia nvidia_modeset nvidia_uvm nvidia_peermem gdrdrv nvidia_drm
	sudo systemctl start nvidia-dcgm.service
	fi

echo "Check NVLink status after reloading NVIDIA kernel modules..."
if nvidia-smi nvlink --status | grep -qa inActive; then
	echo "NVLink is still Inactive after reloading NVIDIA kernel modules!"
	exit 1
else
	echo "NVLink is Active."
fi
