require "../spec/examples_helper"

MPI.init do |universe|
  world = universe.world
  moon = world.dup

  world.barrier
  moon.barrier

  assert world.compare(moon) == MPI::ComparisonResult::Congruent
end
