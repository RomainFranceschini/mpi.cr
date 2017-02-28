require "../src/mpi"

MPI.init do |universe|
  world = universe.world

  tstart = MPI.time
  world.barrier
  tend = MPI.time

  puts "barrier took: #{tend - tstart}secs."
  puts "the clock has a resolution of #{MPI.time_resolution}secs."
end
