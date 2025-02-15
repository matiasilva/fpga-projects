`default_nettype none

module stall #(
   parameter CTR_WIDTH = 24
) (
   input wire clk,
   input wire  rst,

   input wire [CTR_WIDTH-1:0] cycles,
   input wire en,
   output wire done
);

reg stalling;
reg [CTR_WIDTH-1:0] ctr;
wire last = ctr == 0;

always @(posedge clk or negedge rst) begin
   if (~rst) begin
      stalling <= 1'b0;
      ctr <= 0;
   end else begin
      if (en && (!stalling || last)) begin // en asserted on last cycle continues stall
         stalling <= 1'b1;
         ctr <= cycles - 1;
      end else if (stalling) begin
         if (last)
            stalling <= 0;
         else
            ctr <= ctr - 1;
      end
   end
end

assign done = last && stalling;

endmodule
