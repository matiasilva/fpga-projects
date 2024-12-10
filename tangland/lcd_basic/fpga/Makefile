BOARD   := tangnano9k
FAMILY  := GW1N-9C
DEVICE  := GW1NR-LV9QN88PC6/I5
PC_FILE := ${BOARD}.cst

HDLDIR  := ${ROOT}/hdl
PROJ    := lcd_basic
SOURCES := fpga.v ${HDLDIR}/serdes.v ${HDLDIR}/fifo.v ${HDLDIR}/decoder.v ${HDLDIR}/stall.v ${HDLDIR}/lcd_st7789v3.v
YOSYS_DEFINES := -DN_LEDS=6 -DFPGA


all: ${PROJ}.fs

# synth
${PROJ}.json: ${SOURCES}
	yosys ${YOSYS_DEFINES} -p "read_verilog -sv $^; synth_gowin -top top -json $@"

# pnr
${PROJ}_pnr.json: ${PROJ}.json
	nextpnr-himbaechel --json ${PROJ}.json --write $@ --freq 27 --device ${DEVICE} --vopt family=${FAMILY} --vopt cst=${PC_FILE}

# bitstream
${PROJ}.fs: ${PROJ}_pnr.json
	gowin_pack -d ${FAMILY} -o ${PROJ}.fs ${PROJ}_pnr.json

# flash
load: ${PROJ}.fs
	openFPGALoader -b ${BOARD} ${PROJ}.fs -f

# sim pt. 1
${PROJ}_test.o: ${PROJ}.v ${PROJ}_tb.v
	iverilog -o $@ -s test ${PROJ}.v ${PROJ}_tb.v

# sim pt. 2
${PROJ}.vcd: ${PROJ}_test.o
	vvp $<

lint:
	verilator --lint-only -Wall -I$(dir ${LF}) ${LF}

sim: ${PROJ}.vcd
	gtkwave $<

# Cleanup build artifacts
clean:
	rm ${PROJ}.vcd ${PROJ}.fs ${PROJ}_test.o

.PHONY: load clean sim lint
.INTERMEDIATE: ${PROJ}_pnr.json ${PROJ}.json ${PROJ}_test.o
