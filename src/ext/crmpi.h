#ifndef CRMPI_H
#define CRMPI_H
#include "mpi.h"

extern const MPI_Comm kCRMPI_COMM_WORLD;
extern const MPI_Comm kCRMPI_COMM_NULL;
extern const MPI_Comm kCRMPI_COMM_SELF;

extern const MPI_Group kCRMPI_GROUP_EMPTY;
extern const MPI_Group kCRMPI_GROUP_NULL;

extern const MPI_Message kCRMPI_MESSAGE_NULL;
extern const MPI_Message kCRMPI_MESSAGE_NO_PROC;

extern const MPI_Request kCRMPI_REQUEST_NULL;

extern const MPI_Status* kCRMPI_STATUS_IGNORE;
extern const MPI_Status* kCRMPI_STATUSES_IGNORE;

extern const MPI_Op kCRMPI_MAX;
extern const MPI_Op kCRMPI_MIN;
extern const MPI_Op kCRMPI_SUM;
extern const MPI_Op kCRMPI_PROD;
extern const MPI_Op kCRMPI_LAND;
extern const MPI_Op kCRMPI_BAND;
extern const MPI_Op kCRMPI_LOR;
extern const MPI_Op kCRMPI_BOR;
extern const MPI_Op kCRMPI_LXOR;
extern const MPI_Op kCRMPI_BXOR;

extern const MPI_Datatype kCRMPI_FLOAT;
extern const MPI_Datatype kCRMPI_DOUBLE;
extern const MPI_Datatype kCRMPI_INT8_T;
extern const MPI_Datatype kCRMPI_INT16_T;
extern const MPI_Datatype kCRMPI_INT32_T;
extern const MPI_Datatype kCRMPI_INT64_T;

extern const MPI_Datatype kCRMPI_UINT8_T;
extern const MPI_Datatype kCRMPI_UINT16_T;
extern const MPI_Datatype kCRMPI_UINT32_T;
extern const MPI_Datatype kCRMPI_UINT64_T;

extern const MPI_Datatype kCRMPI_DATATYPE_NULL;

enum crmpi_vendor {
  VENDOR_MPICH,
  VENDOR_OPEN_MPI,
  VENDOR_UNKNOWN
};

enum crmpi_vendor crmpi_get_vendor();

#endif
