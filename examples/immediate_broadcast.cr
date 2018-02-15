require "../spec/spec_helper"

MPI.init do |universe|
  world = universe.world
  master_rank = 0
  master_proc = world.process_at(master_rank)

  x = if world.rank == master_rank
        (2 ** 10).tap { |n|
          puts "Master broadcasting value: #{n}"
        }
      else
        0
      end

  master_proc.immediate_broadcast(pointerof(x)).wait
  puts "Process #{world.rank} received value: #{x}"
  assert x == 1024

  n = 4
  a = if world.rank == master_rank
        (1..n).map { |i| 2 ** i }.tap { |a|
          puts "Master broadcasting value: #{a}"
        }
      else
        Array(Int32).new(n, 0)
      end

  master_proc.immediate_broadcast(a).wait

  puts "Process #{world.rank} received value: #{a}"
  assert a == [2, 4, 8, 16]
end
