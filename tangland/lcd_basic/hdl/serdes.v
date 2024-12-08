`default_nettype none
// TODO: add MSB/LSB toggle

// Consumes data from a source, like a FIFO, and serializes it
// Data launches immediately as it is latched in

module serdes #(
   parameter WORD_WIDTH = 8
) (
   input clk,
   input rst,

   // data in port
   output wire ready,
   input wire valid,
   input wire [WORD_WIDTH-1:0] data,

   // serial data
   output wire sda
);

localparam BIT_PTR_MAX = (1 << $clog2(WORD_WIDTH)) - 1;

reg [$clog2(WORD_WIDTH)-1:0] bit_ptr;
reg [7:0] frame;

always @(posedge clk or negedge rst) begin
   if (~rst) begin
      sd_nxt <= 1'b0;
      bit_ptr <= BIT_PTR_MAX; // MSB first
   end else begin
      if (valid && ready) begin
         frame <= data;
      if (bit_ptr == 0) begin
         bit_ptr <= BIT_PTR_MAX;
      end else begin
         bit_ptr <= bit_ptr - 1;
      end
   end
end

assign ready = bit_ptr == BIT_PTR_MAX;
assign sd = ready ? data[bit_ptr] : frame[bit_ptr]; // launch forwarded data on first cycle


endmodule
