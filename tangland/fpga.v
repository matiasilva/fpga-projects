`define N_LEDS 6

module top (
   input clk,
   input rst,
   output [`N_LEDS-1:0] led,
   output lcd_rst,
   output lcd_rs,
   output lcd_sd,
   output lcd_scl,
   output lcd_cs
);


proj_wrapper p0 ( .clk (clk),
                  .rst (rst),
                  .led (led),
                  .lcd_rst (lcd_rst),
                  .lcd_rs (lcd_rs),
                  .lcd_sd (lcd_sd),
                  .lcd_scl (lcd_scl),
                  .lcd_cs (lcd_cs));


endmodule
