@[Link(ldflags: "-L/Users/romain/Documents/Dev/crystal/mpi.cr/crmpi/lib -lcrmpi")]
lib LibCRMPI
  enum Vendor
    MPICH
    OPEN_MPI
    UNKNOWN
  end

  fun get_vendor = crmpi_get_vendor : Vendor
end

case LibCRMPI.get_vendor
when LibCRMPI::Vendor::OPEN_MPI
  print "open_mpi"
when LibCRMPI::Vendor::MPICH
  print "mpich"
else
  print "unknown"
end
