`define WIDTH 22

module proj_wrapper (
   input clk,
   input rst,
   output [`N_LEDS-1:0] led
);

reg [`WIDTH-1:0] ctr_q;
reg [`N_LEDS-1:0] led_shift;

wire pulse = (ctr_q == {`WIDTH{1'b1}});

always @(posedge clk or negedge rst) begin
   if (~rst) begin
      ctr_q <= `WIDTH'b0;
      led_shift <= 1'b1;
   end else begin
      if (pulse) begin
         led_shift <= {led_shift[`N_LEDS-2:0], led_shift[`N_LEDS-1]};
      end
      ctr_q <= ctr_q + 1'b1;
   end
end

assign led = ~led_shift;

endmodule
