require "../src/mpi"

MPI.init do |universe|
  world = universe.world
  moon = world.dup

  world.barrier
  moon.barrier

  raise "assertion error" unless world.compare(moon) == MPI::ComparisonResult::Congruent
end
