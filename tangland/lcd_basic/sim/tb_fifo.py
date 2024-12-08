import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles
from random import getrandbits, randint

async def reset_dut(dut):
    dut.rst.value = 1
    await ClockCycles(dut.clk, 2)
    dut.rst.value = 0
    await FallingEdge(dut.clk)
    dut.rst.value = 1


@cocotb.test()
async def smoke_test(dut):
    cocotb.start_soon(Clock(dut.clk, 1, units="ns").start())
    await reset_dut(dut)

    DEPTH = dut.DEPTH.value.to_unsigned()
    WORD_WIDTH = dut.WORD_WIDTH.value.to_unsigned()

    dut.wr_valid.value = 0
    dut.rd_ready.value = 0

    async def write_data(data: list | int):
        dut.wr_valid.value = 1
        data = data if isinstance(data, list) else [data]
        for d in data:
            dut.wr_data.value = d
            await RisingEdge(dut.clk)
        dut.wr_valid.value = 0

    async def read_data(n: int):
        buf = []
        dut.rd_ready.value = 1
        for i in range(n):
            await RisingEdge(dut.clk)
            buf.append(dut.rd_data.value)
        dut.rd_ready.value = 0
        return buf if len(buf) > 1 else buf[0]

    async def read_write_one(wr_data, rd_data):
        dut.wr_valid.value = 1
        dut.rd_ready.value = 1
        dut.wr_data.value = wr_data
        await RisingEdge(dut.clk)
        dut.wr_valid.value = 0 # prevent data leaks
        dut.rd_ready.value = 0
        return dut.rd_data.value

    assert dut.empty.value == 1, "FIFO not empty!"

    data_to_wr = [getrandbits(WORD_WIDTH) for _ in range(DEPTH)]
    # fill the FIFO until full
    await write_data(data_to_wr)

    await FallingEdge(dut.clk)
    assert dut.full.value == 1, "FIFO not full!"

    # drain the FIFO and verify contents
    rd_data = await read_data(len(data_to_wr))
    for i in range(len(data_to_wr)):
        assert rd_data[i] == data_to_wr[i], "Read/write mismatch!"

    await FallingEdge(dut.clk)
    assert dut.empty.value == 1, "FIFO not empty!"

    await reset_dut(dut)
    await RisingEdge(dut.clk) # sync before starting test
    assert dut.empty.value == 1, "FIFO not empty!"

    # write 1, read 1 with pointer overflow
    for i in range(DEPTH*4):
        data_to_wr = getrandbits(WORD_WIDTH)
        await write_data(data_to_wr)
        rd_data = await read_data(1)
        assert rd_data == data_to_wr, "Read/write mismatch"
        await FallingEdge(dut.clk)
        assert dut.empty.value == 1, "FIFO not empty!"

    await reset_dut(dut)
    await RisingEdge(dut.clk) # sync before starting test
    assert dut.empty.value == 1, "FIFO not empty!"
    
    # stress test: pick between writes, reads, and simultaneous reads/writes
    # mirror = [0]*DEPTH
    # trials = 100
    # for i in range(trials):
    #     coinflip = randint(0, 3)
    #     match coinflip:
    #         case 0:
    #             data = [getrandbits(WORD_WIDTH) for _ in [1]*randint(1,DEPTH+1)]
    #             for d in data:
    #                 if len(mirror) < DEPTH:
    #                     mirror.append(d)
    #             write_data(data)
    #             await FallingEdge(dut.clk)
    #             assert dut.mem == mirror
    #         case 1:
    #             pass
    #         case 2:
    #             pass
    #         case 3:
    #             pass


    dut._log.info("test finished")

