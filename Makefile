TESTDIR := tb
SOURCEDIR := src
SOURCES := $(shell find $(SOURCEDIR) -name '*.sv')
TBFILES := $(shell find $(TESTDIR) -name '*.sv')
TOP := testbench

# Generate C++ in executable form
VERILATOR_FLAGS += -cc --exe --build
# Generate makefile dependencies (not shown as complicates the Makefile)
#VERILATOR_FLAGS += -MMD
# Optimize
VERILATOR_FLAGS += -x-assign fast --timing
# Warn abount lint issues; may not want this on less solid designs
VERILATOR_FLAGS += -Wall
# Make waveforms
VERILATOR_FLAGS += --trace
# Check SystemVerilog assertions
VERILATOR_FLAGS += --assert
# Generate coverage analysis
VERILATOR_FLAGS += --coverage

# Input files for Verilator
VERILATOR_INPUT = +incdir+include $(TBFILES) $(SOURCES)

.PHONY: all compile simulate coverage clean

all: compile simulate coverage 

compile: $(SOURCES)
	verilator $(VERILATOR_FLAGS) $(VERILATOR_INPUT)

simulate:
	@rm -rf logs
	@mkdir -p logs
	obj_dir/V$(TOP) +trace

coverage:
	@rm -rf logs/annotated
	verilator_coverage --annotate logs/annotated logs/coverage.dat

clean:
	rm -rf obj_dir logs *.log *.dmp *.vpd coverage.dat core
