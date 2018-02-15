#include "crmpi.h"

const MPI_Comm kCRMPI_COMM_WORLD = MPI_COMM_WORLD;
const MPI_Comm kCRMPI_COMM_NULL = MPI_COMM_NULL;
const MPI_Comm kCRMPI_COMM_SELF = MPI_COMM_SELF;

const MPI_Group kCRMPI_GROUP_EMPTY = MPI_GROUP_EMPTY;
const MPI_Group kCRMPI_GROUP_NULL = MPI_GROUP_NULL;

const MPI_Message kCRMPI_MESSAGE_NULL = MPI_MESSAGE_NULL;
const MPI_Message kCRMPI_MESSAGE_NO_PROC = MPI_MESSAGE_NO_PROC;

const MPI_Request kCRMPI_REQUEST_NULL = MPI_REQUEST_NULL;

const MPI_Status* kCRMPI_STATUS_IGNORE = MPI_STATUS_IGNORE;
const MPI_Status* kCRMPI_STATUSES_IGNORE = MPI_STATUSES_IGNORE;

const MPI_Op kCRMPI_MAX = MPI_MAX;
const MPI_Op kCRMPI_MIN = MPI_MIN;
const MPI_Op kCRMPI_SUM = MPI_SUM;
const MPI_Op kCRMPI_PROD = MPI_PROD;
const MPI_Op kCRMPI_LAND = MPI_LAND;
const MPI_Op kCRMPI_BAND = MPI_BAND;
const MPI_Op kCRMPI_LOR = MPI_LOR;
const MPI_Op kCRMPI_BOR = MPI_BOR;
const MPI_Op kCRMPI_LXOR = MPI_LXOR;
const MPI_Op kCRMPI_BXOR = MPI_BXOR;

const MPI_Datatype kCRMPI_BOOL = MPI_C_BOOL;
const MPI_Datatype kCRMPI_FLOAT = MPI_FLOAT;
const MPI_Datatype kCRMPI_DOUBLE = MPI_DOUBLE;
const MPI_Datatype kCRMPI_INT8_T = MPI_INT8_T;
const MPI_Datatype kCRMPI_INT16_T = MPI_INT16_T;
const MPI_Datatype kCRMPI_INT32_T = MPI_INT32_T;
const MPI_Datatype kCRMPI_INT64_T = MPI_INT64_T;

const MPI_Datatype kCRMPI_UINT8_T = MPI_UINT8_T;
const MPI_Datatype kCRMPI_UINT16_T = MPI_UINT16_T;
const MPI_Datatype kCRMPI_UINT32_T = MPI_UINT32_T;
const MPI_Datatype kCRMPI_UINT64_T = MPI_UINT64_T;

const MPI_Datatype kCRMPI_DATATYPE_NULL = MPI_DATATYPE_NULL;

enum crmpi_vendor crmpi_get_vendor() {
  #if defined(MPICH_NAME)
    return VENDOR_MPICH;
  #elif defined(OPEN_MPI)
    return VENDOR_OPEN_MPI;
  //#elif defined(HP_MPI)
  //#elif defined(LAM_MPI)
  //#elif defined(PLATFORM_MPI)
  //#elif defined(MSMPI_VER)
  #else
    return VENDOR_UNKNOWN;
  #endif
}
