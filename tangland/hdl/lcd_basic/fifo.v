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

   localparam PTRLEN $clog2(DEPTH) // need n+1 bits

   reg [PTRLEN:0] rd_ptr, wr_ptr;
   reg [WORD_WIDTH-1:0] mem [0:DEPTH-1];

   wire [PTRLEN:0] level = wr_ptr - rd_ptr;
   wire empty = (level == 0);
   wire full = (level == {1'b1, {(PTRLEN){1'b0}}});

   always @(posedge clk or negedge rst) begin
      if (~rst) begin
         rd_ptr <= 0;
         wr_ptr <= 0;
      end else begin
         if (rd_ready && rd_valid) begin
            rd_ptr <= rd_ptr + 1;
            if (full) wr_ptr <= 0;
         end
         if (wr_ready && wr_valid) begin
            mem[wr_ptr] <= wr_data;
            wr_ptr <= wr_ptr + 1;
         end
      
      
      end
      
   
   end

   assign rd_valid = !empty;
   assign wr_ready = !full;
   assign rd_data = mem[rd_ptr];

endmodule
