{{ ansible_managed | comment(decoration="-- ") }}
{{ "system_role:hpc" | comment(decoration="-- ", prefix="", postfix="") }}
-- This is laregly derived from the system openmpi module file that can be
-- found at /usr/share/modulefiles/mpi/openmpi-x86-64.
--
-- This file should be installed in the same directory as the above system
-- openmpi module i.e. /usr/share/modulefiles/mpi/openmpi-5.0.8-cuda-gpu.
--
-- This allows it to conflict against other mpi modules already loaded,
-- so only one MPI environment module can be loaded at any time.
--
conflict("mpi")

whatis("Description: OpenMPI {{ __hpc_openmpi_info.version }} with NVidia GPU, CUDA 12 and PMIx {{ __hpc_pmix_info.version }} support.")
whatis("This library only works on machines with NVidia GPUs installed.")
whatis("If you don't have Infiniband, use '-mca coll ^hcoll' to silence startup warnings.")
whatis("Version: {{ __hpc_openmpi_info.version }}-1")

-- Set the base installation directory
local ompi_dir = "/opt/{{ __hpc_openmpi_info.name }}-{{ __hpc_openmpi_info.version }}"
local ucx_dir = "{{ __hpc_ucx_path }}"
local ucc_dir = "{{ __hpc_ucc_path }}"
local hcoll_dir = "{{ __hpc_hcoll_path }}"

-- Set up important paths
prepend_path("PATH", pathJoin(ompi_dir, "bin"))
prepend_path("PATH", pathJoin(ucx_dir, "bin"))
prepend_path("PATH", pathJoin(ucc_dir, "bin"))
prepend_path("PATH", pathJoin(hcoll_dir, "bin"))

prepend_path("LD_LIBRARY_PATH", pathJoin(ompi_dir, "lib"))
prepend_path("LD_LIBRARY_PATH", pathJoin(ucx_dir, "lib"))
prepend_path("LD_LIBRARY_PATH", pathJoin(ucc_dir, "lib"))
prepend_path("LD_LIBRARY_PATH", pathJoin(hcoll_dir, "lib"))

prepend_path("PKG_LIBRARY_PATH", pathJoin(ompi_dir, "lib/pkgconfig"))
prepend_path("PKG_LIBRARY_PATH", pathJoin(ucx_dir, "lib/pkgconfig"))
prepend_path("PKG_LIBRARY_PATH", pathJoin(ucc_dir, "lib/pkgconfig"))
prepend_path("PKG_LIBRARY_PATH", pathJoin(hcoll_dir, "lib/pkgconfig"))

prepend_path("MANPATH", pathJoin(ompi_dir, "share/man"))

-- Set up MPI environment variables. this is not the entire set,
-- just the important ones for building and running MPI apps.
setenv("MPI_HOME", ompi_dir)
setenv("MPI_BIN", pathJoin(ompi_dir, "bin"))
setenv("MPI_SYSCONFIG", pathJoin(ompi_dir, "etc"))
setenv("MPI_INCLUDE", pathJoin(ompi_dir, "include"))
setenv("MPI_LIB", pathJoin(ompi_dir, "lib"))
setenv("MPI_MAN", pathJoin(ompi_dir, "share/man"))
setenv("MPI_COMPILER", "{{ __hpc_openmpi_info.name }}-{{ __hpc_openmpi_info.version }}")
setenv("MPI_SUFFIX", "_{{ __hpc_openmpi_info.name }}-{{ __hpc_openmpi_info.version }}")

-- dependent on PMIx {{ __hpc_pmix_info.version }} installed in /opt
load("{{ __hpc_pmix_info.name }}/{{ __hpc_pmix_info.name }}-{{ __hpc_pmix_info.version }}")
