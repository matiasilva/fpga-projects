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

always @(posedge clk or negedge rst) begin
   if (~rst) begin
      stalling <= 1'b1;
   end else begin
      if (!stalling) begin
         if (en) begin
            stalling <= 1'b1;
            ctr <= cycles;
         end
      end else begin
         ctr <= ctr - 1;
         if (ctr == 0) stalling <= 1'b0;
      end
   end
end

assign done = (ctr == 0) && stalling;

endmodule
