`include "lcd_st7789v3.vh"
`default_nettype none

module lcd_st7789v3 (
   input  clk,
   output lcd_rst,
   output lcd_rs,
   output lcd_sd,
   output lcd_scl,
   output lcd_cs
);

localparam INITSEQ_SIZE = 60;
reg [(INITSEQ_SIZE*8)-1:0] INITSEQ = {
   

   }; // implied initial

endmodule
