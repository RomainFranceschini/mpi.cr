{% if MPI::VENDOR == "mpich" %}
  require "./libmpi/mpich"
{% elsif MPI::VENDOR == "openmpi" %}
  require "./libmpi/openmpi"
{% else %}
  {{ raise "Unknown MPI implementation. Use OpenMPI or MPICH." }}
{% end %}

require "./libcrmpi"

# :nodoc:
@[Link("mpi")]
lib LibMPI
  COMM_WORLD = LibCRMPI.kCRMPI_COMM_WORLD
  COMM_SELF  = LibCRMPI.kCRMPI_COMM_SELF
  COMM_NULL  = LibCRMPI.kCRMPI_COMM_NULL

  GROUP_EMPTY = LibCRMPI.kCRMPI_GROUP_EMPTY
  GROUP_NULL  = LibCRMPI.kCRMPI_GROUP_NULL

  MESSAGE_NULL    = LibCRMPI.kCRMPI_MESSAGE_NULL
  MESSAGE_NO_PROC = LibCRMPI.kCRMPI_MESSAGE_NO_PROC

  REQUEST_NULL = LibCRMPI.kCRMPI_REQUEST_NULL

  STATUS_IGNORE   = LibCRMPI.kCRMPI_STATUS_IGNORE
  STATUSES_IGNORE = LibCRMPI.kCRMPI_STATUSES_IGNORE

  OP_MAX  = LibCRMPI.kCRMPI_MAX
  OP_MIN  = LibCRMPI.kCRMPI_MIN
  OP_SUM  = LibCRMPI.kCRMPI_SUM
  OP_PROD = LibCRMPI.kCRMPI_PROD
  OP_LAND = LibCRMPI.kCRMPI_LAND
  OP_BAND = LibCRMPI.kCRMPI_BAND
  OP_LOR  = LibCRMPI.kCRMPI_LOR
  OP_BOR  = LibCRMPI.kCRMPI_BOR
  OP_LXOR = LibCRMPI.kCRMPI_LXOR
  OP_BXOR = LibCRMPI.kCRMPI_BXOR

  BOOL          = LibCRMPI.kCRMPI_BOOL
  FLOAT         = LibCRMPI.kCRMPI_FLOAT
  DOUBLE        = LibCRMPI.kCRMPI_DOUBLE
  INT_8_T       = LibCRMPI.kCRMPI_INT8_T
  INT_16_T      = LibCRMPI.kCRMPI_INT16_T
  INT_32_T      = LibCRMPI.kCRMPI_INT32_T
  INT_64_T      = LibCRMPI.kCRMPI_INT64_T
  UINT_8_T      = LibCRMPI.kCRMPI_UINT8_T
  UINT_16_T     = LibCRMPI.kCRMPI_UINT16_T
  UINT_32_T     = LibCRMPI.kCRMPI_UINT32_T
  UINT_64_T     = LibCRMPI.kCRMPI_UINT64_T
  DATATYPE_NULL = LibCRMPI.kCRMPI_DATATYPE_NULL

  alias Count = LibC::LongLong
  alias Offset = LibC::LongLong
  alias Aint = LibC::Long

  alias ErrCode = LibC::Int

  type File = Void*
  type TEnum = Void*
  type TCVarHandle = Void*
  type TPVarSession = Void*
  type TPVarHandle = Void*

  # Describes the various levels of multithreading that can be supported by an
  # MPI library.
  #
  # Standard section(s)
  #   - 12.4.3
  enum Threading
    # All processes partaking in the computation are single-threaded.
    Single
    # Processes may be multi-threaded, but MPI functions will only ever be
    # called from the main thread.
    Funneled
    # Processes may be multi-threaded, but calls to MPI functions will not be
    # made concurrently. The user is responsible for serializing the calls.
    Serialized
    # Processes may be multi-threaded with no restriction on the use of MPI
    # functions from the threads.
    Multiple
  end

  enum ComparisonResult
    Ident
    Congruent
    Similar
    Unequal
  end

  # Environment

  fun get_version = MPI_Get_version(version : LibC::Int*, subversion : LibC::Int*) : ErrCode
  fun get_library_version = MPI_Get_library_version(version : LibC::Char*, resultlen : LibC::Int*) : ErrCode

  fun get_processor_name = MPI_Get_processor_name(name : LibC::Char*, resultlen : LibC::Int*) : ErrCode

  fun init = MPI_Init(argc : LibC::Int*, argv : LibC::Char***) : ErrCode
  fun init_thread = MPI_Init_thread(argc : LibC::Int*, argv : LibC::Char***, required : LibC::Int, provided : LibC::Int*) : ErrCode
  fun initialized = MPI_Initialized(flag : LibC::Int*) : ErrCode

  fun finalize = MPI_Finalize : ErrCode
  fun finalized = MPI_Finalized(flag : LibC::Int*) : ErrCode

  fun query_thread = MPI_Query_thread(provided : LibC::Int*) : ErrCode

  fun buffer_attach = MPI_Buffer_attach(buffer : Void*, size : LibC::Int) : ErrCode
  fun buffer_detach = MPI_Buffer_detach(buffer_addr : Void*, size : LibC::Int*) : ErrCode

  fun wtime = MPI_Wtime : LibC::Double
  fun wtick = MPI_Wtick : LibC::Double

  fun error_string = MPI_Error_string(errorcode : ErrCode, string : LibC::Char*, resultlen : LibC::Int*) : ErrCode
  fun error_class = MPI_Error_class(errorcode : ErrCode, errorclass : LibC::Int*) : ErrCode

  fun get_address = MPI_Get_address(location : Void*, address : Aint*) : LibC::Int

  # Communicators

  fun comm_rank = MPI_Comm_rank(comm : Comm, rank : LibC::Int*) : ErrCode
  fun comm_size = MPI_Comm_size(comm : Comm, size : LibC::Int*) : ErrCode
  fun comm_compare = MPI_Comm_compare(comm1 : Comm, comm2 : Comm, result : ComparisonResult*) : ErrCode
  fun comm_dup = MPI_Comm_dup(comm : Comm, newcomm : Comm*) : ErrCode
  fun comm_group = MPI_Comm_group(comm : Comm, group : Group*) : ErrCode
  fun comm_free = MPI_Comm_free(comm : Comm*) : ErrCode
  fun comm_create_group = MPI_Comm_create_group(comm : Comm, group : Group, tag : LibC::Int, newcomm : Comm*) : ErrCode
  fun comm_create = MPI_Comm_create(comm : Comm, group : Group, newcomm : Comm*) : ErrCode
  fun comm_split = MPI_Comm_split(comm : Comm, color : LibC::Int, key : LibC::Int, newcomm : Comm*) : ErrCode
  fun abort = MPI_Abort(comm : Comm, errorcode : LibC::Int) : ErrCode

  # Requests

  fun wait = MPI_Wait(request : Request*, status : Status*) : ErrCode
  fun test = MPI_Test(request : Request*, flag : LibC::Int*, status : Status*) : ErrCode
  fun request_free = MPI_Request_free(request : Request*) : ErrCode
  fun cancel = MPI_Cancel(request : Request*) : ErrCode
  fun wait_any = MPI_Waitany(count : LibC::Int, array_of_requests : Request*, indx : LibC::Int*, status : Status*) : LibC::Int
  fun test_any = MPI_Testany(count : LibC::Int, array_of_requests : Request*, indx : LibC::Int*, flag : LibC::Int*, status : Status*) : LibC::Int
  fun wait_all = MPI_Waitall(count : LibC::Int, array_of_requests : Request*, array_of_statuses : Status*) : LibC::Int
  fun test_all = MPI_Testall(count : LibC::Int, array_of_requests : Request*, flag : LibC::Int*, array_of_statuses : Status*) : LibC::Int
  fun wait_some = MPI_Waitsome(incount : LibC::Int, array_of_requests : Request*, outcount : LibC::Int*, array_of_indices : LibC::Int*, array_of_statuses : Status*) : LibC::Int
  fun test_some = MPI_Testsome(incount : LibC::Int, array_of_requests : Request*, outcount : LibC::Int*, array_of_indices : LibC::Int*, array_of_statuses : Status*) : LibC::Int

  # Groups

  fun group_free = MPI_Group_free(group : Group*) : ErrCode
  fun group_rank = MPI_Group_rank(group : Group, rank : LibC::Int*) : ErrCode
  fun group_size = MPI_Group_size(group : Group, size : LibC::Int*) : ErrCode
  fun group_translate_ranks = MPI_Group_translate_ranks(group1 : Group, n : LibC::Int, ranks1 : LibC::Int*, group2 : Group, ranks2 : LibC::Int*) : ErrCode
  fun group_compare = MPI_Group_compare(group1 : Group, group2 : Group, result : ComparisonResult*) : ErrCode
  fun group_difference = MPI_Group_difference(group1 : Group, group2 : Group, newgroup : Group*) : ErrCode
  fun group_excl = MPI_Group_excl(group : Group, n : LibC::Int, ranks : LibC::Int*, newgroup : Group*) : ErrCode
  fun group_incl = MPI_Group_incl(group : Group, n : LibC::Int, ranks : LibC::Int*, newgroup : Group*) : ErrCode
  fun group_intersection = MPI_Group_intersection(group1 : Group, group2 : Group, newgroup : Group*) : ErrCode
  fun group_union = MPI_Group_union(group1 : Group, group2 : Group, newgroup : Group*) : ErrCode

  # Datatype

  fun type_free = MPI_Type_free(datatype : Datatype*) : ErrCode
  fun type_commit = MPI_Type_commit(datatype : Datatype*) : ErrCode
  fun type_contiguous = MPI_Type_contiguous(count : LibC::Int, oldtype : Datatype, newtype : Datatype*) : ErrCode
  fun type_vector = MPI_Type_vector(count : LibC::Int, blocklength : LibC::Int, stride : LibC::Int, oldtype : Datatype, newtype : Datatype*) : ErrCode

  # Point to point communications

  fun get_count = MPI_Get_count(status : Status*, datatype : Datatype, count : LibC::Int*) : ErrCode
  fun probe = MPI_Probe(source : LibC::Int, tag : LibC::Int, comm : Comm, status : Status*) : ErrCode
  fun mprobe = MPI_Mprobe(source : LibC::Int, tag : LibC::Int, comm : Comm, message : Message*, status : Status*) : ErrCode
  fun iprobe = MPI_Iprobe(source : LibC::Int, tag : LibC::Int, comm : Comm, flag : LibC::Int*, status : Status*) : LibC::Int
  fun improbe = MPI_Improbe(source : LibC::Int, tag : LibC::Int, comm : Comm, flag : LibC::Int*, message : Message*, status : Status*) : LibC::Int
  fun recv = MPI_Recv(buf : Void*, count : LibC::Int, datatype : Datatype, source : LibC::Int, tag : LibC::Int, comm : Comm, status : Status*) : ErrCode
  fun send = MPI_Send(buf : Void*, count : LibC::Int, datatype : Datatype, dest : LibC::Int, tag : LibC::Int, comm : Comm) : ErrCode
  fun mrecv = MPI_Mrecv(buf : Void*, count : LibC::Int, datatype : Datatype, message : Message*, status : Status*) : ErrCode
  fun sendrecv = MPI_Sendrecv(sendbuf : Void*, sendcount : LibC::Int, sendtype : Datatype, dest : LibC::Int, sendtag : LibC::Int, recvbuf : Void*, recvcount : LibC::Int, recvtype : Datatype, source : LibC::Int, recvtag : LibC::Int, comm : Comm, status : Status*) : ErrCode
  fun sendrecv_replace = MPI_Sendrecv_replace(buf : Void*, count : LibC::Int, datatype : Datatype, dest : LibC::Int, sendtag : LibC::Int, source : LibC::Int, recvtag : LibC::Int, comm : Comm, status : Status*) : ErrCode
  fun bsend = MPI_Bsend(buf : Void*, count : LibC::Int, datatype : Datatype, dest : LibC::Int, tag : LibC::Int, comm : Comm) : LibC::Int
  fun ssend = MPI_Ssend(buf : Void*, count : LibC::Int, datatype : Datatype, dest : LibC::Int, tag : LibC::Int, comm : Comm) : LibC::Int
  fun rsend = MPI_Rsend(buf : Void*, count : LibC::Int, datatype : Datatype, dest : LibC::Int, tag : LibC::Int, comm : Comm) : LibC::Int
  fun isend = MPI_Isend(buf : Void*, count : LibC::Int, datatype : Datatype, dest : LibC::Int, tag : LibC::Int, comm : Comm, request : Request*) : LibC::Int
  fun ibsend = MPI_Ibsend(buf : Void*, count : LibC::Int, datatype : Datatype, dest : LibC::Int, tag : LibC::Int, comm : Comm, request : Request*) : LibC::Int
  fun issend = MPI_Issend(buf : Void*, count : LibC::Int, datatype : Datatype, dest : LibC::Int, tag : LibC::Int, comm : Comm, request : Request*) : LibC::Int
  fun irsend = MPI_Irsend(buf : Void*, count : LibC::Int, datatype : Datatype, dest : LibC::Int, tag : LibC::Int, comm : Comm, request : Request*) : LibC::Int
  fun irecv = MPI_Irecv(buf : Void*, count : LibC::Int, datatype : Datatype, source : LibC::Int, tag : LibC::Int, comm : Comm, request : Request*) : LibC::Int
  fun imrecv = MPI_Imrecv(buf : Void*, count : LibC::Int, datatype : Datatype, message : Message*, request : Request*) : LibC::Int

  # Collective communications

  fun barrier = MPI_Barrier(comm : Comm) : ErrCode
  fun ibarrier = MPI_Ibarrier(comm : Comm, request : Request*) : ErrCode
  fun bcast = MPI_Bcast(buffer : Void*, count : LibC::Int, datatype : Datatype, root : LibC::Int, comm : Comm) : ErrCode
  fun gather = MPI_Gather(sendbuf : Void*, sendcount : LibC::Int, sendtype : Datatype, recvbuf : Void*, recvcount : LibC::Int, recvtype : Datatype, root : LibC::Int, comm : Comm) : ErrCode
  fun gatherv = MPI_Gatherv(sendbuf : Void*, sendcount : LibC::Int, sendtype : Datatype, recvbuf : Void*, recvcounts : LibC::Int*, displs : LibC::Int*, recvtype : Datatype, root : LibC::Int, comm : Comm) : ErrCode
  fun scatter = MPI_Scatter(sendbuf : Void*, sendcount : LibC::Int, sendtype : Datatype, recvbuf : Void*, recvcount : LibC::Int, recvtype : Datatype, root : LibC::Int, comm : Comm) : ErrCode
  fun scatterv = MPI_Scatterv(sendbuf : Void*, sendcounts : LibC::Int*, displs : LibC::Int*, sendtype : Datatype, recvbuf : Void*, recvcount : LibC::Int, recvtype : Datatype, root : LibC::Int, comm : Comm) : ErrCode
  fun reduce = MPI_Reduce(sendbuf : Void*, recvbuf : Void*, count : LibC::Int, datatype : Datatype, op : Op, root : LibC::Int, comm : Comm) : ErrCode
  fun reduce_local = MPI_Reduce_local(inbuf : Void*, inoutbuf : Void*, count : LibC::Int, datatype : Datatype, op : Op) : ErrCode
  fun all_gather = MPI_Allgather(sendbuf : Void*, sendcount : LibC::Int, sendtype : Datatype, recvbuf : Void*, recvcount : LibC::Int, recvtype : Datatype, comm : Comm) : ErrCode
  fun all_to_all = MPI_Alltoall(sendbuf : Void*, sendcount : LibC::Int, sendtype : Datatype, recvbuf : Void*, recvcount : LibC::Int, recvtype : Datatype, comm : Comm) : ErrCode
  fun all_reduce = MPI_Allreduce(sendbuf : Void*, recvbuf : Void*, count : LibC::Int, datatype : Datatype, op : Op, comm : Comm) : ErrCode
  fun iall_gather = MPI_Iallgather(sendbuf : Void*, sendcount : LibC::Int, sendtype : Datatype, recvbuf : Void*, recvcount : LibC::Int, recvtype : Datatype, comm : Comm, request : Request*) : LibC::Int
end
