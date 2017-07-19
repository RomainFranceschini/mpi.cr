require "../spec/spec_helper"

MPI.init do |universe|
  world = universe.world

  odd = (0...world.size).select { |x| x % 2 != 0 }
  odd_group = world.group.subgroup_including(odd)
  even_group = world.group - odd_group

  assert(
   (world.rank % 2 == 0 && even_group.rank != nil && odd_group.rank == nil) ||
   (even_group.rank == nil && odd_group.rank != nil)
  )

  my_group = odd_group.rank != nil ? odd_group : even_group
  empty_group = MPI::Group.empty

  oddness_comm = world.split_collective(my_group)
  assert !oddness_comm.null?

  assert oddness_comm.group.compare(my_group) == MPI::ComparisonResult::Ident

  odd_comm = if odd_group.rank
               world.split_collective(odd_group)
             else
               world.split_collective(empty_group)
             end

  if odd_group.rank
    assert !odd_comm.null?
    assert odd_comm.group.compare(odd_group) == MPI::ComparisonResult::Ident
  else
    assert odd_comm.null?
  end

  oddness_comm = world.split(color: MPI::Color.new(world.rank % 2))
  assert !oddness_comm.null?

  assert oddness_comm.group.compare(my_group) == MPI::ComparisonResult::Ident

  odd_comm = world.split(color: world.rank % 2 != 0 ? MPI::Color.new(0) : MPI::Color.undefined)
  if world.rank % 2 != 0
    assert !odd_comm.null?
    assert odd_comm.group.compare(odd_group) == MPI::ComparisonResult::Ident
  else
    assert odd_comm.null?
  end
end
