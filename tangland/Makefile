BOARD   := tangnano9k # openFPGALoader name
FAMILY  := GW1N-9C # pnr
DEVICE  := GW1NR-LV9QN88PC6/I5 # pnr
PC_FILE := ${BOARD}.cst # constraints
PROJ    := app


all: ${PROJ}.fs

# synth
${PROJ}.json: top.v
	yosys -p "read_verilog top.v; synth_gowin -json ${PROJ}.json"

# pnr
${PROJ}_pnr.json: ${PROJ}.json
	nextpnr-himbaechel --json ${PROJ}.json --write ${PROJ}_pnr.json --freq 27 --device ${DEVICE} --vopt family=${FAMILY} --vopt cst=${PC_FILE}

# bitstream
${PROJ}.fs: ${PROJ}_pnr.json
	gowin_pack -d ${FAMILY} -o ${PROJ}.fs ${PROJ}_pnr.json

# flash
load: ${PROJ}.fs
	openFPGALoader -b ${BOARD} ${PROJ}.fs -f

# sim pt. 1
${PROJ}_test.o: ${PROJ}.v ${PROJ}_tb.v
	iverilog -o ${PROJ}_test.o -s test ${PROJ}.v ${PROJ}_tb.v

# sim pt. 2
${PROJ}.vcd: ${PROJ}_test.o
	vvp ${PROJ}_test.o

sim: ${PROJ}.vcd
	gtkwave ${PROJ}.vcd

# Cleanup build artifacts
clean:
	rm ${PROJ}.vcd ${PROJ}.fs ${PROJ}_test.o

.PHONY: load clean sim
.INTERMEDIATE: ${PROJ}_pnr.json ${PROJ}.json ${PROJ}_test.o
