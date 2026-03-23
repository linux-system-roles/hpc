Changelog
=========

[0.4.0] - 2026-03-23
--------------------

### New Features

- feat: Moneo monitoring tool package (#46)
- feat: Installing Moby container runtime and NVIDIA Container Toolkit (#47)
- feat: add variables for azure resources and tools (#48)
- feat: SKU customisations (#49)
- feat: add expanding rootvg-varlv size function (#51)
- feat: Install and configure Azure HPC Health Checks (#52)
- feat: RDMA naming infra changes (#67)
- feat: refine hpc_tuning and add additional tunings (#70)
- feat: add AZNFS mount helper installation (#72)
- feat: install the Azure HPC Diagnostics script (#76)
- feat: add support for disk partition expansion and PV resize (#80)
- feat: install __hpc_base_packages early via dedicated task (#83)
- feat: gate NVIDIA IMEX enablement to GB200/GB300 NVLink systems (#85)
- feat: Add NVIDIA DCGM installation (#100)

### Bug Fixes

- fix: Change installation path/location for moneo tool (#54)
- fix: fix added for moneo install path (#59)
- fix: address ansible-lint issues in Azure health check PR #52 (#63)
- fix: change the condition about lv expansion to use integer comparison (#66)
- fix: change nvidia-container-toolkit repo and remove version lock (#68)
- fix: do not pull in OFED IB drivers for the persistent naming monitor (#71)
- fix: __MOCK_SKU is uninitialised when run from init services (#74)
- fix: CI fails tests because /var is too small (#75)
- fix: versionlock kernel-devel-matched to prevent depsolve errors (#79)
- fix: Don't try to configure WAAgent in non-Azure environments (#81)
- fix: sku_customisation.service file should not be executable (#84)
- fix: use an alternate subnet for the docker bridge network (#90)
- fix: run azure-specific installation after resource path created (#91)
- fix: correct typo in service running test (#92)
- fix: moneo test-script fixes (#95)
- fix: install cuda-toolkit-config-common-12.9.79-1 with cuda-toolkit 12 (#97)
- fix: install RDMA test script after azure specific resource path created (#98)
- fix: add opt-in net.ifnames=0 for Azure images (#101)
- fix: resolve nvidia-persistenced service failure issue on race condition (#102)
- fix: prevent Azure-specific tasks from running on non-Azure platforms (#104)
- fix: replace unsupported patch module with patch command (#105)

### Other Changes

- refactor: handle INJECT_FACTS_AS_VARS=false by using ansible_facts instead (#44)
- ci: use ANSIBLE_INJECT_FACT_VARS=false by default for testing (#45)
- test: SKU customisations (#50)
- test: Added Testcases for testing moneo tool (#53)
- test: skip hpc_install_nvidia_fabric_manager in skip_toolkit test (#55)
- test: do not install moneo (#57)
- ci: bump ansible/ansible-lint from 25 to 26 (#58)
- build: Add a hidden collection directory to be used for building RPM (#60)
- ci: skip most CI checks if title contains citest skip [citest_skip] (#61)
- chore: Update nvidia-driver and fabricmanager to 580 (#62)
- ci: ansible-lint - remove .collection directory from converted collection [citest_skip] (#65)
- test: add Azure health check test script for basic validation (#69)
- ci: tox-lsr version 3.15.0 [citest_skip] (#73)
- test: Added RDMA validation script for waagent, ibverbs tools, and Azure persistent naming (#77)
- ci: Add Fedora 43, remove Fedora 41 from Testing Farm CI (#78)
- ci: Ansible version must be string, not float [citest_skip] (#82)
- test: add test script for aznfs package (#86)
- ci: bump actions/upload-artifact from 6 to 7 (#88)
- test: add testing Nvidia docker container script (#89)
- test: add validation for hpc tuning (#93)
- ci: tox-lsr 3.16.0 - fix qemu tox test failures - rename to qemu-ansible-core-X-Y [citest_skip] (#94)
- ci: tox-lsr 3.17.0 - container test improvements, use ansible 2.20 for fedora 43 [citest_skip] (#96)
- ci: tox-lsr 3.17.1 - previous update broke container tests, this fixes them [citest_skip] (#99)
- tests: add diagnostics installation validation script (#103)
- test: remove redundant tuning tests from tests_skip_toolkit.yml (#106)

[0.3.2] - 2026-01-06
--------------------

### Other Changes

- ci: bump actions/checkout from 5 to 6 (#39)
- ci: add qemu tests for Fedora 43, drop Fedora 41 (#40)
- ci: bump actions/upload-artifact from 5 to 6 (#41)
- docs: fix copyright in license (#42)

[0.3.1] - 2025-11-17
--------------------

### Bug Fixes

- fix: cannot use community-general version 12 - no py27 and py36 support (#37)

[0.3.0] - 2025-11-13
--------------------

### New Features

- feat: lock VM to RHEL9.6 and enable EUS channels (#31)

### Bug Fixes

- fix: Fail on unsupported architectures (#30)

### Other Changes

- ci: Bump actions/upload-artifact from 4 to 5 (#32)
- ci: use versioned upload-artifact instead of master; bump codeql-action to v4; bump upload-artifact to v5 (#33)
- ci: bump tox-lsr to 3.13.0 (#34)
- ci: bump tox-lsr to 3.14.0 - this moves standard-inventory-qcow2 to tox-lsr (#35)

[0.2.2] - 2025-10-07
--------------------

### Bug Fixes

- fix: fix lmod PATH env for openmpi-5.0.8 (#27)

### Other Changes

- ci: bump github-script from v6 to v7; bump setup-python from v5 to v6 (#26)

[0.2.1] - 2025-10-06
--------------------

### Bug Fixes

- fix: Improve efficiency and apply overall fixes to the role processes (#22)
- fix: Retry installation of packages (#23)
- fix: Fix bug with incorrect indentation of until (#24)

### Other Changes

- ci: Bump actions/github-script from 7 to 8 (#20)

[0.2.0] - 2025-10-02
--------------------

### New Features

- feat: Add improvements from Yaju and Fabio feedback (#13)
- feat: Build gdrcopy, hpcx, and openmpi from source (#17)
- feat: Install system openmpi for usecases that don't need GPUs (#19)

### Bug Fixes

- fix: Only enable the nvidia-fabricmanager service (#14)

### Other Changes

- ci: use tox-lsr 3.12.0 for osbuild_config.yml feature (#16)
- ci: use JSON format for __bootc_validation (#18)

[0.1.0] - 2025-09-16
--------------------

### New Features

- feat: Initialize HPC role (#1)

### Bug Fixes

- fix: Add additional steps from from azure scripts suggested by phagara (#4)

### Other Changes

- ci: Onboard HPC role (#3)
- ci: Bump actions/checkout from 4 to 5 (#5)
- ci: rollout several recent changes to CI testing (#7)
- ci: support openSUSE Leap in qemu/kvm test matrix (#8)
- ci: use the new epel feature to enable EPEL for testing farm (#9)

