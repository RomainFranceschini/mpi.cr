#include <stdio.h>
#include "mpi.h"

int main(void) {
  #if defined(MPICH_NAME)
    printf("mpich");
  #elif defined(OPEN_MPI)
    printf("openmpi");
  //#elif defined(HP_MPI)
  //#elif defined(LAM_MPI)
  //#elif defined(PLATFORM_MPI)
  //#elif defined(MSMPI_VER)
  #else
    printf("unknown");
  #endif

  return 0;
}
