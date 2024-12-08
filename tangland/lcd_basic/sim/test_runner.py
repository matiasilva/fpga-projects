import os
from pathlib import Path

from cocotb_tools.runner import get_runner


def test_fifo_runner():
    sim = os.getenv("SIM", "icarus")
    root = Path(os.getenv("ROOT"))

    sources = [root / "fifo.v"]

    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="fifo",
    )

    test_opts = {
        'waves': True,
        'timescale': ('1ns', '100ps'),
        'test_module': 'tb_fifo'
    }
    runner.test(hdl_toplevel="fifo", **test_opts)


if __name__ == "__main__":
    test_fifo_runner()

