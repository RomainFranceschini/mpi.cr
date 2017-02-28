require "../src/mpi"

MPI.init do |universe|
  world = universe.world

  g = world.group
  # group accessors and communicator accessors agree
  raise "assertion error" unless world.size == g.size
  raise "assertion error" unless world.rank == g.rank

  # g == g
  raise "assertion error" unless g == g

  h = world.group
  # h == g
  raise "assertion error" unless g == h

  i = g | h
  # g union h == g union g == g
  raise "assertion error" unless g == i

  empty = g - h
  # g difference h == g difference g = empty Group
  raise "assertion error" unless empty == MPI::Group.empty
  raise "assertion error" unless empty.size == 0

  # g intersection empty == empty Group
  raise "assertion error" unless (g & empty).size == 0

  first_half = (0...g.size/2).to_a

  # f and s are first and second half of g
  f = g.subgroup_including(first_half)
  s = g.subgroup_excluding(first_half)

  # f != s
  raise "assertion error" unless f != s

  # g intersection f == f
  f_ = g & f
  raise "assertion error" unless f_ == f
  # g intersection s == s
  s_ = g & s
  raise "assertion error" unless s_ == s

  # g difference s == f
  f__ = g - s
  raise "assertion error" unless f__ == f
  s__ = g - f
  # g difference f == s
  raise "assertion error" unless s__ == s

  # f union s == g
  fs = f | s
  raise "assertion error" unless fs == g

  # f intersection s == empty
  fs = f & s
  raise "assertion error" unless MPI::Group.empty == fs

  # inverting rank mappings
  rev = (0...g.size).to_a.reverse!
  r = g.subgroup_including(rev)

  raise "assertion error" unless rev[g.rank.not_nil!] == r.translate_rank(g.rank.not_nil!, g)
end
