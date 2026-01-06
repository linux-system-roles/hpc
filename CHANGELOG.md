Changelog
=========

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

