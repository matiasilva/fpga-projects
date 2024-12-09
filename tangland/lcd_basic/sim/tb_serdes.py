import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles
from random import getrandbits

@cocotb.test()
async def smoke_test(dut):
    cocotb.start_soon(Clock(dut.clk, 1, units="ns").start())

    dut.rst.value = 1
    await ClockCycles(dut.clk, 2)
    dut.rst.value = 0
    await FallingEdge(dut.clk)
    dut.rst.value = 1

    WORD_WIDTH = dut.WORD_WIDTH.value.to_unsigned()

    await RisingEdge(dut.clk) # sync

    dut.valid.value = 1
    data_to_wr = getrandbits(WORD_WIDTH)
    dut.data.value = data_to_wr
    await RisingEdge(dut.clk) # clock data in

    await FallingEdge(dut.clk)
    assert not dut.ready.value, "Serdes still ready!"
    assert dut.frame.value == data_to_wr, "Serdes has wrong data frame"
    for i in range(WORD_WIDTH-1, -1, -1):
        assert dut.sd.value == (data_to_wr >> i) & 1, "Serdes output wrong data"
        await FallingEdge(dut.clk)

    await RisingEdge(dut.clk)

import os
from pathlib import Path
from cocotb_tools.runner import get_runner


def test_serdes_runner():
    sim = os.getenv("SIM", "icarus")
    root = Path(os.getenv("ROOT")) / 'hdl'

    sources = [root / "serdes.v"]

    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="serdes",
        timescale=("1ns", "1ps"),
        waves=True
    )

    test_opts = {
        'waves': True,
        'test_module': 'tb_serdes',
        'timescale': ("1ns", "1ps")
    }
    runner.test(hdl_toplevel="serdes", **test_opts)


if __name__ == "__main__":
    test_serdes_runner()
