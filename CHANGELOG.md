Changelog
=========

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

