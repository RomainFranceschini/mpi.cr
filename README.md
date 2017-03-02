# mpi.cr - MPI bindings for Crystal (WIP)

The [Message Passing Interface](http://www.mpi-forum.org) (MPI) is a specification for a
message-passing style concurrency library. Implementations of MPI are often used to structure parallel computation on High Performance Computing systems. The MPI specification describes bindings for the C programming language (and through it C++) as well as for the Fortran programming language. 

This library is an attempt to provide [Crystal](https://crystal-lang.org) bindings as well. It is unashamedly inspired by [rsmpi](https://github.com/bsteinb/rsmpi), which provides MPI bindings for [Rust](https://www.rust-lang.org).

## Status

This project is a **work in progress**. The bindings follows the MPI 3.1 specification.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  zeromq:
    github: romain1189/mpi.cr
    version: 0.1.0
```

## Requirements

An implementation of the C language interface that conforms to MPI-3.1. `mpi.cr` currently support the following implementations:

- [OpenMPI][https://www.open-mpi.org] 2.0.1
- [MPICH][https://www.mpich.org] 3.2.2

Since the MPI standard leaves some details of the C API unspecified (e.g. whether to implement certain constants and even functions using preprocessor macros or native C constructs, the details of most types, ...) `mpi.cr` uses a thin *static* library written in C (see `src/ext/crmpi.c`) that tries to capture the underspecified identifiers and re-exports them with a fixed C API to generate functional low-level bindings. 

Use `make` with the optional make variables `release=1` or `debug=1` to build the static library. Note that `make release=1` is automatically executed by `shards` as a postinstall script.

## Usage

```crystal
require "mpi"

MPI.init do |universe|
  comm = universe.world
  puts "Hello, world from process #{comm.rank} of #{comm.size}!"
end
```

## Examples

See files in `examples` folder.

Use `make examples` with the optional make variables `release=true` or `debug=true` to build all examples.

Then, use `mpiexec` or `mpirun` to run examples:

```
$ mpiexec -n 4 ./build/simple
Hello, world from process 0 of 4!
Hello, world from process 1 of 4!
Hello, world from process 2 of 4!
Hello, world from process 3 of 4!
```

## Contributors

- [[romain1189]](https://github.com/[romain1189]) Romain Franceschini - creator, maintainer

## License

This software is governed by the CeCILL-C license under French law and
abiding by the rules of distribution of free software.  You can use,
modify and/ or redistribute the software under the terms of the CeCILL-C
license as circulated by CEA, CNRS and INRIA at the following URL
"http://www.cecill.info".

The fact that you are presently reading this means that you have had
knowledge of the CeCILL-C license and that you accept its terms.
