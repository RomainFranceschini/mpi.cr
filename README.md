# (WIP) mpi.cr - MPI bindings for Crystal

The [Message Passing Interface][MPI] (MPI) is a specification for a
message-passing style concurrency library. Implementations of MPI are often used to structure parallel computation on High Performance Computing systems. The MPI specification describes bindings for the C programming language (and through it C++) as well as for the Fortran programming language. 

This library is an attempt to provide [Crystal][crystal] bindings as well. It is unashamedly inspired by [rsmpi][rsmpi], which provides MPI bindings for [Rust][rust].

[MPI]: http://www.mpi-forum.org
[crystal]: https://crystal-lang.org
[rsmpi]: https://github.com/bsteinb/rsmpi

## Status

This project is a **work in progress**.

## Features

The bindings follows the MPI 3.1 specification.

## Requirements

An implementation of the C language interface that conforms to MPI-3.1. `mpi.cr` currently support the following implementations:

- [OpenMPI][OpenMPI] 2.0.1
- [MPICH][MPICH] 3.2.2

Since the MPI standard leaves some details of the C API unspecified (e.g. whether to implement certain constants and even functions using preprocessor macros or native C constructs, the details of most types, ...) `mpi.cr` uses a thin *shared* library written in C (see `crmpi.h` and `crmpi.c`) that tries to capture the underspecified identifiers and re-exports them with a fixed C API to generate functional low-level bindings.

[OpenMPI]: https://www.open-mpi.org
[MPICH]: https://www.mpich.org

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  zeromq:
    github: romain1189/mpi.cr
```

## Documentation

## Usage

```crystal
require "mpi"
```

## Examples

See files in `examples` folder.

## License

## Contribute
