#!/usr/bin/env bash

set -euo pipefail

ostree_dir="${OSTREE_DIR:-"$(dirname "$(realpath "$0")")"}"

if [ -z "${4:-}" ] || [ "${1:-}" = help ] || [ "${1:-}" = -h ]; then
    cat <<EOF
Usage: $0 packages|repos runtime|testing DISTRO-MAJOR[.MINOR] json|yaml|raw|toml
The script will use the packages, repos and roles files in $ostree_dir to
construct the list of packages or repos needed to build the ostree image.  The script
will output the list of packages or repos in the given format
- json is a JSON list like ["pkg1","pkg2",....,"pkgN"]
- yaml is the YAML list format
- raw is the list of packages, one per line, or repos in INI .repo format
- toml is a list of [[packages]] elements as in https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html-single/composing_installing_and_managing_rhel_for_edge_images/index#creating-an-image-builder-blueprint-for-a-rhel-for-edge-image-using-the-command-line-interface_composing-a-rhel-for-edge-image-using-image-builder-command-line
The DISTRO-MAJOR.MINOR is the same format used by Ansible for distribution e.g. CentOS-8, RedHat-8.9, etc.
- toml is the repo format needed for osbuild-composer
EOF
    exit 1
fi
category="$1"
pkgtype="$2"
distro_ver="$3"
format="$4"
pkgtypes=("$pkgtype")
if [ "$pkgtype" = testing ]; then
    pkgtypes+=(runtime)
fi

get_rolepath() {
    local ostree_dir role rolesdir roles_parent_dir coll_path path
    ostree_dir="$1"
    role="$2"
    roles_parent_dir="$(dirname "$(dirname "$ostree_dir")")"
    rolesdir="$roles_parent_dir/$role/.ostree"
    # assumes collection format
    if [ -d "$rolesdir" ]; then
        echo "$rolesdir"
        return 0
    fi
    # assumes legacy role format like linux-system-roles.$role/
    for rolesdir in "$roles_parent_dir"/*-system-roles."$role"/.ostree; do
        if [ -d "$rolesdir" ]; then
          echo "$rolesdir"
          return 0
        fi
    done
    # look elsewhere
    coll_path="${ANSIBLE_COLLECTIONS_PATH:-}"
    if [ -z "$coll_path" ]; then
        coll_path="${ANSIBLE_COLLECTIONS_PATHS:-}"
    fi
    if [ -n "${coll_path}" ]; then
        for path in ${coll_path//:/ }; do
            for rolesdir in "$path"/ansible_collections/*/*_system_roles/roles/"$role"/.ostree; do
                if [ -d "$rolesdir" ]; then
                    echo "$rolesdir"
                    return 0
                fi
            done
        done
    fi
    1>&2 echo ERROR - could not find role "$role" - please use ANSIBLE_COLLECTIONS_PATH
    exit 2
}

get_packages() {
    local ostree_dir pkgtype pkgfile rolefile
    ostree_dir="$1"
    for pkgtype in "${pkgtypes[@]}"; do
        for suff in "${suffix_list[@]}"; do
            pkgfile="$ostree_dir/packages-${pkgtype}${suff}.txt"
            if [ -f "$pkgfile" ]; then
                cat "$pkgfile"
            fi
        done
        rolefile="$ostree_dir/roles-${pkgtype}.txt"
        if [ -f "$rolefile" ]; then
            local roles role rolepath
            roles="$(cat "$rolefile")"
            for role in $roles; do
                rolepath="$(get_rolepath "$ostree_dir" "$role")"
                if [ -z "$rolepath" ]; then
                    1>&2 echo ERROR - could not find role "$role" - please use ANSIBLE_COLLECTIONS_PATH
                    exit 2
                fi
                get_packages "$rolepath"
            done
        fi
    done | sort -u
}

format_packages_json() {
    local comma pkgs pkg
    comma=""
    pkgs="["
    while read -r pkg; do
        pkgs="${pkgs}${comma}\"${pkg}\""
        comma=,
    done
    pkgs="${pkgs}]"
    echo "$pkgs"
}

format_packages_raw() {
    cat
}

format_packages_yaml() {
    while read -r pkg; do
        echo "- $pkg"
    done
}

format_packages_toml() {
    while read -r pkg; do
        echo "[[packages]]"
        echo "name = \"$pkg\""
        echo "version = \"*\""
    done
}

get_repos() {
    local ostree_dir repotype repofile rolefile
    ostree_dir="$1"
    for repotype in "${pkgtypes[@]}"; do
        for suff in "${suffix_list[@]}"; do
            repofile="$ostree_dir/repos-${repotype}${suff}.repo"
            if [ -f "$repofile" ]; then
                cat "$repofile"
            fi
        done
        rolefile="$ostree_dir/roles-${repotype}.txt"
        if [ -f "$rolefile" ]; then
            local roles role rolepath
            roles="$(cat "$rolefile")"
            for role in $roles; do
                rolepath="$(get_rolepath "$ostree_dir" "$role")"
                if [ -z "$rolepath" ]; then
                    1>&2 echo ERROR - could not find role "$role" - please use ANSIBLE_COLLECTIONS_PATH
                    exit 2
                fi
                get_repos "$rolepath"
            done
        fi
    done
}

format_repos_json() {
    python -c 'import sys; import json; import configparser
cp = configparser.ConfigParser()
cp.read_file(sys.stdin)
ret = []
# supported is from osbuild-mpp
supported = ["baseurl", "metalink", "mirrorlist",
             "enabled", "metadata_expire", "gpgcheck", "username", "password", "priority",
             "sslverify", "sslcacert", "sslclientkey", "sslclientcert",
             "skip_if_unavailable"]
for section in cp.sections():
    repo = {"id": section}
    for option in supported:
        if cp.has_option(section, option):
            repo[option] = cp.get(section, option)
    ret.append(repo)
repo_str = json.dumps(ret)
repo_str = repo_str.replace("$", "$$$$")
print(repo_str)
'
}

format_repos_raw() {
    cat
}

format_repos_yaml() {
    python -c 'import sys; import yaml; import configparser
cp = configparser.ConfigParser()
cp.read_file(sys.stdin)
ret = []
for section in cp.sections():
    repo = {"id": section}
    for option in cp.options(section):
        repo[option] = cp.get(section, option)
    ret.append(repo)
yaml.safe_dump(ret, sys.stdout)
'
}

distro="${distro_ver%%-*}"
suffix_list=("" "-$distro")
ver="${distro_ver##*-}"
if [[ "$ver" =~ ^([0-9]*) ]]; then
    major_ver="${BASH_REMATCH[1]}"
    suffix_list+=("-${distro}-${major_ver}")
    if [ "$ver" != "$major_ver" ]; then
        suffix_list+=("-${distro}-${ver}")
    fi
else
    echo ERROR: cannot parse major version number from version "$ver"
    exit 1
fi

"get_$category" "$ostree_dir" | "format_${category}_$format"
