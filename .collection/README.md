# Microsoft SQL Ansible Collection

## Description

This collection contains a role for managing HPC workloads.

## Installation

There are currently two ways to install this collection, using `ansible-galaxy` or RPM package.

### Installing with ansible-galaxy

You can install the collection with `ansible-galaxy` by entering the following command:

```shell
ansible-galaxy collection install redhat.hpc
```

You can also include it in a requirements.yml file and install it with ansible-galaxy collection install -r requirements.yml, using the format:

```yaml
collections:
  - name: redhat.hpc
```

Note that if you install any collections from Ansible, they will not be upgraded automatically when you upgrade the Ansible package.
To upgrade the collection to the latest available version, run the following command:

```shell
ansible-galaxy collection install redhat.hpc --upgrade
```

You can also install a specific version of the collection, for example, if you need to downgrade when something is broken in the latest version (please report an issue in this repository). Use the following syntax to install version 1.0.0:

```shell
ansible-galaxy collection install redhat.hpc:==1.0.0
```

See [using Ansible collections](https://docs.ansible.com/ansible/devel/user_guide/collections_using.html) for more details.

After the installation, you can call the server role from playbooks with `redhat.hpc.hpc`.
When installing using `ansible-galaxy`, by default, you can find the role documentation at `~/.ansible/collections/ansible_collections/redhat/hpc/roles/hpc/README.md`.

### Installing using RPM package

You can install the collection with the software package management tool `dnf` by running the following command:

```bash
dnf install ansible-collection-redhat-hpc
```

When installing using `dnf`, you can find the role documentation in markdown format at `/usr/share/doc/ansible-collection-redhat-hpc/redhat.hpc-hpc/README.md` and in HTML format at `/usr/share/doc/ansible-collection-redhat-hpc/redhat.hpc-hpc/README.html`.

## Contributing (Optional)

If you wish to contribute to roles within this collection, feel free to open a pull request for the role's upstream repository at https://github.com/linux-system-roles/hpc.

We recommend that prior to submitting a PR, you familiarize yourself with our [Contribution Guidelines](https://linux-system-roles.github.io/contribute.html).

## Support

* Red Hat Enterprise Linux 9 (RHEL 9+)

## Release Notes and Roadmap

For the list of versions and their changelog, see CHANGELOG.md within this collection.

## Related Information

Where available, link to general how to use collections or other related documentation applicable to the technology/product this collection works with. Useful materials such as demos, case studies, etc. may be linked here as well.

## License Information

- MIT
