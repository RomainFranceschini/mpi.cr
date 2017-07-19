require "spec"
require "../src/mpi"

macro assert(exp)
  it do
    ({{exp}}).should be_true
  end
end
