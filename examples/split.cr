require "../src/mpi"

if universe = MPI.init
  world = universe.world

  odd = (0...world.size).select { |x| x % 2 != 0 }
  odd_group = world.group.subgroup_including(odd)
  even_group = world.group - odd_group

  if !(world.rank % 2 == 0 && even_group.rank && odd_group.rank.nil? || even_group.rank.nil? && odd_group.rank)
    raise "should not happen"
  end

  my_group = odd_group.rank != nil ? odd_group : even_group
  empty_group = MPI::Group.empty

  oddness_comm = world.split_collective(my_group)
  raise "should not happen" if oddness_comm.null?

  if oddness_comm.group.compare(my_group) != MPI::ComparisonResult::Ident
    raise "my_group and oddness_comm.group should be identical"
  end

  odd_comm = if odd_group.rank
               world.split_collective(odd_group)
             else
               world.split_collective(empty_group)
             end

  if odd_group.rank
    raise "should not happen" if odd_comm.null?
    if odd_comm.group.compare(odd_group) != MPI::ComparisonResult::Ident
      raise "odd_comm.group and odd_group should be identical"
    end
  else
    raise "should not happen" if !odd_comm.null?
  end

  oddness_comm = world.split(color: MPI::Color.new(world.rank % 2))
  raise "should not happen" if oddness_comm.null?

  if oddness_comm.group.compare(my_group) != MPI::ComparisonResult::Ident
    raise "my_group and oddness_comm.group should be identical"
  end

  odd_comm = world.split(color: world.rank % 2 != 0 ? MPI::Color.new(0) : MPI::Color.undefined)
  if world.rank % 2 != 0
    raise "should not happen" if odd_comm.null?
    if odd_comm.group.compare(odd_group) != MPI::ComparisonResult::Ident
      raise "odd_comm.group and odd_group should be identical"
    end
  else
    raise "should not happen" if !odd_comm.null?
  end

  MPI.finalize
end
