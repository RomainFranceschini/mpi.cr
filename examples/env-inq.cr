require "../src/mpi"

version, subversion = MPI.version
puts "MPI-#{version}.#{subversion}"
puts MPI.library_version

MPI.init
puts MPI.processor_name
MPI.finalize
