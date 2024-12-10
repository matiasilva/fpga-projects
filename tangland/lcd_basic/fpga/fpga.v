`default_nettype none

module top (
   input wire clk,
   input wire rst,
   output wire [`N_LEDS-1:0] led,
   output wire lcd_rst,
   output wire lcd_rs,
   output wire lcd_sd,
   output wire lcd_sck,
   output wire lcd_cs
);

wire hclk;
assign led = {(`N_LEDS-1){1'b0}, 1'b1};

CLKDIV clkdiv_inst (
.HCLKIN(clk),
.RESETN(rst),
.CALIB(1'b0),
.CLKOUT(hclk)
);
defparam clkdiv_inst.DIV_MODE="8"; // freq = 3.4 MHz

lcd_st7789v3 lcd0 (  .clk(hclk),
                     .rst(rst),
                     .lcd_rst(lcd_rst),
                     .lcd_rs(lcd_rs),
                     .lcd_sd(lcd_sd),
                     .lcd_scl(lcd_sck),
                     .lcd_cs(lcd_cs));

endmodule
