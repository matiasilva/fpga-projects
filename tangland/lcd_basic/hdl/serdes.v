`default_nettype none

module serdes (
   input clk,

);

reg sd_nxt;
reg [2:0] bit_ptr;
reg [7:0] tx_frame;
reg tx_frame_vld;

always @(posedge clk or negedge rst) begin
   if (~rst) begin
      sd_nxt <= 1'b0;
      bit_ptr <= 3'h7;
   end else begin
      if (tx_frame_vld) begin
         sd_nxt <= tx_frame[bit_ptr];
      end
      if(bit_ptr == 0) begin
         tx_frame_vld <= 1'b0;
      end
      bit_ptr <= bit_ptr - 1;
   
   end

end

assign sd = sd_nxt;

endmodule
