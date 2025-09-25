#!/bin/bash

# Load the sunrpc module and apply the sysctls configured for the subsystem.
# This will be run from a startup service to ensure the tunables are always set
# on boot.
modprobe sunrpc
sysctl -p
