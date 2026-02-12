# Role Name

[![ansible-lint.yml](https://github.com/linux-system-roles/hpc/actions/workflows/ansible-lint.yml/badge.svg)](https://github.com/linux-system-roles/hpc/actions/workflows/ansible-lint.yml) [![ansible-test.yml](https://github.com/linux-system-roles/hpc/actions/workflows/ansible-test.yml/badge.svg)](https://github.com/linux-system-roles/hpc/actions/workflows/ansible-test.yml) [![codespell.yml](https://github.com/linux-system-roles/hpc/actions/workflows/codespell.yml/badge.svg)](https://github.com/linux-system-roles/hpc/actions/workflows/codespell.yml) [![markdownlint.yml](https://github.com/linux-system-roles/hpc/actions/workflows/markdownlint.yml/badge.svg)](https://github.com/linux-system-roles/hpc/actions/workflows/markdownlint.yml) [![qemu-kvm-integration-tests.yml](https://github.com/linux-system-roles/hpc/actions/workflows/qemu-kvm-integration-tests.yml/badge.svg)](https://github.com/linux-system-roles/hpc/actions/workflows/qemu-kvm-integration-tests.yml) [![shellcheck.yml](https://github.com/linux-system-roles/hpc/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/linux-system-roles/hpc/actions/workflows/shellcheck.yml) [![tft.yml](https://github.com/linux-system-roles/hpc/actions/workflows/tft.yml/badge.svg)](https://github.com/linux-system-roles/hpc/actions/workflows/tft.yml) [![tft_citest_bad.yml](https://github.com/linux-system-roles/hpc/actions/workflows/tft_citest_bad.yml/badge.svg)](https://github.com/linux-system-roles/hpc/actions/workflows/tft_citest_bad.yml) [![woke.yml](https://github.com/linux-system-roles/hpc/actions/workflows/woke.yml/badge.svg)](https://github.com/linux-system-roles/hpc/actions/workflows/woke.yml)

![hpc](https://github.com/linux-system-roles/hpc/workflows/tox/badge.svg)

Ansible role that configures RHEL 9.6 image in Microsoft Azure Cloud for HPC.

## Requirements

* This role supports the x86_64 architecture only.
HPC software is not available on other architectures for now.

### Collection requirements

If you don't want to manage `ostree` systems, the role has no requirements.

If you want to manage `ostree` systems, the role requires additional modules
from external collections.  Please use the following command to install them:

```bash
ansible-galaxy collection install -vv -r meta/collection-requirements.yml
```

## Variables for Controlling Repositories

### hpc_enable_eus_repo

Whether to disable the default `rhui-azure-rhel${major_version}` repository and enable the EUS `rhui-azure-rhel${major_version}-eus` repository.

This is required to continue getting updates for your minor version.
For example, when on RHEL 9.6, once RHEL 9.7 is released, your system will install packages from RHEL 9.7 repositories.
Setting this variable to `true` locks the version to RHEL 9.6 so that you get packages from RHEL 9.6.z repositories.

Default: `true`

Type: `bool`

## Variables for Controlling Packages to Install

These variables control what packages the role installs.
By default, the role installs all the packages.
You can set some of the variables to `false` to make the role not install particular packages.

### hpc_update_kernel

Whether to update kernel to the latest version.

Default: `true`

Type: `bool`

### hpc_update_all_packages

Whether to update all packages on the system to the latest version.

This is a good practice to have the system in the latest state.
But because this is a serious invasion into users environment, this variable is set to `false` by default.

Default: `false`

Type: `bool`

### Azure-specific packages

When running on Azure systems, the role automatically installs Azure platform packages, e.g. VM management infrastructure and storage utilities.

**WALinuxAgent**: Azure Linux Agent manages Linux provisioning and VM interaction with the Azure Fabric Controller.

**aznfs**: Azure NFS mount helper is Azure-optimized NFS client that simplifies mounting Azure Blob Storage containers over NFS v3 and applies client-side optimizations for improved performance. The package is installed from the Microsoft Production repository with non-interactive installation mode enabled. For more information, see <https://github.com/Azure/AZNFS-mount>.

### hpc_install_cuda_driver

Whether to install the CUDA Driver package.

Default: `true`

Type: `bool`

### hpc_install_cuda_toolkit

Whether to install the CUDA Toolkit package.

Note that this package is required for installing OpenMPI.

Default: `true`

Type: `bool`

### hpc_install_hpc_nvidia_nccl

Whether to install the NVIDIA Collective Communications Library (NCCL) package.

Note that this package is required for installing OpenMPI.

Default: `true`

Type: `bool`

### hpc_install_nvidia_fabric_manager

Whether to install the NVIDIA Fabric Manager package and enable the nvidia-fabricmanager service.

Default: `true`

Type: `bool`

### hpc_install_rdma

Whether to install the NVIDIA RDMA package.

Default: `true`

Type: `bool`

### hpc_enable_azure_persistent_rdma_naming

Whether to configure a persistent RDMA device naming scheme on Azure:

* Installs `/usr/sbin/azure_persistent_rdma_naming.sh`
* Installs and enables `azure_persistent_rdma_naming.service`
* Installs a udev rule that triggers the service on InfiniBand device add/change events

This is automatically skipped on non-Azure systems.

Default: `true`

Type: `bool`

### hpc_install_system_openmpi

Whether to install OpenMPI that comes from AppStream repositories and does not have Nvidia GPU support.

The system openmpi package should be installed to support MPI applications that do not require CUDA support and/or GPU acceleration. It can co-exist alongside other installed OpenMPI packages safely, so if in doubt always install this package.

You can run an `lmod` environmental module to select this openmpi by entering the following command:

```bash
module load mpi/openmpi-x86_64
```

Default: `true`

Type: `bool`

### hpc_build_openmpi_w_nvidia_gpu_support

Whether to build OpenMPI with Nvidia GPU support.

Currently, the role builds OpenMPI from source.
Prior to building OpenMPI, it builds its requirements - GDRCopy, HPCX, and PMIx.

Microsoft-supplied PMIx library RPM is built with versioning that replaces the system (appstream) PMIx package (i.e. v4.2.9 vs v3.2.3).
However, the library it installs as libpmix.so.2 is incorrectly versioned - v4.2.9 implements a newer PMIX API that is not backwards compatible with applications linked against older versions of libpmix.so.2.

As OpenMPI v5.x requires PMIx >= 4.2.0, we have no choice but to build PMIx from source so that we can have both versions installed on the system at the same time. This also requires a pmix-4.2.9 environment module to put the pmix install into various paths.

You can run an `lmod` environmental module to select this openmpi by entering the following command:

```bash
module load mpi/openmpi-5.0.8
```

Note that building OpenMPI requires the following variables to be set to `true`, which is the default value:

```yaml
hpc_install_cuda_toolkit: true
hpc_install_hpc_nvidia_nccl: true
```

Default: `true`

Type: `bool`

### hpc_install_nvidia_container_toolkit

Whether to install and configure NVIDIA Container Toolkit.

This enables GPU support in Docker and containerd by installing the nvidia-container-toolkit package. Note that enabling this variable automatically sets `hpc_install_docker: true` unless you explicitly override it.

Default: `true`

Type: `bool`

### hpc_install_docker

Whether to install the moby-engine and moby-cli packages as well as enable the Docker service.
To explicitly disable Docker even when using the NVIDIA Container Toolkit, you need to set this to `false`, please note that the role will fail unless you also disable `hpc_install_nvidia_container_toolkit`.

Default: `"{{ hpc_install_nvidia_container_toolkit }}"`

Type: `bool`

### hpc_install_moneo

Whether to install the Azure Moneo monitoring tool.

Moneo is a distributed GPU system monitor for AI training and inferencing clusters.
It collects GPU telemetry and supports integration with Azure Monitor.

The role installs Moneo to /opt/hpc/azure/tools/Moneo and adds an alias moneo to /etc/bashrc for easy access.

For more information, see <https://github.com/Azure/Moneo>.

### hpc_install_diagnostics

Whether to install the Azure HPC Diagnostics tool.

The Azure HPC Diagnostics tool gathers system information for triage and
debugging purposes. It collects information and state from the hardware, OS,
Azure environment and installed applications, then packages it into a tarball
to simplify the process of system support and bug triage.

To gather diagnostics, run:

```bash
/opt/hpc/azure/tools/gather_azhpc_vm_diagnostics.sh
```

The script will indicate where the tarball containing the diagnostic information
can be found.

For more information, see <https://github.com/Azure/azhpc-diagnostics/>

Default: `true`

Type: `bool`

## hpc_install_azurehpc_health_checks

Whether to install and configure Azure HPC Health Checks (AZNHC).

This downloads the azurehpc-health-checks toolkit, configures it for the target GPU platform, and pulls the appropriate Docker container image from MCR. The health checks validate HPC components including GPUs, InfiniBand, storage, and MPI operations. For more information, see <https://github.com/Azure/azurehpc-health-checks>.

The role installs the toolkit in `/opt/hpc/azure/tests/azurehpc-health-checks/` and pulls `mcr.microsoft.com/aznhc/aznhc-nv:latest`

Note that NVIDIA Container Toolkit must be installed and at least 20G of free space in /var is required for first-time aznhc-nv docker image download. If the image does not exist and /var has insufficient space, installation will be skipped with a warning. See [Expand virtual hard disks on a Linux VM](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/expand-disks?tabs=rhellvm) for disk expansion details.

Default: `true`

Type: `bool`

## Variables for Configuring Tuning for HPC Workloads

### hpc_tuning

Whether to apply tuning for HPC workloads.

The role applies the following tuning configurations:

* Remove user memory limits to ensure applications aren't restricted by creating a file `/etc/security/limits.d/90-hpc-limits.conf` with memlock, nofile, and stack configuration.
* Configure system by creating a file `/etc/sysctl.d/90-hpc-sysctl.conf`.
This file applies the following configuration:

  * Enable zone reclaim mode
  * Increase the size of the IP neighbour cache
  * Increase the number of NFS RPCs per transport to have in flight at once

* Load a `sunrpc` kernel module with `sunrpc.tcp_max_slot_table_entries=128`.

* Boost read performance for newly mounted NFS network shares by adding a file `/etc/udev/rules.d/90-nfs-readahead.rules`.
This configuration increases the data pre-fetching buffer to 15,380 KB to help overcome network latency.

Default: `true`

Type: `bool`

### hpc_sku_customisation

Whether to install the hardware tuning files for different Azure VM types (SKUs).

This will install definitions for optimal hardware configurations for the different types of high performance VMs that are typically used for HPC workloads in the Azure environment.
These include InfiniBand and GPU/NVLink and NCCL customisations, as well as any workarounds for specific hardware problems that may be needed.

Default: `true`

Type: `bool`

## Variables for Configuring How Role Reboots Managed Nodes

### hpc_reboot_ok

If `true`, if the role detects that something was changed that requires a reboot to take effect, the role will reboot the managed host.

If `false`, it is up to you to determine when to reboot the managed host.

The role returns the variable [hpc_reboot_needed](#hpc_reboot_needed) with a value of `true` to indicate that some change has occurred which needs a reboot to take effect.

Default: `false`

Type: `bool`

### Example Playbook for Configuring Packages

```yaml
- name: Configure my virtual machine for HPC
  hosts: localhost
  vars:
    hpc_install_cuda_driver: true
    hpc_install_cuda_toolkit: true
    hpc_install_hpc_nvidia_nccl: true
    hpc_install_nvidia_fabric_manager: true
    hpc_install_rdma: true
    hpc_install_system_openmpi: true
    hpc_build_openmpi_w_nvidia_gpu_support: true
  roles:
    - linux-system-roles.hpc
```

## Variables for Configuring Firewall

### hpc_manage_firewall

Whether to run the linux-system-roles.firewall role to manage Firewall.

Setting this variable to `true` does the following:

1. Enable and start the firewall service.
2. Configure the default firewall zone to be trusted.

This, basically, allows all connections.
This is a common practice with HPC workloads because security is handled by cloud providers.

This is a security measure and we want users to explicitly approve this action by setting this variable to `true`.

Default: `false`

Type: bool

## Variables for Configuring Storage

By default, the role ensures that `rootlv`, `usrlv` and `varlv` in Azure has enough storage for packages to be installed.
You can use variables described in this section to control the exact sizes and paths.

### hpc_manage_storage

Whether to configure the VG from [hpc_rootvg_name](#hpc_rootvg_name) to have logical volumes [hpc_rootlv_name](#hpc_rootlv_name), [hpc_usrlv_name](#hpc_usrlv_name) and [hpc_varlv_name](#hpc_varlv_name) with indicated sizes and mounted to indicated mount points.

Note that the role configures not the exact size, but ensures that the size is at least as indicated, i.e. the role won't shrink logical volumes.

Default: `true`

Type: `bool`

### hpc_rootvg_name

Name of the root volume group to use.
The role configures logical volumes [hpc_rootlv_name](#hpc_rootlv_name), [hpc_usrlv_name](#hpc_usrlv_name) and [hpc_varlv_name](#hpc_varlv_name) to extend them to the size required to install HPC packages.

Default: `rootvg`

Type: `string`

### hpc_rootlv_name

Name of the `root` logical volume to use.

Default: `rootlv`

Type: `string`

### hpc_rootlv_size

The size of the [hpc_rootlv_size](#hpc_rootlv_name) logical volume to configure.

Note that the role configures not the exact size, but ensures that the size is at least as indicated, i.e. the role won't shrink logical volumes if current size is larger than value of this variable.

Default: `10G`

Type: `string`

### hpc_rootlv_mount

Mount point of the [hpc_rootlv_size](#hpc_rootlv_name) logical volume to configure.

Default: `/`

Type: `string`

### hpc_usrlv_name

Name of the `usr` logical volume to use.

Default: `usrlv`

Type: `string`

### hpc_usrlv_size

The size of the [hpc_usrlv_name](#hpc_usrlv_name) logical volume to configure.

Note that the role configures not the exact size, but ensures that the size is at least as indicated, i.e. the role won't shrink logical volumes if current size is larger than value of this variable.

Default: `20G`

Type: `string`

### hpc_usrlv_mount

Mount point of the [hpc_usrlv_name](#hpc_usrlv_name) logical volume to configure.

Default: `/usr`

Type: `string`

### hpc_varlv_name

Name of the `var` logical volume to use.

Default: `varlv`

Type: `string`

### hpc_varlv_size

The size of the [hpc_varlv_name](#hpc_varlv_name) logical volume to configure.

Note that the role configures not the exact size, but ensures that the size is at least as indicated, i.e. the role won't shrink logical volumes if current size is larger than value of this variable.

Default: `10G`

Type: `string`

### hpc_varlv_mount

Mount point of the [hpc_varlv_name](#hpc_varlv_name) logical volume to configure.

Default: `/var`

Type: `string`

### Example Playbook for Configuring Storage

```yaml
- name: Configure my virtual machine for HPC
  hosts: localhost
  vars:
    hpc_manage_storage: true
    hpc_rootvg_name: rootvg
    hpc_rootlv_name: rootlv
    hpc_rootlv_size: 10G
    hpc_rootlv_mount: /
    hpc_usrlv_name: usrlv
    hpc_usrlv_size: 20G
    hpc_usrlv_mount: /usr
    hpc_varlv_name: varlv
    hpc_varlv_size: 10G
    hpc_varlv_mount: /var
  roles:
    - linux-system-roles.hpc
```

## Variables Exported by the Role

### hpc_reboot_needed

Default `false` - if `true`, this means a reboot is needed to apply the changes made by the role.

## Example Playbooks

Run the role to configure storage, install all packages, and reboot if needed.

```yaml
- name: Configure my virtual machine for HPC
  hosts: localhost
  vars:
    hpc_manage_storage: true
    hpc_rootvg_name: rootvg
    hpc_rootlv_name: rootlv
    hpc_rootlv_size: 10G
    hpc_rootlv_mount: /
    hpc_usrlv_name: usrlv
    hpc_usrlv_size: 20G
    hpc_usrlv_mount: /usr
    hpc_varlv_name: varlv
    hpc_varlv_size: 10G
    hpc_varlv_mount: /var

    hpc_install_cuda_driver: true
    hpc_install_cuda_toolkit: true
    hpc_install_hpc_nvidia_nccl: true
    hpc_install_nvidia_fabric_manager: true
    hpc_install_rdma: true
    hpc_install_system_openmpi: true
    hpc_build_openmpi_w_nvidia_gpu_support: true

    hpc_reboot_ok: true
  roles:
    - linux-system-roles.hpc
```

## rpm-ostree

See README-ostree.md

## License

MIT
