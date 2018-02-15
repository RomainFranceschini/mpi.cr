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
    # Returns a null request.
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

    # Wait for a communication request to finish.
    #
    # Will block execution of the calling process until the associated operation
    # has finished.
    #
    # Standard section(s)
    #   - 3.7.3
    def wait_without_status
      MPI.err? LibMPI.wait(pointerof(@raw), LibMPI::STATUS_IGNORE)
    end

    # Cancel a communication request.
    #
    # Examples
    # See *examples/immediate.cr*
    #
    # Standard section(s)
    #   - 3.8.4
    def cancel
      MPI.err? LibMPI.cancel(pointerof(@raw))
    end

    # Tests for the completion of a request.
    #
    # Returns the corresponding `Status` if the operations has
    # finished, otherwise returns *nil*.
    #
    # Examples
    # See *examples/immediate.cr*
    #
    # Standard section(s)
    #   - 3.7.3
    def test_completion : Status?
      MPI.err? LibMPI.test(pointerof(@raw), out flag, out status)
      if flag != 0 # complete
        Status.new(status)
      else
        nil
      end
    end

    # Tests for the completion of a request.
    #
    # Returns *true* if the operations has finished, otherwise returns *false*.
    def completed? : Bool
      self.test_completion != nil
    end

    def to_unsafe
      @raw
    end
  end

  # A `ReceiveFuture` represents a value of type `T` received via a
  # non-blocking receive operation.
  struct ReceiveFuture(T)
    getter request

    def initialize(@data : Pointer(T), @request : Request)
    end

    # Wait for the receive operation to finish and return the received data.
    def get : {T, Status}
      status = @request.wait
      {@data.value, status}
    end

    # Check whether the receive operation has finished.
    #
    # It the operation is complete, the received data is returned. Otherwise,
    # *nil* is returned.
    def try : {T, Status}?
      if status = @request.test_completion
        {@data.value, status}
      else
        nil
      end
    end
  end
end
