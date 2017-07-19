module MPI
  VERSION = "0.1.0"

  # Compatible MPI standard version.
  API_VERSION = "3.0 - 3.2"

  {% if flag?(:openmpi) %}
    VENDOR = "openmpi"
  {% elsif flag?(:mpich) %}
    VENDOR = "mpich"
  {% else %}
    VENDOR = {{ system("./src/ext/mpi_vendor").stringify }}
  {% end %}
end

require "./libmpi"

require "./errors"
require "./datatype"
require "./env"
require "./topology"
require "./request"
require "./p2p"
require "./collective"
