SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(ROOT)/hdl/lcd_basic/lcd_st7789v3.v
VERILOG_INCLUDE_DIRS += $(ROOT)/hdl/lcd_basic
TOPLEVEL = lcd_st7789v3
COCOTB_TEST_MODULES = tb

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
