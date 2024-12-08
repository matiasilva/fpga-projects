# Quick smoke test for LCD driver

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, Timer, ClockCycles

@cocotb.test()
async def smoke_test(dut):
    cocotb.start_soon(Clock(dut.clk, 1, units="ns").start())
    dut.rst.value = 0
    await ClockCycles(dut.clk, 2)
    dut.rst.value = 1
    await Timer(1, units="us")  # wait a bit
    await FallingEdge(dut.clk)  # wait for falling edge/"negedge"
    dut._log.info("test finished")

