import os
from pathlib import Path

from cocotb_tools.runner import get_runner


def test_fifo_runner():
    sim = os.getenv("SIM", "icarus")
    root = Path(os.getenv("ROOT")) / 'hdl'

    sources = [root / "fifo.v"]

    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="fifo",
        timescale=("1ns", "1ps"),
        waves=True
    )

    test_opts = {
        'waves': True,
        'test_module': 'tb_fifo',
        'timescale': ("1ns", "1ps")
    }
    runner.test(hdl_toplevel="fifo", **test_opts)

if __name__ == "__main__":
    test_fifo_runner()

