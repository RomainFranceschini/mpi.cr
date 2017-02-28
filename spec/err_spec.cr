require "./spec_helper"

MPI.init

describe "errors" do
  describe "err?" do
    it "does nothing if code is successful" do
      MPI.err?(LibMPI::SUCCESS).should be_nil
    end

    it "raises appropriate exception for known errors" do
      expect_raises MPI::InvalidBufferError do
        MPI.err?(LibMPI::ERR_BUFFER)
      end

      expect_raises MPI::NoMemoryError do
        MPI.err?(LibMPI::ERR_NO_MEM)
      end
    end
  end
end

MPI.finalize
