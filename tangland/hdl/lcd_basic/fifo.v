`default_nettype none

module fifo #(
   parameter DEPTH = 4,
   parameter WORD_WIDTH = 8
)(
   input wire clk,
   input wire rst,

   // write port
   output wire wr_ready,
   input wire wr_valid,
   input wire [WORD_WIDTH-1:0] wr_data,

   // read port
   input wire rd_ready,
   output wire rd_valid,
   output wire [WORD_WIDTH-1:0] rd_data,
);

   reg [$clog2(WORD_WIDTH)-1:0] rd_ptr, wr_ptr;

endmodule
