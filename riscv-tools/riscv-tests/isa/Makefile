#=======================================================================
# Makefile for riscv-tests/isa
#-----------------------------------------------------------------------

XLEN ?= 32

src_dir := .

include $(src_dir)/rv64ui/Makefrag
include $(src_dir)/rv64uc/Makefrag
include $(src_dir)/rv64um/Makefrag
include $(src_dir)/rv64ua/Makefrag
include $(src_dir)/rv64uf/Makefrag
include $(src_dir)/rv64ud/Makefrag
include $(src_dir)/rv64si/Makefrag
include $(src_dir)/rv64mi/Makefrag
include $(src_dir)/rv32ui/Makefrag
include $(src_dir)/rv32uc/Makefrag
include $(src_dir)/rv32um/Makefrag
include $(src_dir)/rv32ua/Makefrag
include $(src_dir)/rv32uf/Makefrag
include $(src_dir)/rv32ud/Makefrag
include $(src_dir)/rv32si/Makefrag
include $(src_dir)/rv32mi/Makefrag
#include $(src_dir)/rv32imc_0/Makefrag
#include $(src_dir)/rv32imc_1/Makefrag
#include $(src_dir)/rv32imc_2/Makefrag
include $(src_dir)/soc/Makefrag

default: all

#--------------------------------------------------------------------
# Build rules
#--------------------------------------------------------------------

RISCV_PREFIX ?= ${PWD}/../../prebuilt_tools/prefix/bin/riscv-none-embed-
RISCV_GCC ?= $(RISCV_PREFIX)gcc
RISCV_GCC_OPTS ?= -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles
RISCV_OBJDUMP ?= $(RISCV_PREFIX)objdump
RISCV_OBJDUMP_OPTS ?= --disassemble-all
RISCV_OBJCOPY ?= $(RISCV_PREFIX)objcopy -O verilog 
RISCV_OBJCOPY_OPTS ?= -O verilog 
RISCV_SIM ?= ${PWD}/../../prebuilt_tools/prefix/bin/spike

vpath %.S $(src_dir)

#------------------------------------------------------------
# Build assembly tests

%.spike.rpt: % 
	$(RISCV_SIM)  --isa=rv32imafdc -l $< >& $<.spike.rpt

%.dump: % 
	$(RISCV_OBJDUMP) $(RISCV_OBJDUMP_OPTS) $< > $@
	$(RISCV_OBJCOPY) $(RISCV_OBJCOPY_OPTS) $<   $<.verilog
	sed -i 's/@800/@000/g' $<.verilog
	sed -i 's/@200/@000/g' $<.verilog
	sed -i 's/@00002FB8/@00002000/g' $<.verilog

%.out: %
	$(RISCV_SIM) --isa=rv64gc $< 2> $@

%.out32: %
	$(RISCV_SIM) --isa=rv32gc $< 2> $@

# Defines a dynamic target for compiling an ISA test.
#
# Arguments:
#   1: ISA tests folder (e.g. `rv31ui`, `soc`, etc.).
#   2: Compiler flags. Normally conveys only architecture and ABI flags
#      (e.g. `-march=rv32i -mabi=ilp32`). Users may add extra flags for
#      include paths and others.
#   3: (optional) Extra dependencies, such as header files that ISA test
#      binaries depend on.
#   4: Environment type (e.g. `p`, `f`, etc.). The environment provides the
#      startup code and a linker script.
#
define compile_template

$$($(1)_$(4)_tests): $(1)-$(4)-%: $(1)/%.S $(3)
	$$(RISCV_GCC) $(2) $$(RISCV_GCC_OPTS) -I$(src_dir)/../env/$(4) -I$(src_dir)/macros/scalar -T$(src_dir)/../env/$(4)/link.ld $$< -o $$@
$(1)_tests += $$($(1)_$(4)_tests)

$(1)_tests_dump = $$(addsuffix .dump, $$($(1)_tests))

$(1): $$($(1)_tests_dump)

.PHONY: $(1)

tests += $$($(1)_tests)

endef

$(eval $(call compile_template,rv32ui,-march=rv32imafdc -mabi=ilp32,,p))
$(eval $(call compile_template,rv32ui,-march=rv32imafdc -mabi=ilp32,,f))
$(eval $(call compile_template,rv32uc,-march=rv32imafdc -mabi=ilp32,,p))
$(eval $(call compile_template,rv32um,-march=rv32imafdc -mabi=ilp32,,p))
$(eval $(call compile_template,rv32ua,-march=rv32imafdc -mabi=ilp32,,p))
$(eval $(call compile_template,rv32uf,-march=rv32imafdc -mabi=ilp32,,p))
$(eval $(call compile_template,rv32ud,-march=rv32imafdc -mabi=ilp32,,p))
#$(eval $(call compile_template,rv32si,-march=rv32imafdc -mabi=ilp32,,p))
$(eval $(call compile_template,rv32mi,-march=rv32imafdc -mabi=ilp32,,p))
#$(eval $(call compile_template,rv32imc_0,-march=rv32imafdc -mabi=ilp32,,p))
#$(eval $(call compile_template,rv32imc_1,-march=rv32imafdc -mabi=ilp32,,p))
#$(eval $(call compile_template,rv32imc_2,-march=rv32imafdc -mabi=ilp32,,p))
$(eval $(call compile_template,soc,-march=rv32imafdc -mabi=ilp32 -I$(src_dir)/soc,$(src_dir)/soc/soc.h,p))
ifeq ($(XLEN),64)
$(eval $(call compile_template,rv64ui,-march=rv64imafdc -mabi=lp64,,p))
$(eval $(call compile_template,rv64uc,-march=rv64imafdc -mabi=lp64,,p))
$(eval $(call compile_template,rv64um,-march=rv64imafdc -mabi=lp64,,p))
$(eval $(call compile_template,rv64ua,-march=rv64imafdc -mabi=lp64,,p))
$(eval $(call compile_template,rv64uf,-march=rv64imafdc -mabi=lp64,,p))
$(eval $(call compile_template,rv64ud,-march=rv64imafdc -mabi=lp64,,p))
$(eval $(call compile_template,rv64si,-march=rv64imafdc -mabi=lp64,,p))
$(eval $(call compile_template,rv64mi,-march=rv64imafdc -mabi=lp64,,p))
endif

tests_spike_rpt = $(addsuffix .spike.rpt, $(tests))
tests_verilog = $(addsuffix .verilog, $(tests))
tests_dump = $(addsuffix .dump, $(tests))
tests_hex = $(addsuffix .hex, $(tests))
tests_out = $(addsuffix .out, $(spike_tests))
tests32_out = $(addsuffix .out32, $(spike32_tests))

#run: $(tests_out) $(tests32_out)
run: $(tests_spike_rpt)

junk += $(tests) $(tests_spike_rpt) $(tests_verilog) $(tests_dump) $(tests_hex) $(tests_out) $(tests32_out)

#------------------------------------------------------------
# Default

all: $(tests_dump)

#------------------------------------------------------------
# Clean up

clean:
	rm -rf $(junk)
