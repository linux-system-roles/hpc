{{ ansible_managed | comment }}
{{ "system_role:hpc" | comment(prefix="", postfix="") }}
-- This file should be installed in the same directory as the system as:
-- /usr/share/modulefiles/pmix/pmix-{{ __hpc_pmix_info.version }}.lua
--
-- This allows it to conflict against other mpi modules already loaded,
-- so only one MPI environment module can be loaded at any time.
--
conflict("pmix")

whatis("Description: PMIx {{ __hpc_pmix_info.version }} installed in /opt/pmix/{{ __hpc_pmix_info.version }}")
whatis("Version: {{ __hpc_pmix_info.version }}-1")

-- Set the base installation directory
local base_dir = "{{ __hpc_pmix_path }}"

-- Set up important paths
prepend_path("PATH", pathJoin(base_dir, "bin"))
prepend_path("LD_LIBRARY_PATH", pathJoin(base_dir, "lib"))
prepend_path("PKG_LIBRARY_PATH", pathJoin(base_dir, "lib/pkgconfig"))
prepend_path("MANPATH", pathJoin(base_dir, "share/man"))
