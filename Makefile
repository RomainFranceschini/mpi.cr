release ?= ## Compile in release mode
stats ?=   ## Enable statistics output
threads ?= ## Maximum number of threads to use
debug ?=   ## Add symbolic debug info
verbose ?= ## Run specs in verbose mode

OS := $(shell uname -s | tr '[:upper:]' '[:lower:]')

O := build
FLAGS := $(if $(release),--release )$(if $(stats),--stats )$(if $(threads),--threads $(threads) )$(if $(debug),-d )
VERBOSE := $(if $(verbose),-v )
SHELL = bash

## Use mpicc wrapper rather than the system C compiler.
CC = mpicc

CFLAGS += -fPIC
CFLAGS += $(if $(debug),-g -O0)
CFLAGS += $(if $(release),-O2)

LIB_CRMPI = src/ext/crmpi.c
LIB_CRMPI_OBJ = $(subst .c,.o,$(LIB_CRMPI))
LIB_CRMPI_TARGET = src/ext/libcrmpi.a

DEPS = $(LIB_CRMPI_TARGET)

EXAMPLES_SOURCES := $(shell find examples -name '*.cr')
EXAMPLES_TARGETS := $(patsubst %.cr, %, $(EXAMPLES_SOURCES))

.PHONY: all
all: deps

.PHONY: deps libcrmpi

deps: $(DEPS) ## Build dependencies

libcrmpi: $(LIB_CRMPI_TARGET)

$(LIB_CRMPI_TARGET): $(LIB_CRMPI_OBJ)
	$(AR) -rcs $@ $^

.PHONY: doc
doc: deps ## Generate mpi.cr library documentation
	@echo "Building documentation..."
	$(BUILD_PATH) crystal doc src/mpi.cr

.PHONY: examples
examples: $(DEPS) $(EXAMPLES_TARGETS)

$(EXAMPLES_TARGETS) :
	@mkdir -p $(O)
	$(BUILD_PATH) crystal build $(FLAGS) $(addsuffix .cr,$@) -o $(subst examples,$(O),$@)

.PHONY: clean
clean: ## Clean up built directories and files
	@echo "Cleaning..."
	rm -rf $(O)
	rm -rf ./doc
	rm -rf $(LIB_CRMPI_OBJ) $(LIB_CRMPI_TARGET)
	rm -rf ~/.cache/crystal/* ## Since 0.21.0, macros `run` are reused unless code changes. Clear the cache
