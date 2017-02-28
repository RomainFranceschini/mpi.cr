module MPI

  # Request objects for non-blocking operations
  #
  # Non-blocking operations such as `Process#immediate_send` return request
  # objects that borrow any buffers involved in the operation so as to ensure
  # proper access restrictions. In order to release the borrowed buffers from
  # the request objects, a completion operation such as `#wait` or
  # `#completed?` must be used on the request object.
  #
  # Unfinished features
  # - **3.7**: Nonblocking mode:
  #   - Completion, MPI_Waitany(), MPI_Waitall(), MPI_Waitsome(),
  #   MPI_Testany(), MPI_Testall(), MPI_Testsome(), MPI_Request_get_status()
  # - **3.8**:
  #   - Cancellation, MPI_Cancel(), MPI_Test_cancelled()
  struct Request
    def self.null
      Request.new(LibMPI::REQUEST_NULL)
    end

    def initialize(@raw : LibMPI::Request)
    end

    # Whether this request is null.
    def null?
      @raw == LibMPI::REQUEST_NULL
    end

    # Wait for a communication request to finish.
    #
    # Will block execution of the calling process until the associated operation
    # has finished.
    #
    # Examples
    # See *examples/immediate.cr*
    #
    # Standard section(s)
    #   - 3.7.3
    def wait : Status
      MPI.err? LibMPI.wait(pointerof(@raw), out status)
      Status.new(status)
    end

    # Cancel a communication request.
    #
    # Examples
    # See *examples/immediate.cr*
    #
    # Standard section(s)
    #   - 3.8.4
    def cancel : Bool
      MPI.err? LibMPI.cancel(self)
      MPI.err? LibMPI.request_free(pointerof(@raw))
      null?
    end

    # Tests for the completion of a request.
    #
    # Returns *true* with the corresponding `Status` if the operations has
    # finished, otherwise returns *false* with a *nil* status.
    #
    # Examples
    # See *examples/immediate.cr*
    #
    # Standard section(s)
    #   - 3.7.3
    def completed? : { Bool, Status? }
      MPI.err? LibMPI.test(self, out flag, out status)
      if flag != 0 # complete
        { true, Status.new(status) }
      else
        { false, nil }
      end
    end

    def to_unsafe
      @raw
    end
  end

end
