#!/usr/bin/env bash
# This is a template, not an actual shell script, so tell shellcheck to
# ignore the problematic templated parts
# shellcheck disable=all
{{ ansible_managed | comment }}
{{ "system_role:hpc" | comment(prefix="", postfix="") }}
# shellcheck enable=all

# This is test code, and some operations are expected to fail. Hence we can't
# use set -e to automatically exist the script if something fails.
set -u

# Script for testing SKU customisation.
#
# This can be run in two ways, determined by the CLI parameter '--manual'
# being specified.
#
# When run in manual mode, the test will mock the SKU string and run the setup
# script, check the install, remove it and check that it is empty. It will
# iterate through all supported SKU types and an invalid type to exercise the
# failure path
#
# When run without the manual CLI parameter, it is assumed that we are being run
# from a CI system using real azure VMs and we are doing whole system testing.
# This means the service scripts will be installing the SKU files at startup,
# and so we do a API query to determine what the current SKU is and expect
# the system to already be set up appropriately.

NCCL_CONF="/etc/nccl.conf"

# define the expected runtime location for the topology and graph
# customisation files
TOPOLOGY_RUNTIME_DIR="{{ __hpc_azure_runtime_dir }}/topology"
TOPOLOGY_GRAPH="${TOPOLOGY_RUNTIME_DIR}/graph.xml"
TOPOLOGY_FILE="${TOPOLOGY_RUNTIME_DIR}/topo.xml"

MANUAL_TEST=
SKU_LIST="standard_nc96ads_a100_v4 \
	  standard_nd40rs_v2 \
	  standard_nd96asr_v4 \
	  standard_hb176rs_v4 \
	  standard_nc80adis_h100_v5 \
	  standard_nd96isr_h200_v5 \
	  standard_nd128isr_gb300_v6 \
	  some_unknown_sku_for_testing"

fail()
{
	echo Failed: "$1"
	exit 1
}

usage()
{
	echo "$1"
	echo "$0 [--manual] [--help|-h|-?]"
	echo
	echo "Run SKU customisation tests. Options:"
	echo "--manual		Exercise all SKU types via mocking."
	echo "--help		Print this usage message."

	exit 1
}

while [ $# -gt 0 ]; do

	case "$1" in
	--manual)
		MANUAL_TEST=1 ;;
	--help|-h|-?)
		usage "Help requested" ;;
	*)	usage "Unknown Option" ;;
	esac
	shift
done


if [ -z "$MANUAL_TEST" ]; then
	metadata_endpoint="http://169.254.169.254/metadata/instance?api-version=2019-06-04"

	retry_count=0
	while (( retry_count++ < 5 )); do
	    SKU_LIST=$(curl -s -H Metadata:true "$metadata_endpoint" | jq -r ".compute.vmSize")
	    [ -z "$SKU_LIST" ] || break
	    sleep 30
	done
fi

if [ -z "$SKU_LIST" ]; then
	fail "Could not retrieve VM Size from IMDS endpoint"
fi

SKU_LIST=$(echo "$SKU_LIST" | awk '{print tolower($0)}')

## Topo file setup based on SKU
for sku in $SKU_LIST; do
	unknown_sku=

	echo
	echo "Testing $sku"
	if [ -n "$MANUAL_TEST" ]; then
		__MOCK_SKU="$sku" "{{ __hpc_azure_resource_dir }}/bin/setup_sku_customisations.sh"
	fi

	case "$sku" in
	standard_hb176*v4 | \
	standard_nc80adis_h100_v5 | \
	standard_nd128is*_gb[2-3]00_v6)
		# No topology or graph file, nccl.conf configured
		[ -e "$TOPOLOGY_FILE" ] && fail "$sku: unexpected topology file found"
		[ -e "$TOPOLOGY_GRAPH" ] && fail "$sku: unexpected graph file found"
		[ -s "$NCCL_CONF" ] || fail "$sku: $NCCL_CONF empty or does not exist"
		;;

	standard_nc96ads_a100_v4)
		# Both topology and graph file, nccl.conf configured
		[ -e "$TOPOLOGY_FILE" ] || fail "$sku: topology file not found"
		[ -e "$TOPOLOGY_GRAPH" ] || fail "$sku: graph file not found"
		[ -s "$NCCL_CONF" ] || fail "$sku: $NCCL_CONF empty or does not exist"
		;;

	standard_nd40rs_v2 | \
	standard_nd*v4 | \
	standard_nd96is*_h[1-2]00_v5)
		# Only topology file, nccl.conf configured
		[ -e "$TOPOLOGY_FILE" ] || fail "$sku: topology file not found"
		[ -e "$TOPOLOGY_GRAPH" ] && fail "$sku: unexpected graph file found"
		[ -s "$NCCL_CONF" ] || fail "$sku: $NCCL_CONF empty or does not exist"
		;;

	*)
		# No topology or graph file, nccl.conf missing or zero length
		echo "Unknown SKU: $sku"
		[ -e "$TOPOLOGY_FILE" ] && fail "$sku: unexpected topology file found"
		[ -e "$TOPOLOGY_GRAPH" ] && fail "$sku: unexpected graph file found"
		[ -s "$NCCL_CONF" ] && fail "$sku: $NCCL_CONF not empty"
		# turn off the service running check
		unknown_sku="$sku"
		;;
	esac

	if [ -n "$MANUAL_TEST" ]; then
		"{{ __hpc_azure_resource_dir }}"/bin/remove_sku_customisations.sh

		# No topology or graph file, nccl.conf missing or zero length
		[ -e "$TOPOLOGY_FILE" ] && fail "$sku: topology file not removed"
		[ -e "$TOPOLOGY_GRAPH" ] && fail "$sku: graph file not removed"
		[ -s "$NCCL_CONF" ] && fail "$sku: $NCCL_CONF not empty"
	elif [ -z "$unknown_sku" ]; then
		# check that the customisation service is running
		if ! systemctl is-active --quiet sku_customisations ; then
			fail "$sku: customisation service not running"
		fi
	fi
	echo Test Passed: "$sku"
done

exit 0
