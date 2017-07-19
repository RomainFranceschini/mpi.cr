@[Link(ldflags: "#{__DIR__}/ext/libcrmpi.a -lmpi")]
lib LibCRMPI
  $kCRMPI_COMM_WORLD : LibMPI::Comm
  $kCRMPI_COMM_SELF : LibMPI::Comm
  $kCRMPI_COMM_NULL : LibMPI::Comm

  $kCRMPI_GROUP_EMPTY : LibMPI::Group
  $kCRMPI_GROUP_NULL : LibMPI::Group

  $kCRMPI_MESSAGE_NULL : LibMPI::Message
  $kCRMPI_MESSAGE_NO_PROC : LibMPI::Message

  $kCRMPI_REQUEST_NULL : LibMPI::Request

  $kCRMPI_STATUS_IGNORE : LibMPI::Status

  $kCRMPI_MAX : LibMPI::Op
  $kCRMPI_MIN : LibMPI::Op
  $kCRMPI_SUM : LibMPI::Op
  $kCRMPI_PROD : LibMPI::Op
  $kCRMPI_LAND : LibMPI::Op
  $kCRMPI_BAND : LibMPI::Op
  $kCRMPI_LOR : LibMPI::Op
  $kCRMPI_BOR : LibMPI::Op
  $kCRMPI_LXOR : LibMPI::Op
  $kCRMPI_BXOR : LibMPI::Op

  $kCRMPI_FLOAT : LibMPI::Datatype
  $kCRMPI_DOUBLE : LibMPI::Datatype
  $kCRMPI_INT8_T : LibMPI::Datatype
  $kCRMPI_INT16_T : LibMPI::Datatype
  $kCRMPI_INT32_T : LibMPI::Datatype
  $kCRMPI_INT64_T : LibMPI::Datatype
  $kCRMPI_UINT8_T : LibMPI::Datatype
  $kCRMPI_UINT16_T : LibMPI::Datatype
  $kCRMPI_UINT32_T : LibMPI::Datatype
  $kCRMPI_UINT64_T : LibMPI::Datatype
  $kCRMPI_DATATYPE_NULL : LibMPI::Datatype
end
