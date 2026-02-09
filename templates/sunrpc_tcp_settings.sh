#!/bin/bash
{{ ansible_managed | comment }}
{{ "system_role:hpc" | comment(prefix="", postfix="") }}

modprobe sunrpc
sysctl -p
