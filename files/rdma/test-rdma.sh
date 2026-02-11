#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
#
# RDMA Validation Script
# Usage: test-rdma.sh
#

# This is test code, and some operations are expected to fail. Hence we can't
# use set -e to automatically exit the script if something fails.
set -u

fail()
{
	echo Failed: "$1"
	exit 1
}

require_file() {
  local path="$1"
  [[ -e "$path" ]] || fail "missing file: $path"
}

require_executable() {
  local path="$1"
  [[ -x "$path" ]] || fail "not executable: $path"
}

require_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || fail "missing command in PATH: $cmd"
}

sys_vendor() {
  if [[ -r /sys/class/dmi/id/sys_vendor ]]; then
    cat /sys/class/dmi/id/sys_vendor
  else
    echo ""
  fi
}

is_systemd() {
  [[ "$(ps -p 1 -o comm= 2>/dev/null || true)" == "systemd" ]]
}

main() {
	echo
	echo "Testing waagent RDMA flag"
	require_file /etc/waagent.conf
	grep -Fxq "OS.EnableRDMA=y" /etc/waagent.conf || fail "expected 'OS.EnableRDMA=y' in /etc/waagent.conf"
	echo Test Passed: "waagent RDMA flag is set"

	echo
	echo "Testing RDMA userland tools"
	require_cmd ibv_devinfo
	echo Test Passed: "RDMA tools are present (ibv_devinfo)"

	# Azure persistent RDMA naming artifacts/services (Azure only)
	if [ "$(sys_vendor)" != "Microsoft Corporation" ]; then
		echo
		echo "Testing Azure persistent RDMA naming (skip: not Azure)"
		echo Test Passed: "not running on Azure; Azure persistent RDMA naming checks skipped"
		return 0
	fi

	if ! is_systemd; then
		echo
		echo "Testing Azure persistent RDMA naming (skip: not systemd)"
		echo Test Passed: "not running systemd; systemd unit checks skipped"
		return 0
	fi

	echo
	echo "Testing Azure persistent RDMA naming artifacts"
	require_executable /usr/sbin/azure_persistent_rdma_naming.sh
	require_executable /usr/sbin/azure_persistent_rdma_naming_monitor.sh
	require_file /etc/systemd/system/azure_persistent_rdma_naming.service
	require_file /etc/systemd/system/azure_persistent_rdma_naming_monitor.service
	require_file /etc/udev/rules.d/99-azure-persistent-rdma-naming.rules
	echo Test Passed: "Azure persistent RDMA naming artifacts exist"

	echo
	echo "Testing Azure persistent RDMA naming services"
	require_cmd systemctl
	systemctl is-enabled azure_persistent_rdma_naming.service >/dev/null 2>&1 || fail "azure_persistent_rdma_naming.service not enabled"
	systemctl is-enabled azure_persistent_rdma_naming_monitor.service >/dev/null 2>&1 || fail "azure_persistent_rdma_naming_monitor.service not enabled"

	# azure_persistent_rdma_naming.service is Type=oneshot, so it may not remain
	# "active" after it runs. Treat "failed" as an error; other states are OK.
	if [ "$(systemctl is-failed azure_persistent_rdma_naming.service 2>/dev/null || true)" = "failed" ]; then
		fail "azure_persistent_rdma_naming.service is in failed state"
	fi

	# Monitor service should be continuously running.
	systemctl is-active azure_persistent_rdma_naming_monitor.service >/dev/null 2>&1 || fail "azure_persistent_rdma_naming_monitor.service not active"
	echo Test Passed: "Azure persistent RDMA naming services look healthy"
}

main "$@"

