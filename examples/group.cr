require "../spec/spec_helper"

MPI.init do |universe|
  world = universe.world

  g = world.group
  # group accessors and communicator accessors agree
  assert world.size == g.size
  assert world.rank == g.rank

  # g == g
  assert g == g

  h = world.group
  # h == g
  assert g == h

  i = g | h
  # g union h == g union g == g
  assert g == i

  empty = g - h
  # g difference h == g difference g = empty Group
  assert empty == MPI::Group.empty
  assert empty.size == 0

  # g intersection empty == empty Group
  assert (g & empty).size == 0

  first_half = (0...g.size // 2).to_a

  # f and s are first and second half of g
  f = g.subgroup_including(first_half)
  s = g.subgroup_excluding(first_half)

  # f != s
  assert f != s

  # g intersection f == f
  f_ = g & f
  assert f_ == f
  # g intersection s == s
  s_ = g & s
  assert s_ == s

  # g difference s == f
  f__ = g - s
  assert f__ == f
  s__ = g - f
  # g difference f == s
  assert s__ == s

  # f union s == g
  fs = f | s
  assert fs == g

  # f intersection s == empty
  fs = f & s
  assert MPI::Group.empty == fs

  # inverting rank mappings
  rev = (0...g.size).to_a.reverse!
  r = g.subgroup_including(rev)

  assert rev[g.rank.not_nil!] == r.translate_rank(g.rank.not_nil!, g)
end
