{{ ansible_managed | comment(decoration="-- ") }}
{{ "system_role:hpc" | comment(decoration="-- ", prefix="", postfix="") }}
-- Wrapper for NVidia HPCX OpenMPI environment
--
-- This allows the module to conflict against other mpi modules already loaded,
-- so only one MPI environment module can be loaded at any time.
--
conflict("mpi")

whatis("Description: NVidia HPCX OpemMPI")
whatis("Version: {{ __hpc_hpcx_info.version }}")

prepend_path("MODULEPATH", "{{__hpc_hpcx_path }}/modulefiles")

-- Pull in the HPCX module
load("hpcx")
