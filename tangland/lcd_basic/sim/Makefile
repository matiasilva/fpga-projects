SIM ?= icarus
TOPLEVEL_LANG ?= verilog

PROJ_ROOT := $(ROOT)/hdl
VERILOG_SOURCES += $(PROJ_ROOT)/lcd_st7789v3.v
VERILOG_INCLUDE_DIRS += $(PROJ_ROOT)
TOPLEVEL ?= lcd_st7789v3
COCOTB_TEST_MODULES ?= tb
COCOTB_HDL_TIMEPRECISION := 100ps
COCOTB_HDL_TIMEUNIT := 1ns
# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
