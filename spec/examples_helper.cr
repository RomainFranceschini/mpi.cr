require "../src/mpi"

macro assert(exp)
  bool = ({{exp}})
  unless bool
    puts "assertion error at #{ {{exp.filename}} }:#{ {{exp.line_number}} }."
    puts "==> \"#{ {{exp.stringify}} }\" is false"
    exit -1
  end
end
