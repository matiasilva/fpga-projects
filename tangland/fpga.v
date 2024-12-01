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

endmodule
