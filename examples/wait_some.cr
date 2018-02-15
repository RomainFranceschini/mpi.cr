require "../spec/spec_helper"

REQUESTS_PER_SENDER = 10

MPI.init do |universe|
  world = universe.world
  master_proc = 0
  rank = world.rank

  if rank == master_proc
    clients_count = world.size - 1
    count = clients_count * REQUESTS_PER_SENDER
    requests = Array(MPI::Request).new(count)
    values = Pointer(Int32).malloc(count)

    (count).times { |i|
      requests << world.any_process.immediate_receive(values + i, 1)
    }

    while count > 0
      MPI::Request.wait_some(requests).each do |request_index, status|
        puts "Root received message '#{values[request_index]}' from process ##{status.source_rank}."
        assert requests[request_index].null?
        count -= 1
      end

      # Do some computations here
    end
    requests.clear
  else
    REQUESTS_PER_SENDER.times { |i| world.process_at(0).send(rank ** 2) }
  end
end
