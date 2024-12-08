import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles
from random import getrandbits

async def reset_dut(dut):
    dut.rst.value = 1
    await ClockCycles(dut.clk, 2)
    dut.rst.value = 0
    await RisingEdge(dut.clk)
    dut.rst.value = 1


@cocotb.test()
async def smoke_test(dut):
    cocotb.start_soon(Clock(dut.clk, 1, units="ns").start())
    await reset_dut(dut)

    dut.rd_ready.value = 0
    dut.wr_valid.value = 0

    DEPTH = dut.DEPTH.value
    WORD_WIDTH = dut.WORD_WIDTH.value
    data_to_wr = [getrandbits(WORD_WIDTH) for _ in range(DEPTH)]

    assert dut.empty.value == 1, "FIFO not empty!"
    # fill the FIFO until full
    for i in range(DEPTH):
        dut.wr_valid.value = 1
        dut.wr_data.value = data_to_wr[i]
        await RisingEdge(dut.clk)

    await FallingEdge(dut.clk)
    assert dut.full.value == 1, "FIFO not full!"

    dut.wr_valid.value = 0
    # drain the FIFO and verify contents
    for i in range(DEPTH):
        dut.rd_ready.value = 1
        await RisingEdge(dut.clk)
        assert dut.rd_data.value == data_to_wr[i], "Read/write mismatch!"

    await FallingEdge(dut.clk)
    assert dut.empty.value == 1, "FIFO not empty!"

    await reset_dut(dut)

    # fill the FIFO 

    dut._log.info("test finished")

