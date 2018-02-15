module MPI
  # Request objects for non-blocking operations
  #
  # Non-blocking operations such as `Process#immediate_send` return request
  # objects that captures any buffers involved in the operation so as to ensure
  # proper access restrictions. In order to release the captured buffers from
  # the request objects, a completion operation such as `#wait` or
  # `#completed?` must be used on the request object.
  struct Request
    # Blocks until one of the operations associated with the given `Request`s
    # has completed.
    #
    # Returns the index associated with the completed operation, or *nil* if
    # *requests* contains no active requests.
    #
    # Standard section(s)
    #   - 3.7.5
    def self.wait_any(requests : Array(Request)) : {Int32, Status}?
      raw_requests = requests.to_unsafe.as(Pointer(LibMPI::Request))
      MPI.err? LibMPI.wait_any(requests.size, raw_requests, out index, out status)
      if index == LibMPI::UNDEFINED
        nil
      else
        {index, Status.new(status)}
      end
    end

    # Tests for the completion of either one or none of the operations
    # associated with the given `Request`s.
    #
    # Returns the index associated with the completed operation, or *nil* if
    # *requests* contains no active requests.
    #
    # Standard section(s)
    #   - 3.7.5
    def self.test_any(requests : Array(Request)) : {Int32, Status}?
      raw_requests = requests.to_unsafe.as(Pointer(LibMPI::Request))
      MPI.err? LibMPI.test_any(requests.size, raw_requests, out index, out flag, out status)

      if flag != 0 && index != LibMPI::UNDEFINED
        {index, Status.new(status)}
      else
        nil
      end
    end

    # Blocks until at least one of the operations associated with the given
    # `Request`s have completed.
    #
    # Returns an array filled with the operations that have completed.
    #
    # Examples
    # See *examples/wait_some.cr*
    #
    # Standard section(s)
    #   - 3.7.5
    def self.wait_some(requests : Array(Request)) : Array({Int32, Status})
      indices = Pointer(LibC::Int).malloc(requests.size)
      statuses = Pointer(LibMPI::Status).malloc(requests.size)
      raw_requests = requests.to_unsafe.as(Pointer(LibMPI::Request))

      MPI.err? LibMPI.wait_some(requests.size, raw_requests, out outcount, indices, statuses)

      if outcount == LibMPI::UNDEFINED
        Array({Int32, Status}).new(0)
      else
        ary = Array({Int32, Status}).new(outcount)
        outcount.times do |i|
          ary << {indices[i], Status.new(statuses[i])}
        end
        ary
      end
    end

    # Test for the completion of at least one of the operations associated with
    # the given `Request`s.
    #
    # Returns an array filled with the operations that have completed.
    #
    # Standard section(s)
    #   - 3.7.5
    def self.test_some(requests : Array(Request)) : Array({Int32, Status})
      indices = Pointer(LibC::Int).malloc(requests.size)
      statuses = Pointer(LibMPI::Status).malloc(requests.size)
      raw_requests = requests.to_unsafe.as(Pointer(LibMPI::Request))

      MPI.err? LibMPI.test_some(requests.size, raw_requests, out outcount, indices, statuses)

      if outcount == LibMPI::UNDEFINED
        Array({Int32, Status}).new(0)
      else
        ary = Array({Int32, Status}).new(outcount)
        outcount.times do |i|
          ary << {indices[i], Status.new(statuses[i])}
        end
        ary
      end
    end

    # Blocks until all operations associated with the given `Request`s complete.
    #
    # Returns an array filled with corresponding `Status`es of each request.
    #
    # Standard section(s)
    #   - 3.7.5
    def self.wait_all(requests : Array(Request)) : Array(Status)
      statuses = Pointer(LibMPI::Status).malloc(requests.size)
      raw_requests = requests.to_unsafe.as(Pointer(LibMPI::Request))

      MPI.err? LibMPI.wait_all(requests.size, raw_requests, statuses)

      ary = Array(Status).new(requests.size)
      requests.size.times do |i|
        ary << Status.new(status)
      end
      ary
    end

    # Test whether all operations associated with the given `Request`s are
    # complete.
    #
    # Returns an array filled with corresponding `Status`es of each request, or
    # *nil* if all operations are not complete.
    #
    # Standard section(s)
    #   - 3.7.5
    def self.test_all(requests : Array(Request)) : Array(Status)?
      statuses = Pointer(LibMPI::Status).malloc(requests.size)
      raw_requests = requests.to_unsafe.as(Pointer(LibMPI::Request))

      MPI.err? LibMPI.test_all(requests.size, raw_requests, out flag, statuses)

      if flag != 0
        ary = Array(Status).new(requests.size)
        requests.size.times do |i|
          ary << Status.new(status)
        end
        ary
      else
        nil
      end
    end

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

  # A `ReceiveFutureSlice` represents a slice of values of type `T` received
  # via a non-blocking receive operation.
  struct ReceiveFutureSlice(T)
    def initialize(@slice : Slice(T), @request : Request)
    end

    # Wait for the receive operation to finish and return the received slice.
    def get : {Slice(T), Status}
      status = @request.wait
      {@slice, status}
    end

    # Check whether the receive operation has finished.
    #
    # It the operation is complete, the received slice is returned. Otherwise,
    # *nil* is returned.
    def try : {T, Status}?
      if status = @request.test_completion
        {@slice, status}
      else
        nil
      end
    end
  end

  # A `ReceiveFuture` represents a string received via a
  # non-blocking operation.
  struct ReceiveFutureString
    def initialize(@data : Pointer(UInt8), @request : Request)
    end

    # Wait for the receive operation to finish and return the received data.
    def get : {String, Status}
      status = @request.wait
      {String.new(@data), status}
    end

    # Check whether the receive operation has finished.
    #
    # It the operation is complete, the received data is returned. Otherwise,
    # *nil* is returned.
    def try : {String, Status}?
      if status = @request.test_completion
        {String.new(@data), status}
      else
        nil
      end
    end
  end
end
