module MPI
  @[AlwaysInline]
  def self.err?(code)
    Errors.err?(code)
  end

  module Errors
    abstract class MPIError < Exception
      ERR_CODE = LibMPI::ERR_UNKNOWN

      def message : String?
        @message ||= begin
          buf = uninitialized UInt8[LibMPI::MAX_ERROR_STRING]
          err = LibMPI.error_string(ERR_CODE, buf, out len)
          if err == LibMPI::SUCCESS
            String.new(buf.to_unsafe)
          else
            nil
          end
        end
      end

      # Converts an error code into an error class
      def error_class
        LibMPI.error_string(ERR_CODE, out errclass)
        MPI.err_class(errclass).new(cause: self)
      end

      def to_unsafe
        ERR_CODE
      end
    end

    macro def_mpi_exception(exception, mpierror)
      class {{exception}} < MPIError
        ERR_CODE = {{mpierror}}
      end
    end

    def_mpi_exception(InvalidBufferError, LibMPI::ERR_BUFFER)
    def_mpi_exception(InvalidArgumentCountError, LibMPI::ERR_COUNT)
    def_mpi_exception(InvalidTypeError, LibMPI::ERR_TYPE)
    def_mpi_exception(InvalidTagError, LibMPI::ERR_TAG)
    def_mpi_exception(CommError, LibMPI::ERR_COMM)
    def_mpi_exception(InvalidRankError, LibMPI::ERR_RANK)
    def_mpi_exception(InvalidRootError, LibMPI::ERR_ROOT)
    def_mpi_exception(TruncatedMessageError, LibMPI::ERR_TRUNCATE)
    def_mpi_exception(InvalidGroupError, LibMPI::ERR_GROUP)
    def_mpi_exception(InvalidOperationError, LibMPI::ERR_OP)
    def_mpi_exception(InvalidRequestError, LibMPI::ERR_REQUEST)
    def_mpi_exception(InvalidTopologyError, LibMPI::ERR_TOPOLOGY)
    def_mpi_exception(InvalidDimensionError, LibMPI::ERR_DIMS)
    def_mpi_exception(InvalidArgumentError, LibMPI::ERR_ARG)
    def_mpi_exception(OtherError, LibMPI::ERR_OTHER)
    def_mpi_exception(UnknownError, LibMPI::ERR_UNKNOWN)
    def_mpi_exception(InternalError, LibMPI::ERR_INTERN)
    def_mpi_exception(InStatusError, LibMPI::ERR_IN_STATUS)
    def_mpi_exception(PendingRequestError, LibMPI::ERR_REQUEST)
    def_mpi_exception(AccessError, LibMPI::ERR_ACCESS)
    def_mpi_exception(AModeError, LibMPI::ERR_AMODE)
    def_mpi_exception(BadFileError, LibMPI::ERR_BAD_FILE)
    def_mpi_exception(ConversionError, LibMPI::ERR_CONVERSION)
    def_mpi_exception(DupDataRep, LibMPI::ERR_DUP_DATAREP)
    def_mpi_exception(FileExistsError, LibMPI::ERR_FILE_EXISTS)
    def_mpi_exception(FileInUseError, LibMPI::ERR_FILE_IN_USE)
    def_mpi_exception(FileError, LibMPI::ERR_FILE)
    def_mpi_exception(IOError, LibMPI::ERR_IO)
    def_mpi_exception(NoSpaceError, LibMPI::ERR_NO_SPACE)
    def_mpi_exception(NoSuchFileError, LibMPI::ERR_NO_SUCH_FILE)
    def_mpi_exception(ReadOnlyError, LibMPI::ERR_READ_ONLY)
    def_mpi_exception(UnsupportedDataRepError, LibMPI::ERR_UNSUPPORTED_DATAREP)
    def_mpi_exception(InfoError, LibMPI::ERR_INFO)
    def_mpi_exception(InfoKeyError, LibMPI::ERR_INFO_KEY)
    def_mpi_exception(InfoValueError, LibMPI::ERR_INFO_VALUE)
    def_mpi_exception(InfoNoKeyError, LibMPI::ERR_INFO_NOKEY)
    def_mpi_exception(NameError, LibMPI::ERR_NAME)
    def_mpi_exception(NoMemoryError, LibMPI::ERR_NO_MEM)
    def_mpi_exception(NotSameError, LibMPI::ERR_NOT_SAME)
    def_mpi_exception(PortError, LibMPI::ERR_PORT)
    def_mpi_exception(QuotaError, LibMPI::ERR_QUOTA)
    def_mpi_exception(ServiceError, LibMPI::ERR_SERVICE)
    def_mpi_exception(SpawnError, LibMPI::ERR_SPAWN)
    def_mpi_exception(UnsupportedOperationError, LibMPI::ERR_UNSUPPORTED_OPERATION)
    def_mpi_exception(WinError, LibMPI::ERR_WIN)
    def_mpi_exception(BaseError, LibMPI::ERR_BASE)
    def_mpi_exception(LockTypeError, LibMPI::ERR_LOCKTYPE)
    def_mpi_exception(KeyValueError, LibMPI::ERR_KEYVAL)
    def_mpi_exception(RMAConflictError, LibMPI::ERR_RMA_CONFLICT)
    def_mpi_exception(RMASyncError, LibMPI::ERR_RMA_SYNC)
    def_mpi_exception(SizeError, LibMPI::ERR_SIZE)
    def_mpi_exception(DispError, LibMPI::ERR_DISP)
    def_mpi_exception(AssertError, LibMPI::ERR_ASSERT)
    def_mpi_exception(RMARangeError, LibMPI::ERR_RMA_RANGE)
    def_mpi_exception(RMAAttachError, LibMPI::ERR_RMA_ATTACH)
    def_mpi_exception(RMASharedError, LibMPI::ERR_RMA_SHARED)
    def_mpi_exception(RMAFlavorError, LibMPI::ERR_RMA_FLAVOR)

    @@code_to_class = Hash(LibMPI::ErrCode, MPIError.class).new

    def self.err_class(code : LibMPI::ErrCode)
      unless code == LibMPI::SUCCESS
        @@code_to_class.fetch(code) do
          raise ArgumentError.new("unknown error code: #{code}")
        end
      end
    end

    def self.err?(code : LibMPI::ErrCode)
      unless code == LibMPI::SUCCESS
        klass = @@code_to_class.fetch(code) do
          raise ArgumentError.new("unknown error code: #{code}")
        end
        raise klass.new
      end
    end

    {% for klass in MPIError.subclasses %}
      @@code_to_class[{{klass.constant("ERR_CODE")}}] = {{ klass }}
    {% end %}
  end
end
