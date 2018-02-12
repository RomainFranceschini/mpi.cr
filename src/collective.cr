module MPI
  # Applies a reduction operator to local arguments.
  #
  # Examples
  # See examples/reduce.cr
  #
  # Standard section(s)
  #   5.9.7
  def self.reduce_local(inbuf : Pointer(T), inoutbuf : Pointer(U), count : Count, op : Operation) forall T, U
    MPI.err?(LibMPI.reduce_local(inbuf, inoutbuf, count, T.to_mpi_datatype, op))
  end

  # ditto
  def self.reduce_local(sendbuf : Slice(T) | Array(T) | StaticArray(T, N), op : Operation) : Slice(T) forall T, N
    slice = Slice(T).new(sendbuf.size)
    self.reduce_local(sendbuf, slice.to_unsafe, sendbuf.size, op)
    slice
  end

  # ditto
  def self.reduce_local(str : String, op : Operation) : String
    String.new(str.size) do |buf|
      self.reduce_local(str.to_unsafe, buf, str.bytesize, op)
    end
  end

  # ditto
  def self.reduce_local(x : T, op : Operation) : T forall T
    ptr = Pointer(T).malloc
    self.reduce_local(pointerof(x), ptr, 1, op)
    ptr.value
  end

  # ditto
  def self.reduce_local(x : T, r : T, op : Operation) : T forall T
    self.reduce_local(pointerof(x), pointerof(r), 1, op)
    r
  end

  struct Communicator
    # Barrier synchronization among all processes in a `Communicator`
    #
    # Partake in a barrier synchronization across all processes in this
    # communicator
    #
    # Calling processes (or threads within the calling processes) will enter
    # the barrier and block execution until all processes in this communicator
    # have entered the barrier.
    #
    # Examples
    # See *examples/barrier.cr*
    #
    # Standard section(s)
    #   - 5.3
    def barrier
      LibMPI.barrier(self)
    end

    # Non-blocking barrier synchronization among all processes in a
    # `Communicator`
    #
    # Calling processes (or threads within the calling processes) enter the
    # barrier. Completion methods on the associated request object will block
    # until all processes have entered.
    #
    # Examples
    # See *examples/immediate_barrier.cr*
    #
    # Standard section(s)
    #   5.12.1
    def immediate_barrier : Request
      LibMPI.ibarrier(self, out request)
      Request.new(request)
    end

    # Gather contents of buffers on all participating processes.
    #
    # After the call completes, the contents of the send buffer on all
    # processes will be concatenated into the receive buffer on all ranks.
    #
    # All send buffers must contain the same count of elements.
    #
    # Examples
    # See *examples/all_gather.rs*
    #
    # Standard section(s)
    #   5.7
    def all_gather(sendbuf : Pointer(T), sendcount : Count, recvbuf : Pointer(U), recvcount : Count) forall T, U
      MPI.err?(LibMPI.all_gather(
        sendbuf,
        sendcount,
        T.to_mpi_datatype,
        recvbuf,
        recvcount / self.size,
        U.to_mpi_datatype,
        self
      ))
    end

    # ditto
    def all_gather(sendbuf : Slice(T) | Array(T) | StaticArray(T, N), recvcount : Count, recvtype : U.class) : Slice(T) forall T, U, N
      slice = Slice(U).new(recvcount)
      self.all_gather(sendbuf.to_unsafe, sendbuf.size, slice.to_unsafe, slice.size)
      slice
    end

    # ditto
    def all_gather(sendbuf : Slice(T) | Array(T) | StaticArray(T, N), recvcount : Count) : Slice(T) forall T, N
      self.all_gather(sendbuf, recvcount, T)
    end

    # ditto
    def all_gather(str : String, recvcount : Count) : String
      String.new(recvcount) do |recvbuf|
        self.all_gather(str.to_unsafe, str.bytesize, recvbuf, recvcount)
      end
    end

    # ditto
    def all_gather(x : T, recvcount) : Slice(T) forall T
      slice = Slice(T).new(recvcount)
      self.all_gather(pointerof(x), 1, slice.to_unsafe, slice.size)
      slice
    end

    # Distribute the send buffers from all processes to the receive buffers on
    # all processes.
    #
    # Each process sends and receives the same count of elements to and from
    # each process.
    #
    # Examples
    # See *examples/all_to_all.cr*
    #
    # Standard section(s)
    #   5.8
    def all_to_all(sendbuf : Pointer(T), sendcount : Count, recvbuf : Pointer(U), recvcount : Count) forall T, U
      size = self.size
      MPI.err?(LibMPI.all_to_all(
        sendbuf,
        sendcount / size,
        T.to_mpi_datatype,
        recvbuf,
        recvcount / size,
        U.to_mpi_datatype,
        self
      ))
    end

    # ditto
    def all_to_all(sendbuf : Slice(T) | Array(T) | StaticArray(T, N), recvcount : Count, recvtype : U.class) : Slice(T) forall T, U, N
      slice = Slice(U).new(recvcount)
      self.all_to_all(sendbuf.to_unsafe, sendbuf.size, slice.to_unsafe, slice.size)
      slice
    end

    # ditto
    def all_to_all(sendbuf : Slice(T) | Array(T) | StaticArray(T, N), recvcount : Count) : Slice(T) forall T, N
      self.all_to_all(sendbuf, recvcount, T)
    end

    # ditto
    def all_to_all(str : String, recvcount : Count) : String
      String.new(recvcount) do |recvbuf|
        self.all_to_all(str.to_unsafe, str.bytesize, recvbuf, recvcount)
      end
    end

    # ditto
    def all_to_all(x : T, recvcount) : Slice(T) forall T
      slice = Slice(T).new(recvcount)
      self.all_to_all(pointerof(x), 1, slice.to_unsafe, slice.size)
      slice
    end

    # Performs a global reduction under the given operation of the input data
    # in *sendbuf* and stores the result in *recvbuf* on all processes.
    #
    # Examples
    # See `examples/reduce.cr`
    #
    # Standard section(s)
    #    5.9.6
    def all_reduce(sendbuf : Pointer(T), recvbuf : Pointer(T), count : Count, op : Operation) forall T
      MPI.err?(LibMPI.all_reduce(
        sendbuf,
        recvbuf,
        count,
        T.to_mpi_datatype,
        op,
        self
      ))
    end

    # ditto
    def all_reduce(sendbuf : Slice(T) | Array(T) | StaticArray(T, N), op : Operation) : Slice(T) forall T, N
      slice = Slice(T).new(sendbuf.size)
      self.all_reduce(sendbuf, slice.to_unsafe, sendbuf.size, op)
      slice
    end

    # ditto
    def all_reduce(str : String, op : Operation) : String
      String.new(str.size) do |buf|
        self.all_reduce(str.to_unsafe, buf, str.bytesize, op)
      end
    end

    # ditto
    def all_reduce(x : T, op : Operation) : T forall T
      ptr = Pointer(T).malloc
      self.all_reduce(pointerof(x), ptr, 1, op)
      ptr.value
    end
  end

  # Something that can take the role of *master* in a collective operation.
  #
  # Many collective operations define a master process that takes a special
  # role in the communication. These collective operations are implemented as
  # default methods of this module.
  module Master
    # The `Rank` of the master process
    abstract def master_rank : Rank

    # Broadcast of the contents of a buffer.
    #
    # After the call completes, the buffer on all processes in the
    # `Communicator` of `Master` will contain what it contains on self.
    #
    # Examples
    # See *examples/broadcast.cr*
    #
    # Standard section(s)
    # 5.4
    def broadcast(buf : Pointer(T), count : Count) forall T
      MPI.err? LibMPI.bcast(buf, count, T.to_mpi_datatype, self.master_rank, self.comm)
    end

    # ditto
    def broadcast(buf : Slice(T) | StaticArray(T, N) | Array(T)) forall T, N
      self.broadcast(buf.to_unsafe, buf.size)
    end

    # ditto
    def broadcast(str : String)
      self.broadcast(str.to_unsafe, str.bytesize)
    end

    # ditto
    def broadcast(x : T) : T forall T
      self.broadcast(pointerof(x), 1)
      x
    end

    # Gather contents of buffers on `Master`.
    #
    # After the call completes, the contents of the `Master`s on all ranks will
    # be concatenated into the buffer on `Master`.
    #
    # All send buffers must have the same count of elements.
    #
    # This function *must* be called on all non-master processes.
    #
    # Examples
    # See *examples/gather.cr*
    #
    # Standard section(s)
    # 5.5
    def gather(buf : Pointer(T), count : Count) forall T
      if self.comm.rank == self.master_rank
        raise "#gather must be called on non-master processes."
      end
      MPI.err? LibMPI.gather(buf, count, T.to_mpi_datatype, nil, 0, UInt8.to_mpi_datatype, self.master_rank, self.comm)
    end

    # ditto
    def gather(buf : Slice(T) | StaticArray(T, N) | Array(T)) forall T
      self.gather(buf.to_unsafe, buf.size)
    end

    # ditto
    def gather(buf : String) forall T
      self.gather(buf.to_unsafe, buf.bytesize)
    end

    # ditto
    def gather(x : T) forall T
      self.gather(pointerof(x), 1)
    end

    # Gather contents of buffers on `Master`.
    #
    # After the call completes, the contents of the buffers on all ranks will
    # be concatenated into the buffer on `Master`.
    #
    # All send buffers must have the same count of elements.
    #
    # This function *must* be called on the master process.
    #
    # Examples
    # See *examples/gather.cr*
    #
    # Standard section(s)
    # 5.5
    def master_gather(sendbuf : Pointer(T), sendcount : Count, recvbuf : Pointer(U), recvcount : Count) forall T, U
      if self.comm.rank != self.master_rank
        raise "#master_gather must be called on the master process."
      end
      recvcount = recvcount / self.comm.size
      MPI.err? LibMPI.gather(sendbuf, sendcount, T.to_mpi_datatype, recvbuf, recvcount, U.to_mpi_datatype, self.master_rank, self.comm)
    end

    # ditto
    def master_gather(sendbuf : Slice(T) | Array(T) | StaticArray(T, N), recvcount : Count) : Slice(T) forall T, N
      slice = Slice(T).new(recvcount)
      self.master_gather(sendbuf.to_unsafe, sendbuf.size, slice.to_unsafe, slice.size)
      slice
    end

    def master_gather(sendbuf : Slice(T) | Array(T) | StaticArray(T, N), recvcount : Count, recvtype : U.class) : Slice(U) forall T, N, U
      slice = Slice(U).new(recvcount)
      self.master_gather(sendbuf.to_unsafe, sendbuf.size, slice.to_unsafe, slice.size)
      slice
    end

    # ditto
    def master_gather(str : String, recvcount : Count) : String
      String.new(recvcount) do |recvbuf|
        self.master_gather(str.to_unsafe, str.bytesize, recvbuf, recvcount)
      end
    end

    # ditto
    def master_gather(x : T.class, recvcount) : Slice(T)
      slice = Slice(T).new(recvcount)
      self.master_gather(pointerof(x), 1, slice.to_unsafe, slice.size)
      slice
    end

    # Scatter contents of a buffer on the root process to all processes.
    #
    # After the call completes, each participating process will have received
    # a part of the send buffer from the master process.
    #
    # All send buffers must have the same count of elements.
    #
    # This function *must* be called on all non-master processes.
    #
    # Examples
    # See *examples/scatter.cr*
    #
    # Standard section(s)
    # 5.6
    def scatter(buf : Pointer(T), count : Count) forall T
      if self.comm.rank == self.master_rank
        raise "#scatter must be called on non-master processes."
      end
      MPI.err?(LibMPI.scatter(
        nil,
        0,
        UInt8.to_mpi_datatype,
        buf,
        count,
        T.to_mpi_datatype,
        self.master_rank,
        self.comm
      ))
    end

    def scatter(x : T.class) : T forall T
      res = Pointer(T).malloc
      self.scatter(res, 1)
      res.value
    end

    # ditto
    def scatter(buf : Slice(Equivalence) | StaticArray(Equivalence, N)) forall T
      self.scatter(buf.to_unsafe, buf.size)
    end

    # ditto
    def scatter_array(x : T.class, recvcount : Count) : Array(T) forall T
      Array(T).build(recvcount) do |buf|
        self.scatter(buf, recvcount)
      end
    end

    # ditto
    def scatter_string(recvcount : Count) : String
      String.new(recvcount) do |buf|
        self.scatter(buf, recvcount)
      end
    end

    # ditto
    def scatter_slice(x : T.class, recvcount : Count) : Slice(T) forall T
      slice = Slice(T).new(recvcount)
      self.scatter(slice.to_unsafe, recvcount)
      slice
    end

    # Scatter contents of buffers on `Master`.
    #
    # After the call completes, each participarting process will have received
    # a part of the send buffer from the `Master` process.
    #
    # All receive buffers must have the same count of elements.
    #
    # This function *must* be called on the master process.
    #
    # Examples
    # See *examples/scatter.cr*
    #
    # Standard section(s)
    # 5.6
    def master_scatter(sendbuf : Pointer(T), sendcount : Count, recvbuf : Pointer(U), recvcount : Count) forall T, U
      if self.comm.rank != self.master_rank
        raise "#master_scatter must be called on the master process."
      end
      sendcount = sendcount / self.comm.size
      MPI.err?(LibMPI.scatter(
        sendbuf,
        sendcount,
        T.to_mpi_datatype,
        recvbuf,
        recvcount,
        U.to_mpi_datatype,
        self.master_rank,
        self.comm
      ))
    end

    # ditto
    def master_scatter(sendbuf : Slice(T) | Array(T) | StaticArray(T, N), recvcount : Count) : Slice(T) forall T
      slice = Slice(T).new(recvcount)
      self.master_scatter(sendbuf.to_unsafe, sendbuf.size, slice.to_unsafe, slice.size)
      slice
    end

    # ditto
    def master_scatter(str : String, recvcount : Count) : String
      String.new(recvcount) do |recvbuf|
        self.master_scatter(str.to_unsafe, str.bytesize, recvbuf, recvcount)
      end
    end

    # ditto
    def master_scatter(sendbuf : Slice(T) | Array(T) | StaticArray(T, N)) : T forall T
      ptr = Pointer(T).malloc
      self.master_scatter(sendbuf.to_unsafe, sendbuf.size, ptr, 1)
      ptr.value
    end

    # Performs a global reduction under the operation *op* of the input data in
    # *buf* and stores the result on the `Master` process.
    #
    # This function *must* be called on all non-master processes.
    #
    # Examples
    # See *examples/reduce.cr*
    #
    # Standard section(s)
    # 5.9.1
    def reduce(buf : Pointer(T), count : Count, op : Operation) forall T
      if self.comm.rank == self.master_rank
        raise "#reduce must be called on non-master processes."
      end
      MPI.err?(LibMPI.reduce(
        buf,
        nil,
        count,
        T.to_mpi_datatype,
        op,
        self.master_rank,
        self.comm
      ))
    end

    # ditto
    def reduce(buf : Slice(T) | StaticArray(T, N), op : Operation) forall T
      self.reduce(buf.to_unsafe, buf.size, op)
    end

    # ditto
    def reduce(buf : String, op : Operation) forall T
      self.reduce(buf.to_unsafe, buf.bytesize, op)
    end

    # ditto
    def reduce(x : T, op : Operation) forall T
      self.reduce(pointerof(x), 1, op)
      x
    end

    # Performs a global reduction under the operation *op* of the input data in
    # *sendbuf* and stores the result on the `Master` process.
    #
    # This function *must* be called on the master process.
    #
    # Examples
    # See *examples/reduce.cr*
    #
    # Standard section(s)
    # 5.9.1
    def master_reduce(sendbuf : Pointer(T), recvbuf : Pointer(T), count : Count, op : Operation) forall T
      if self.comm.rank != self.master_rank
        raise "#master_reduce must be called on the master process."
      end
      MPI.err?(LibMPI.reduce(
        sendbuf,
        recvbuf,
        count,
        T.to_mpi_datatype,
        op,
        self.master_rank,
        self.comm
      ))
    end

    # ditto
    def master_reduce(sendbuf : Slice(T) | Array(T) | StaticArray(T, N), op : Operation) : Slice(T) forall T, N
      slice = Slice(T).new(sendbuf.size)
      self.master_reduce(sendbuf, slice.to_unsafe, sendbuf.size, op)
      slice
    end

    # ditto
    def master_reduce(str : String, op : Operation) : String
      String.new(str.size) do |buf|
        self.master_reduce(str.to_unsafe, buf, str.bytesize, op)
      end
    end

    # ditto
    def master_reduce(x : T, op : Operation) : T forall T
      ptr = Pointer(T).malloc
      self.master_reduce(pointerof(x), ptr, 1, op)
      ptr.value
    end

    # ditto
    def master_reduce(x : T, r : T, op : Operation) : T forall T
      self.master_reduce(pointerof(x), pointerof(r), 1, op)
      r
    end
  end

  struct Process
    include Master

    def master_rank : Rank
      self.rank
    end
  end

  # An operation to be used in a reduction or scan type operation.
  struct Operation
    macro builtin_op(op, mpiop)
      def self.{{op.id}} : self
        Operation.new({{mpiop}})
      end

      def {{op.id}}?
        @raw == {{mpiop}}
      end
    end

    builtin_op max, LibMPI::OP_MAX
    builtin_op min, LibMPI::OP_MIN
    builtin_op sum, LibMPI::OP_SUM
    builtin_op product, LibMPI::OP_PROD
    builtin_op logical_and, LibMPI::OP_LAND
    builtin_op bitwise_and, LibMPI::OP_BAND
    builtin_op logical_or, LibMPI::OP_LOR
    builtin_op bitwise_or, LibMPI::OP_BOR
    builtin_op logical_xor, LibMPI::OP_LXOR
    builtin_op bitwise_xor, LibMPI::OP_BXOR

    # Max operation
    MAX = self.max

    # Min operation
    MIN = self.min

    # Sum operation
    SUM = self.sum

    # Product operation
    PROD = self.product

    # Logical AND operation
    LAND = self.logical_and

    # Bitwise AND operation
    BAND = self.bitwise_and

    # Logical OR operation
    LOR = self.logical_or

    # Bitwise OR operation
    BOR = self.bitwise_or

    # Logical XOR operation
    LXOR = self.logical_xor

    # Bitwise XOR operation
    BXOR = self.bitwise_xor

    def initialize(@raw : LibMPI::Op)
    end

    def to_unsafe
      @raw
    end
  end
end
