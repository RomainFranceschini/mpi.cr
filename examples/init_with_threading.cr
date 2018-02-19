require "../spec/spec_helper"

MPI.init(MPI::Threading::Multiple) do |universe|
  assert MPI::Threading::Multiple == MPI.threading_support
  puts "Supported level of threading #{MPI.threading_support}"
end
