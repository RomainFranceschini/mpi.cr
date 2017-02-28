module MPI

  # Describing an MPI datatype
  #
  # The core function of MPI is getting data from point A to point B (where A and B are e.g. single
  # processes, multiple processes, the filesystem, ...). It offers facilities to describe that data
  # (layout in memory, behavior under certain operators) that go beyound a start address and a
  # number of bytes.
  #
  # An MPI datatype describes a memory layout and semantics (e.g. in a collective reduce
  # operation). There are several pre-defined `SystemDatatype`s which directly correspond to Crystal
  # primitive types, such as *LibMPI::DOUBLE* and `Float64`. A direct relationship between a Crystal type and
  # an MPI datatype is covered by the `Equivalence` mixin. Starting from the
  # `SystemDatatype`s, the user can build various `UserDatatype`s, e.g. to describe the layout of a
  # struct (which should then implement `Equivalence`) or to intrusively describe parts of
  # an object in memory like all elements below the diagonal of a dense matrix stored in row-major
  # order.
  abstract struct Datatype
    def self.null
      self.new(LibMPI::DATATYPE_NULL)
    end

    def initialize(@raw : LibMPI::Datatype)
    end

    def null?
      @raw == LibMPI::DATATYPE_NULL
    end

    def to_unsafe
      @raw
    end
  end

  # A system datatype, e.g. *LibMPI::DOUBLE*
  #
  # Standard section(s)
  #   - 3.2.2
  struct SystemDatatype < Datatype
  end

  # A direct equivalence exists between the implementing type and an MPI
  # datatype.
  #
  # This module is intended to be mixed in the equivalent Crystal type when
  # it is extended with the `ToDatatype` module.
  # It provides a default implementation for the `#mpi_datatype` which returns
  # the corresponding MPI `Datatype`.
  #
  # Standard section(s)
  #   - 3.2.2
  module Equivalence
    # Returns the MPI `Datatype` that is equivalent to this type.
    def mpi_datatype : Datatype
      self.class.to_mpi_datatype
    end
  end

  # A direct equivalence exists between the implementing type and an MPI
  # datatype.
  #
  # This module is intended to be extended in the equivalent Crystal type so
  # that it can be converted to an MPI `Datatype` via the `#to_mpi_datatype`
  # function.
  #
  # Standard section(s)
  #   - 3.2.2
  module ToDatatype
    # Returns the MPI `Datatype` that is equivalent to this type.
    abstract def to_mpi_datatype : Datatype
  end

  macro def_mpi_equivalence(crtype, mpitype)
    {% if crtype.resolve < Value %}
      # :nodoc:
      struct ::{{crtype}}
        extend MPI::ToDatatype
        include MPI::Equivalence
        def self.to_mpi_datatype : MPI::Datatype
          MPI::SystemDatatype.new({{ mpitype }})
        end
      end
    {% else %}
      # :nodoc:
      class ::{{crtype}}
        extend MPI::ToDatatype
        include MPI::Equivalence
        def self.to_mpi_datatype : MPI::Datatype
          MPI::SystemDatatype.new({{ mpitype }})
        end
      end
    {% end %}
  end

  def_mpi_equivalence(Float32, LibMPI::FLOAT)
  def_mpi_equivalence(Float64, LibMPI::DOUBLE)

  def_mpi_equivalence(Int8, LibMPI::INT_8_T)
  def_mpi_equivalence(Int16, LibMPI::INT_16_T)
  def_mpi_equivalence(Int32, LibMPI::INT_32_T)
  def_mpi_equivalence(Int64, LibMPI::INT_64_T)

  def_mpi_equivalence(UInt8, LibMPI::UINT_8_T)
  def_mpi_equivalence(UInt16, LibMPI::UINT_16_T)
  def_mpi_equivalence(UInt32, LibMPI::UINT_32_T)
  def_mpi_equivalence(UInt64, LibMPI::UINT_64_T)

  # `Char` occupies 32-bits.
  def_mpi_equivalence(Char, LibMPI::INT_32_T)

  # A user defined MPI datatype
  #
  # Standard section(s)
  #   - 4
  struct UserDatatype < Datatype

    # Frees this datatype
    def free
      MPI.err? LibMPI.type_free(self)
      UserDatatype.null
    end

    # Constructs a new datatype by concatenating *count* repetitions of
    # *oldtype*
    #
    # Examples
    # See *examples/contiguous.cr*
    #
    # Standard section(s)
    #   - 4.1.2
    def contiguous(count : Count, oldtype : Datatype)
      MPI.err? LibMPI.type_contiguous(count, oldtype, out newtype)
      LibMPI.type_commit(newtype)
      newtype
    end

    # Construct a new datatype out of *count* blocks of *blocklength* elements
    # of *oldtype* concatenated with the start of consecutive blocks placed
    # `stride` elements apart.
    #
    # Examples
    # See *examples/vector.cr*
    #
    # Standard section(s)
    #   - 4.1.2
    def vector(count : Count, blocklength : Count, stride : Count, oldtype : Datatype)
      MPI.err? LibMPI.type_vector(count, blocklength, stride, oldtype, out newtype)
      LibMPI.type_commit(newtype)
      newtype
    end
  end
end
