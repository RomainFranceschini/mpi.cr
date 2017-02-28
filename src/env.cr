module MPI
  alias Threading = LibMPI::Threading

  class Universe
    property buffer : Bytes

    def initialize
      @buffer = Bytes.empty
    end

    def initialize(@buffer : Bytes)
    end

    # Returns the *world* communicator.
    #
    # Contains all processes initially partaking in the computation.
    def world
      Communicator.world
    end

    # The size in bytes of the buffer used for buffered communication.
    def buffer_size
      @buffer.size
    end

    # Set the size in bytes of the buffer used for buffered communication.
    def buffer_size=(size : Int)
      detach_buffer
      if size > 0
        buf = Bytes.new(size)
        LibMPI.buffer_attach(buf, buf.bytesize)
        @buffer = buf
      end
    end

    # Detach the buffer used for buffered communication.
    def detach_buffer
      if @buffer.size > 0
        LibMPI.buffer_detach(@buffer, out size)
        @buffer = Bytes.empty
      end
    end

    def finalize
      unless MPI.finalized?
        detach_buffer
        LibMPI.finalize
      end
    end
  end

  # Identifies the version of the MPI standard implemented by the library.
  #
  # Returns a tuple of `{version, subversion}`, e.g. `{3,1}`.
  #
  # Can be called without initializing MPI.
  def self.version : Tuple(LibC::Int, LibC::Int)
    LibMPI.get_version(out version, out subversion)
    { version, subversion }
  end

  # Describes the version of the MPI library itself as a string.
  #
  # Can be called without initializing MPI.
  def self.library_version : String
    buf = uninitialized UInt8[LibMPI::MAX_LIBRARY_VERSION_STRING]
    LibMPI.get_library_version(buf, out len)
    String.new(buf.to_unsafe)
  end

  # Names the processor that the calling process is running on.
  def self.processor_name : String
    buf = uninitialized UInt8[LibMPI::MAX_PROCESSOR_NAME]
    LibMPI.get_processor_name(buf, out len)
    String.new(buf.to_unsafe)
  end

  # Whether the MPI library has been initialized.
  def self.initialized? : Bool
    LibMPI.initialized(out flag)
    flag != 0
  end

  # Whether the MPI library has been finalized.
  def self.finalized? : Bool
    LibMPI.finalized(out flag)
    flag != 0
  end

  # Finalize MPI.
  def self.finalize
    unless MPI.finalized?
      LibMPI.finalize
    end
  end

  # Level of multithreading supported by this MPI universe
  def self.threading_support : Threading
    LibMPI.query_thread(out res)
    Threading.new(res)
  end

  # Initialize MPI with desired level of multithreading support.
  #
  # If the MPI library has not been initialized so far, tries to initialize
  # with the desired level of multithreading support and returns the MPI
  # communication `Universe` with access to additional functions as well as
  # the level of multithreading actually supported by the
  # implementation. Otherwise returns nil.
  #
  # Examples
  # See *examples/init_with_threading.cr*
  #
  # Standard section(s)
  # 12.4.3
  def self.init(threading : Threading) : Tuple(Universe, Threading)?
    unless MPI.initialized?
      LibMPI.init_thread(nil, nil, threading, out provided)
      { Universe.new, Threading.new(provided) }
    end
  end

  # Initialize MPI.
  #
  # If the MPI library has not been initialized so far, tries to initialize
  # with the desired level of multithreading support.
  # The given block will be passed the MPI `Universe` and the actual level
  # of multithreading supported by the implementation. MPI will be automatically
  # finalized when the block returns.
  #
  # If MPI was already initialized, the block is never called.
  #
  # Standard section(s)
  #   - 12.4.3
  def self.init(threading : Threading)
    unless MPI.initialized?
      LibMPI.init_thread(nil, nil, threading, out provided)
      yield Universe.new, Threading.new(provided)
      MPI.finalize unless MPI.finalized?
    end
  end

  # Initialize MPI.
  #
  # If the MPI library has not been initialized so far, tries to initialize
  # with the desired level of multithreading support.
  # The given block will be passed the MPI `Universe`. MPI will be automatically
  # finalized when the block returns.
  #
  # If MPI was already initialized, the block is never called.
  #
  # Standard section(s)
  #   - 12.4.3
  def self.init
    self.init(Threading::Single) { |universe, _| yield(universe) }
  end

  # Initialize MPI.
  #
  # If the MPI library has not been initialized so far, initializes and
  # returns a representation of the MPI communication `Universe` which
  # provides access to additional functions. Otherwise returns `nil`.
  #
  # Equivalent to: `MPI#init(Threading::Single)`
  #
  # Examples
  # See *examples/simple.cr*
  #
  # Standard section(s)
  #   8.7
  def self.init : Universe?
    init(Threading::Single).try &.[0]
  end

  # Time in seconds since an arbitrary time in the past.
  #
  # The cheapest high-resolution timer available will be used.
  def self.time
    LibMPI.wtime
  end

  # Resolution of timer used in `MPI.time` in seconds.
  def self.time_resolution
    LibMPI.wtick
  end
end
