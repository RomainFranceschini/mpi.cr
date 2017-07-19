module MPI
  alias ComparisonResult = LibMPI::ComparisonResult

  alias Count = LibC::Int

  # Identifies a certain process within a communicator
  alias Rank = LibC::Int

  # A key used when determining the rank order of processes after a
  # communicator split.
  alias Key = LibC::Int

  # Can be used to tag messages on the sender side and match on the receiver
  # side
  alias Tag = LibC::Int

  # An address in memory
  alias Address = LibMPI::Aint

  # A color used in a communicator split
  struct Color
    @raw : Int32

    # Special color of undefined value
    def self.undefined : self
      Color.new(LibMPI::UNDEFINED)
    end

    # Initialize a color tainted by the given symbol.
    def initialize(color : Symbol)
      @raw = color.to_i
    end

    # Initialize a color of a certain value
    def initialize(color : Int::Unsigned)
      @raw = color.to_i32
    end

    # Initialize a color of a certain value
    #
    # Valid values are non-negative.
    def initialize(raw : Int::Signed)
      if raw < 0 && raw != LibMPI::UNDEFINED
        raise ArgumentError.new("Value of color must be non-negative.")
      end
      @raw = raw.to_i32
    end

    def to_unsafe
      @raw
    end
  end

  # A communicator
  #
  # Standard section(s)
  #   - 6.4
  struct Communicator
    # Returns the *world* communicator.
    #
    # Contains all processes initially partaking in the computation.
    #
    # Examples
    # See *examples/simple.cr*
    def self.world
      Communicator.new(LibMPI::COMM_WORLD)
    end

    # Returns the *self* communicator.
    def self.self
      Communicator.new(LibMPI::COMM_SELF)
    end

    # Returns the *null* communicator.
    def self.null
      Communicator.new(LibMPI::COMM_NULL)
    end

    def initialize(raw : LibMPI::Comm = LibMPI::COMM_WORLD)
      @raw = raw
    end

    # Whether this communicator is a null communicator.
    def null?
      @raw == LibMPI::COMM_NULL
    end

    # Whether this communicator is the world communicator.
    def world?
      @raw == LibMPI::COMM_WORLD
    end

    # Whether this communicator is the self communicator.
    def self?
      @raw == LibMPI::COMM_SELF
    end

    # Whether this communicator is a permanent communicator.
    def permanent?
      @raw == LibMPI::COMM_NULL || @raw == LibMPI::COMM_SELF || @raw == LibMPI::COMM_WORLD
    end

    # Frees this communicator.
    #
    # Does nothing if this is a permanent communicator.
    def free : Communicator
      if permanent?
        self
      else
        MPI.err? LibMPI.comm_free(self)
        Communicator.null
      end
    end

    # Returns the `Rank` that identifies the calling process within this
    # communicator
    #
    # Examples
    # See *examples/simple.cr*
    #
    # Standard section(s)
    #   - 6.4.1
    def rank : Rank
      LibMPI.comm_rank(@raw, out rank)
      rank
    end

    # Returns the number of processes in this communicator
    #
    # Examples
    # See *examples/simple.cr*
    #
    # Standard section(s)
    #   - 6.4.1
    def size
      LibMPI.comm_size(@raw, out size)
      size
    end

    # Bundles a reference to this communicator with a specific rank into a
    # `Process`.
    #
    # Raises `ArgumentError` if given rank is not valid.
    #
    # Examples
    # See *examples/broadcast.cr*, *examples/gather.cr*,
    # *examples/send_receive.cr*
    def process_at(rank : Rank) : Process
      if rank < 0 || rank >= self.size
        raise ArgumentError.new("rank must be within #{0} and #{self.size} (given #{rank})")
      end
      Process.new(self, rank)
    end

    # Returns a `Process` for the calling process.
    def this_process : Process
      Process.new(self, self.rank)
    end

    def any_process
      Process.any(self)
    end

    # Compare two communicators.
    #
    # Returns `ComparisonResult::Ident` for identical groups and same
    # contexts, `ComparisonResult::Congruent` when groups match in constituents
    # and rank order but context differs, `ComparisonResult::Similar` when group
    # constituents match but rank order differs, `ComparisonResult::Unequal`
    # otherwise.
    #
    # Standard section(s)
    # 6.4.1
    def compare(other : Communicator) : ComparisonResult
      LibMPI.comm_compare(self, other, out res)
      res
    end

    # Duplicate a communicator.
    #
    # See *examples/duplicate.cr*
    #
    # Standard section(s)
    #   - 6.4.2
    def duplicate
      MPI.err? LibMPI.comm_dup(self, out new_comm)
      Communicator.new(new_comm)
    end

    def dup
      self.duplicate
    end

    def clone
      self.duplicate
    end

    # Split a communicator by color.
    #
    # Creates as many new communicators as distinct values of *color* are
    # given. All processes with the same value of *color* join the same
    # communicator. A process that passes the special undefined color will not
    # join a new communicator.
    #
    # Examples
    # See *examples/split.cr*
    #
    # Standard section(s)
    #   - 6.4.2
    @[AlwaysInline]
    def split(*, color : Color)
      split(color: color, key: 0)
    end

    # Split a communicator by color.
    #
    # Like `#split(color)`, but orders processes according to the value of *key*
    # in the new communicators.
    #
    # Standard section(s)
    #   - 6.4.2
    def split(*, color : Color, key : Key)
      MPI.err? LibMPI.comm_split(self, color, key, out new_comm)
      Communicator.new(new_comm)
    end

    # Split a communicator by subgroup.
    #
    # Like `#split_collective` but not a collective operation.
    #
    # Can avoid collision of concurrent calls (i.e. multithreaded) by passing
    # in distinct tags.
    #
    # Examples
    # See *examples/split.cr*
    #
    # Standard section(s)
    #   - 6.4.2
    def split(*, subgroup : Group, tag : Tag = 0)
      MPI.err? LibMPI.comm_create_group(self, subgroup, tag, out new_comm)
      Communicator.new(new_comm)
    end

    # Split a communicator collectively by given subgroup of the group of this
    # communicator.
    #
    # Proceses pass in a group that is a subgroup of the group associated with
    # the old communicator. Different processes may pass in different groups,
    # but if two groups are different, they have to be disjunct. One new
    # communicator is created for each distinct group. The new communicator is
    # returned if a process is a member of the group he passed in, otherwise
    # the null communicator is returned.
    #
    # This call is a collective operation on the old communicator so all
    # processes have to partake.
    #
    # Examples
    # See *examples/split.cr*
    #
    # Standard section(s)
    # 6.4.2
    def split_collective(subgroup : Group)
      MPI.err? LibMPI.comm_create(self, subgroup, out newcomm)
      Communicator.new(newcomm)
    end

    # Accesses the group associated with this communicator.
    def group
      MPI.err? LibMPI.comm_group(self, out group)
      Group.new(group)
    end

    # Abort program execution
    #
    # Standard section(s)
    #   - 8.7
    def abort(err_code : LibC::Int)
      LibMPI.abort(self, err_code)
    end

    def to_unsafe
      @raw
    end
  end

  struct Process
    getter comm : Communicator
    getter rank : Rank

    def self.any(comm : Communicator) : Process
      Process.new(comm, LibMPI::ANY_SOURCE)
    end

    def self.null(comm : Communicator) : Process
      Process.new(comm, LibMPI::NO_PROC)
    end

    def initialize(@comm : Communicator, @rank : Rank)
    end

    def null?
      @rank == LibMPI::NO_PROC
    end

    def any?
      @rank == LibMPI::ANY_SOURCE
    end
  end

  # A group, e.g. *LibMPI::GROUP_EMPTY*
  #
  # Standard section(s)
  #   - 6.2.1
  struct Group
    # Returns a null group.
    def self.null
      Group.new(LibMPI::GROUP_NULL)
    end

    # Returns an empty group.
    def self.empty
      Group.new(LibMPI::GROUP_EMPTY)
    end

    def initialize(@raw : LibMPI::Group)
    end

    # Whether this group is empty.
    def empty?
      @raw == LibMPI::GROUP_EMPTY
    end

    # Whether this group is null.
    def null?
      @raw == LibMPI::GROUP_NULL
    end

    # Whether this is a permanent group.
    def permanent?
      empty? || null?
    end

    # Frees this group.
    #
    # Does nothing if this is a permanent group.
    def free
      if permanent?
        self
      else
        MPI.err? LibMPI.group_free(self)
        Group.null
      end
    end

    # Returns the number of processes in this group.
    #
    # Standard section(s)
    #   - 6.3.1
    def size
      LibMPI.group_size(self, out size)
      size
    end

    # Returns the rank of this process within the group, or nil if this
    # process is not in the group.
    #
    # Standard section(s)
    #   - 6.3.1
    def rank : Rank?
      LibMPI.group_rank(self, out rank)
      if rank == LibMPI::UNDEFINED
        nil
      else
        rank
      end
    end

    # Find the rank in group *other* of the process that has rank *rank* in this
    # group.
    #
    # If the process is not a member of the other group, returns nil.
    #
    # Standard section(s)
    #   - 6.3.1
    def translate_rank(rank : Rank, other : Group)
      LibMPI.group_translate_ranks(self, 1, pointerof(rank), other, out res)
      if res == LibMPI::UNDEFINED
        nil
      else
        res
      end
    end

    # Find the ranks in group *other* of the processes that have ranks `ranks`
    # in this group.
    #
    # If a process is not a member of the other group, returns nil.
    #
    # Standard section(s)
    # 6.3.1
    def translate_ranks(ranks : Array(Rank), other : Group)
      other_ranks = Slice(Rank).new(ranks.size)
      LibMPI.group_translate_ranks(self, ranks.size, ranks, other, other_ranks)
      other_ranks.map { |r| r == LibMPI::UNDEFINED ? nil : r }
    end

    # Compare two groups.
    #
    # Returns `ComparisonResult::Ident` for identical group members in
    # identical order, `ComparisonResult::Similar` for identical group members
    # in different order, or `ComparisonResult::Unequal` otherwise.
    #
    # Standard section(s)
    #   - 6.3.1
    def compare(other : Group) : ComparisonResult
      LibMPI.group_compare(self, other, out rel)
      rel
    end

    # Equality. Returns *true* if each element in *self* is equal to each
    # corresponding element in *other*, in the same order.
    #
    # Returns *true* only if `#compare` returns `ComparisonResult::Ident`,
    # *false* otherwise.
    #
    # See also `#compare`.
    #
    def ==(other : Group)
      self.compare(other) == ComparisonResult::Ident
    end

    # Group union: constructs a new group that contains all members of this
    # first group followed by all members of the second group that are not
    # also members of the first group.
    #
    # Standard section(s)
    #   - 6.3.2
    def |(other : Group)
      MPI.err? LibMPI.group_union(self, other, out newgroup)
      Group.new(newgroup)
    end

    # Group intersection: constructs a new group that contains all processes
    # that are members of both the first and second group in the order they
    # have in the first group.
    #
    # Standard section(s)
    #   - 6.3.2
    def &(other : Group)
      MPI.err? LibMPI.group_intersection(self, other, out newgroup)
      Group.new(newgroup)
    end

    # Group difference: Constructs a new group that contains all members of the
    # first group that are not also members of the second group in the order
    # they have in the first group.
    #
    # Standard section(s)
    #   - 6.3.2
    def -(other : Group)
      MPI.err? LibMPI.group_difference(self, other, out newgroup)
      Group.new(newgroup)
    end

    # Create a subgroup of this group including only specified ranks.
    #
    # Constructs a new group where the process with rank *ranks[i]* in the old
    # group has rank *i* in the new group.
    #
    # Standard section(s)
    #   - 6.3.2
    def subgroup_including(ranks : Array(Rank))
      MPI.err? LibMPI.group_incl(self, ranks.size, ranks, out newgroup)
      Group.new(newgroup)
    end

    # Create a subgroup of this group excluding all specified ranks.
    #
    # Constructs a new group containing those processes from the old group that
    # are not mentioned in *ranks*.
    #
    # Standard section(s)
    #   - 6.3.2
    def subgroup_excluding(ranks : Array(Rank))
      MPI.err? LibMPI.group_excl(self, ranks.size, ranks, out newgroup)
      Group.new(newgroup)
    end

    def to_unsafe
      @raw
    end
  end
end
