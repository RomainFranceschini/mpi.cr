require "../src/crmpi"

if universe = MPI.init
  comm = universe.world
  puts "Hello, world from process #{comm.rank} of #{comm.size}!"
end

MPI.finalize
