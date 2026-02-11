#!/bin/bash -eu
# This is a template, not an actual shell script, so tell shellcheck to
# ignore the problematic templated parts
# shellcheck disable=all
{{ ansible_managed | comment }}
{{ "system_role:hpc" | comment(prefix="", postfix="") }}
# shellcheck enable=all

# Set up the common NCCL config options so we can append the configured
# customisations to it as needed.
export NCCL_CONF="/etc/nccl.conf"
echo "NCCL_IGNORE_CPU_AFFINITY=1" > "$NCCL_CONF"

# define the location for the topology and graph customisation files
export TOPOLOGY_SRC_DIR="{{ __hpc_azure_resource_dir }}"
export TOPOLOGY_RUNTIME_DIR="{{ __hpc_azure_runtime_dir }}/topology"
export TOPOLOGY_GRAPH="$TOPOLOGY_RUNTIME_DIR/graph.xml"
export TOPOLOGY_FILE="$TOPOLOGY_RUNTIME_DIR/topo.xml"
mkdir -p "$TOPOLOGY_RUNTIME_DIR"

# Use the internal metadata service API to determine the type of machine and
# apply the necessary customisations for that machine.
#
# Note: for manual testing, we mock the SKU from the test environment rather
# than doing an API lookup. The API based customisation will be tested fully
# from the CI system that runs the testing on appropriate hardware. The CI
# system will not set __MOCK_SKU at all, so ensure that it is initialised to an
# empty string in the case where it is undefined in the environment.
: "${__MOCK_SKU:=}"
if [ -z "$__MOCK_SKU" ]; then
	metadata_endpoint="http://169.254.169.254/metadata/instance?api-version=2019-06-04"

	retry_count=0
	while (( retry_count++ < 5 )); do
	    sku=$(curl -s -H Metadata:true "$metadata_endpoint" | jq -r ".compute.vmSize")
	    [ -z "$sku" ] || break
	    sleep 30
	done
else
	sku="$__MOCK_SKU"
fi

if [ -z "$sku" ]; then
	echo "Error! Could not retrieve VM Size from IMDS endpoint"
	exit 1
fi

sku=$(echo "$sku" | awk '{print tolower($0)}')

## Topo file setup based on SKU
case "$sku" in
	standard_nc96ads_a100_v4)
		"$TOPOLOGY_SRC_DIR"/customisations/ncv4.sh;;

	standard_nd*v4)
		"$TOPOLOGY_SRC_DIR"/customisations/ndv4.sh;;

	standard_nd40rs_v2)
		"$TOPOLOGY_SRC_DIR"/customisations/ndv2.sh;;

	standard_hb176*v4)
		"$TOPOLOGY_SRC_DIR"/customisations/hbv4.sh;;

	standard_nc80adis_h100_v5)
		"$TOPOLOGY_SRC_DIR"/customisations/ncv5.sh;;

	standard_nd96is*_h[1-2]00_v5)
		"$TOPOLOGY_SRC_DIR"/customisations/ndv5.sh;;

	standard_nd128is*_gb[2-3]00_v6)
		"$TOPOLOGY_SRC_DIR"/customisations/ndv6.sh;;

	*)	echo "No SKU customization for $sku"
		rm -f "$TOPOLOGY_GRAPH"
		rm -f "$TOPOLOGY_FILE"
		rm -f "$NCCL_CONF"
		;;
esac

# Point NCCL at the configured topology and graph files
if [ -e "$TOPOLOGY_FILE" ]; then
	echo "NCCL_TOPO_FILE=$TOPOLOGY_FILE" >> "$NCCL_CONF"
fi
if [ -e "$TOPOLOGY_GRAPH" ]; then
	echo "NCCL_GRAPH_FILE=$TOPOLOGY_GRAPH" >> "$NCCL_CONF"
fi

