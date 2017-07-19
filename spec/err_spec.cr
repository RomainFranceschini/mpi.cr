require "./spec_helper"

describe "errors" do
  describe "err?" do
    it "does nothing if code is successful" do
      MPI.init { MPI.err?(LibMPI::SUCCESS).should be_nil }
    end

    it "raises appropriate exception for known errors" do
      MPI.init do
        expect_raises MPI::Errors::InvalidBufferError do
          MPI.err?(LibMPI::ERR_BUFFER)
        end

        expect_raises MPI::Errors::NoMemoryError do
          MPI.err?(LibMPI::ERR_NO_MEM)
        end
      end
    end
  end

  describe "MPIError" do
    describe "#message" do
      it "fetch associated message from MPI library" do
        MPI.init do
          err = MPI::Errors::UnknownError.new
          err.message.should eq("Unknown error")

          err = MPI::Errors::InvalidBufferError.new
          err.message.should eq("Invalid buffer pointer")
        end
      end
    end
  end
end

