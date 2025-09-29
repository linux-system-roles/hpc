{{ ansible_managed | comment }}
{{ "system_role:hpc" | comment(prefix="", postfix="") }}
-- This is laregly derived from the system openmpi module file that can be
-- found at /usr/share/modulefiles/mpi/openmpi-x86-64
--
-- This file should be installed in the same directory as the system as:
-- /usr/share/modulefiles/mpi/openmpi-5.0.8-cuda
--
-- This allows it to conflict against other mpi modules already loaded,
-- so only one MPI environment module can be loaded at any time.
--
conflict("mpi")

whatis("Description: OpenMPI {{ __hpc_openmpi_info.version }} with CUDA12 and PMIx {{ __hpc_pmix_info.version }} support.")
whatis("Version: {{ __hpc_openmpi_info.version }}-1")

-- Set the base installation directory
local base_dir = "/opt/{{ __hpc_openmpi_info.name }}-{{ __hpc_openmpi_info.version }}"

-- Set up important paths
prepend_path("PATH", pathJoin(base_dir, "bin"))
prepend_path("LD_LIBRARY_PATH", pathJoin(base_dir, "lib"))
prepend_path("PKG_LIBRARY_PATH", pathJoin(base_dir, "lib/pkgconfig"))
prepend_path("MANPATH", pathJoin(base_dir, "share/man"))

-- Set up MPI environment variables. this is not the entire set,
-- just the important ones for building and running MPI apps.
setenv("MPI_HOME", base_dir)
setenv("MPI_BIN", pathJoin(base_dir, "bin"))
setenv("MPI_SYSCONFIG", pathJoin(base_dir, "etc"))
setenv("MPI_INCLUDE", pathJoin(base_dir, "include"))
setenv("MPI_LIB", pathJoin(base_dir, "lib"))
setenv("MPI_MAN", pathJoin(base_dir, "share/man"))
setenv("MPI_COMPILER", "{{ __hpc_openmpi_info.name }}-{{ __hpc_openmpi_info.version }}")
setenv("MPI_SUFFIX", "_{{ __hpc_openmpi_info.name }}-{{ __hpc_openmpi_info.version }}")

-- dependent on PMIx {{ __hpc_pmix_info.version }} installed in /opt
load("{{ __hpc_pmix_path }}")
