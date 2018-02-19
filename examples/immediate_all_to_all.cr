require "../spec/spec_helper"

MPI.init do |universe|
  world = universe.world
  rank = world.rank
  size = world.size

  u = Slice.new(size, rank)
  v, _ = world.immediate_all_to_all(u).get

  pp u, v

  assert v.each.zip((0...size).each).all? { |i, j| i == j }
end
