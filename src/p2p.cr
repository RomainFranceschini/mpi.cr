module MPI
  def self.send_receive(msg : Pointer(T),
                        sendcount : Count,
                        dest : Destination,
                        buf : Pointer(U),
                        recvcount : Count,
                        source : Source,
                        sendtag : Tag = 0,
                        recvtag : Tag = LibMPI::ANY_TAG) : Status forall T, U
    MPI.err?(LibMPI.sendrecv(
      msg,
      sendcount,
      T.to_mpi_datatype,
      dest.destination_rank,
      sendtag,
      buf,
      recvcount,
      U.to_mpi_datatype,
      source.source_rank,
      recvtag,
      source.comm,
      out status
    ))
    Status.new(status)
  end

  def self.send_receive(msg : Array(T), dest : Destination, source : Source, sendtag : Tag = 0, recvtag : Tag = LibMPI::ANY_TAG) : {Array(T), Status} forall T
    status = uninitialized Status
    res = Array(T).build(msg.size) do |buf|
      status = self.send_receive(
        msg.to_unsafe,
        msg.size,
        dest,
        buf,
        msg.size,
        source,
        sendtag,
        recvtag
      )
      msg.size
    end

    if status.count(T.to_mpi_datatype) == 0
      raise "#{self} received an empty message"
    end

    {res, status}
  end

  def self.send_receive(msg : String, dest : Destination, source : Source, sendtag : Tag = 0, recvtag : Tag = LibMPI::ANY_TAG) : {String, Status}
    status = uninitialized Status
    str = String.new(msg.size) do |buf|
      status = self.send_receive(
        msg.to_unsafe,
        msg.bytesize,
        dest,
        buf,
        msg.bytesize,
        source,
        sendtag,
        recvtag
      )
      {msg.bytesize, 0}
    end

    if status.count(T.to_mpi_datatype) == 0
      raise "#{self} received an empty message"
    end

    {str, status}
  end

  def self.send_receive(msg : T, dest : Destination, source : Source,
                        sendtag : Tag = 0, recvtag : Tag = LibMPI::ANY_TAG) : {T, Status} forall T
    res = Pointer(T).malloc
    status = self.send_receive(
      pointerof(msg),
      1,
      dest,
      res,
      1,
      source,
      sendtag,
      recvtag
    )
    if status.count(T.to_mpi_datatype) == 0
      raise "#{self} received an empty message"
    end
    {res.value, status}
  end

  # single buffer
  def self.send_receive_replace(buf : Pointer(T),
                                count : Count,
                                dest : Destination,
                                source : Source,
                                sendtag : Tag = 0,
                                recvtag : Tag = LibMPI::ANY_TAG) : Status forall T
    MPI.err?(LibMPI.sendrecv_replace(
      buf,
      count,
      T.to_mpi_datatype,
      dest.destination_rank,
      sendtag,
      source.source_rank,
      recvtag,
      source.comm,
      out status
    ))
    Status.new(status)
  end

  def self.send_receive_replace(str : String, dest : Destination, source : Source, sendtag : Tag = 0, recvtag : Tag = LibMPI::ANY_TAG) : Status
    self.send_receive_replace(str.to_unsafe, str.bytesize, dest, source, sendtag, recvtag)
  end

  def self.send_receive_replace(buf : Slice(Equivalence) | StaticArray(Equivalence, N),
                                dest : Destination,
                                source : Source,
                                sendtag : Tag = 0,
                                recvtag : Tag = LibMPI::ANY_TAG) : Status forall N
    self.send_receive_replace(buf.to_unsafe, buf.size, dest, source, sendtag, recvtag)
  end

  # Describes a pending incoming message, probed by a `Source#matched_probe`.
  #
  # Standard section(s)
  #   - 3.8.2
  struct Message
    def self.null
      Message.new(LibMPI::MESSAGE_NULL)
    end

    def self.no_proc
      Message.new(LibMPI::MESSAGE_NO_PROC)
    end

    def initialize(@raw : LibMPI::Message)
    end

    # Whether this message results from a probe by the null process.
    def no_proc?
      @raw == LibMPI::MESSAGE_NO_PROC
    end

    # Whether this message is null.
    def null?
      @raw == LibMPI::MESSAGE_NULL
    end

    def to_unsafe
      @raw
    end

    # Receive a previously probed message containing a single instance of type
    # *T*.
    #
    # Receives the message *self* which contains a single instance of type *T*.
    #
    # Standard section(s)
    #   - 3.8.3
    def matched_receive(x : T.class) : {T, Status} forall T
      res = Pointer(T).malloc
      status = self.matched_receive(res, 1)
      if status.count(x.to_mpi_datatype) == 0
        raise "received an empty message"
      end
      {res.value, status}
    end

    # Receive a previously probed message containing *count* instances of type
    # *T* into a buffer.
    #
    # Receives the message *self* with contents matching *buf*.
    #
    # Standard section(s)
    #   - 3.8.3
    def matched_receive(buf : Pointer(T), count : Count) : Status forall T
      LibMPI.mrecv(buf, count, T.to_mpi_datatype, pointerof(@raw), out status)
      Status.new(status)
    end

    # Receive a previously probed message containing *count* instances of type
    # *T* into the given slice or static array.
    #
    # Receives the message *self* with contents matching *slice*.
    #
    # Standard section(s)
    #   - 3.8.3
    def matched_receive(slice : Slice(Equivalence) | StaticArray(Equivalence, N)) : Status forall N
      self.matched_receive(slice.to_unsafe, slice.size)
    end

    # Receive a previously probed message containing multiple instances of type
    # *T* into a newly created array.
    #
    # Standard section(s)
    #   - 3.8.3
    def matched_receive_array(x : T.class, status : Status) : {Array(T), Status} forall T
      self.matched_receive_array(x, status.count(T.to_mpi_datatype))
    end

    # Receive a previously probed message containing multiple instances of type
    # *T* into a newly created array.
    #
    # Standard section(s)
    #   - 3.8.3
    def matched_receive_array(x : T.class, count : Count) : {Array(T), Status} forall T
      status = uninitialized Status
      ary = Array(T).build(count) do |buf|
        status = self.matched_receive(buf, count)
        count
      end

      if status.count(T.to_mpi_datatype) == 0
        raise "received an empty message"
      end

      {ary, status}
    end

    # Receive a previously probed message of bytes into a newly created String.
    #
    # Standard section(s)
    #   - 3.8.3
    def matched_receive_string(status : Status) : {String, Status}
      self.matched_receive_string(status.count(UInt8.to_mpi_datatype))
    end

    # Receive a previously probed message of bytes into a newly created String.
    #
    # Standard section(s)
    #   - 3.8.3
    def matched_receive_string(count : Count) : {String, Status}
      status = uninitialized Status
      str = String.new(count) do |buf|
        status = self.matched_receive(buf, count)
        {count, 0}
      end

      if status.count(UInt8.to_mpi_datatype) == 0
        raise "received an empty message"
      end

      {str, status}
    end
  end

  # Describes the result of a point to point receive operation.
  #
  # Standard section(s)
  #   - 3.2.5
  struct Status
    def initialize(@raw : LibMPI::Status)
    end

    # The rank of the message source
    def source_rank : Rank
      @raw.source
    end

    # The message tag
    def tag : Tag
      @raw.tag
    end

    # The number of instances of the type contained in the message
    def count(datatype : Datatype) : Count
      LibMPI.get_count(pointerof(@raw), datatype, out count)
      count
    end

    # ditto
    def count(x : T.class) : Count forall T
      self.count(T.to_mpi_datatype)
    end

    def to_s(io : IO)
      io << "<Status source=" << self.source_rank.to_s(io)
      io << ", bytes=" << self.count(UInt8).to_s(io)
      io << ", tag=" << self.tag << '>'
      nil
    end

    def to_unsafe
      @raw
    end
  end

  # Something that can be used as the source in a point to point receive
  # operation.
  #
  # Examples
  # - A `Process` used as a source for a receive operation will receive data
  # only from the identified process.
  # - A communicator can also be used as a source via the `Process#any`
  # identifier.
  #
  # Standard section(s)
  #   - 3.2.3
  module Source
    # The `Rank` that identifies the source
    abstract def source_rank : Rank

    # Probe a source for incoming messages.
    #
    # Probe `Source` self for incoming messages with a certain tag.
    #
    # An ordinary `#probe` returns a `Status` which allows inspection of the
    # properties of the incoming message, but does not guarantee reception by a
    # subsequent `#receive` (especially in a multi-threaded set-up). For a probe
    # operation with stronger guarantees, see `#matched_probe`.
    #
    # Standard section(s)
    #   - 3.8.1
    def probe(tag : Tag = LibMPI::ANY_TAG) : Status
      MPI.err? LibMPI.probe(self.source_rank, tag, self.comm, out status)
      status
    end

    # Probe a source for incoming messages with guaranteed reception.
    #
    # Probe `Source` self for incoming messages with a certain tag.
    #
    # A `#matched_probe` returns both a `Status` that describes the properties
    # of a pending incoming message and a `Message` which can and *must*
    # subsequently be used in a `#matched_receive` to receive the probed
    # message.
    #
    # Standard section(s)
    #   - 3.8.2
    def matched_probe(tag : Tag = LibMPI::ANY_TAG) : {Message, Status}
      LibMPI.mprobe(self.source_rank, tag, self.comm, out msg, out status)
      {Message.new(msg), Status.new(status)}
    end

    # Receive a message containing a single instance of type *T*.
    #
    # Receive a message from `Source` self tagged `tag` containing a single
    # instance of type *T*.
    #
    # Examples
    #
    # ```
    # if universe = MPI.init
    #   world = universe.world
    #   x = world.any_process.receive(Int32)
    #   MPI.finalize
    # end
    # ```
    #
    # Standard section(s)
    #   - 3.2.4
    def receive(x : T.class, tag : Tag = LibMPI::ANY_TAG) : {T, Status} forall T
      res = Pointer(T).malloc
      status = self.receive(res, 1, tag)
      if status.count(x.to_mpi_datatype) == 0
        raise "#{self} received an empty message"
      end
      {res.value, status}
    end

    # Receive a message containing *count* instances of type *T* into a *buf*.
    #
    # Receive a message from `Source` self tagged *tag* containing *count*
    # instances of type *T* into buffer *buf*
    #
    # Standard section(s)
    #   - 3.2.4
    def receive(buf : Pointer(T), count : Count, tag : Tag = LibMPI::ANY_TAG) : Status forall T
      MPI.err? LibMPI.recv(buf, count, T.to_mpi_datatype, self.source_rank,
        tag, self.comm, out status)
      Status.new(status)
    end

    # Receive a message containing multiple instances of type *T* into the
    # given slice or static array.
    #
    # Receive a message from `Source` self tagged *tag* containing *slice.size*
    # instances of type *T* into the given slice.
    #
    # Standard section(s)
    #   - 3.2.4
    def receive(collection : Slice(Equivalence) | StaticArray(Equivalence, N), tag : Tag = LibMPI::ANY_TAG) : Status forall N
      self.receive(collection.to_unsafe, collection.size, tag)
    end

    # Receive a message containing multiple instances of type *T* into a newly
    # created array.
    #
    # Receive a message from `Source` self tagged *tag* containing multiple
    # instances of type *T* into an array.
    #
    # Standard section(s)
    #   - 3.2.4
    def receive_array(x : T.class, tag : Tag = LibMPI::ANY_TAG) : {Array(T), Status} forall T
      msg, status = self.matched_probe(tag)
      msg.matched_receive_array(x, status)
    end

    # Receive a message containing bytes into a newly created string.
    #
    # Receive a message from `Source` self tagged *tag* containing bytes
    # into a `String`.
    #
    # Standard section(s)
    #   - 3.2.4
    def receive_string(tag : Tag = LibMPI::ANY_TAG)
      msg, status = self.matched_probe(tag)
      msg.matched_receive_string(status)
    end
  end

  # Something that can be used as the destination in a point to point send
  # operation.
  #
  # Examples
  # - Using a `Process` as the destination will send data to that specific
  # process.
  #
  # Standard section(s)
  #   - 3.2.3
  module Destination
    # The `Rank` that identifies the destination.
    abstract def destination_rank : Rank

    # Blocking standard mode send operation.
    #
    # Send *count* elements of type *T* from given pointer *buf* to the
    # `Destination` self and tag it.
    #
    # Standard section(s)
    #   - 3.2.1
    def send(buf : Pointer(T), count : Count, tag : Tag = 0) forall T
      MPI.err? LibMPI.send(buf, count, T.to_mpi_datatype, self.destination_rank,
        tag, self.comm)
    end

    # Blocking standard mode send operation.
    #
    # Send contents of given collection of type *T* to the `Destination` self
    # and tag it.
    #
    # Standard section(s)
    #  - 3.2.1
    def send(col : Slice(Equivalence) | Array(Equivalence) | StaticArray(Equivalence, N), tag : Tag = 0) forall N
      self.send(col.to_unsafe, col.size, tag)
    end

    # Blocking standard mode send operation.
    #
    # Send contents of given string to the `Destination` self and tag it.
    #
    # Standard section(s)
    #  - 3.2.1
    def send(str : String, tag : Tag = 0)
      self.send(str.to_unsafe, str.bytesize, tag)
    end

    # Blocking standard mode send operation.
    #
    # Send the given *obj* to the `Destination` self and tag it.
    #
    # Examples
    #
    # ```
    # if universe = MPI.init
    #   world = universe.world
    #   x = world.process_at(0).send(42)
    #   ...
    # end
    # ```
    # See also *examples/send_receive.cr*
    #
    # Standard section(s)
    #   - 3.2.1
    def send(obj : Equivalence, tag : Tag = 0)
      self.send(pointerof(obj), 1, tag)
    end
  end

  struct Process
    include Source
    include Destination

    def source_rank : Rank
      self.rank
    end

    def destination_rank : Rank
      self.rank
    end
  end

  # struct ReceiveFuture(T)

  #   def initialize(@val : T, @req )
  # end
end
