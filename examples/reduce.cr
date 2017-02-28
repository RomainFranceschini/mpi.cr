require "../src/crmpi"

MPI.init do |universe|
  world = universe.world

  rank = world.rank
  size = world.size
  master_rank = 0
  master_proc = world.process_at(master_rank)

  if rank == master_rank
    sum = master_proc.master_reduce(rank, 0, MPI::Operation.sum)
    puts "rank sum: #{sum}"
    raise "assertion error" unless sum == size * (size-1) / 2
  else
    master_proc.reduce(rank, MPI::Operation.sum)
  end

  max = world.all_reduce(rank, MPI::Operation.max)
  puts "max rank: #{max}"
  raise "assertion error" unless max == size-1

  a = 0b0000111111110000u64
  b = 0b0011110000111100u64

  c = MPI.reduce_local(a, b, MPI::Operation.bitwise_and)
  puts "#{a} & #{b} = #{c}"
  raise "assertion error" unless c == 0b0000110000110000u64

  d = MPI.reduce_local(a, b, MPI::Operation.bitwise_or)
  puts "#{a} | #{b} = #{d}"
  raise "assertion error" unless d == 0b0011111111111100u64

  e = MPI.reduce_local(a, b, MPI::Operation.bitwise_xor)
  puts "#{a} ^ #{b} = #{e}"
  raise "assertion error" unless e == 0b0011001111001100u64


end
