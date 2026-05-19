{{ ansible_managed | comment(decoration="-- ") }}
{{ "system_role:hpc" | comment(decoration="-- ", prefix="", postfix="") }}
-- Wrapper for NVidia HPCX OpenMPI w/ PMIx environment
--
-- This allows the module to conflict against other mpi modules already loaded,
-- so only one MPI environment module can be loaded at any time.
--
conflict("mpi")

whatis("Description: NVidia HPCX OpemMPI with PMIx {{ __hpc_pmix_info.version }} support.")
whatis("Version: {{ __hpc_hpcx_info.version }}")

prepend_path("MODULEPATH", "{{__hpc_hpcx_path }}/modulefiles")

-- dependent on PMIx {{ __hpc_pmix_info.version }} installed in /opt
load("{{ __hpc_pmix_info.name }}/{{ __hpc_pmix_info.name }}-{{ __hpc_pmix_info.version }}")

-- Pull in the HPCX module
load("hpcx-rebuild")
