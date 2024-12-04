`define WIDTH 22

module proj_wrapper (
   input clk,
   input rst,
   output [`N_LEDS-1:0] led
   output lcd_rst,
   output lcd_rs,
   output lcd_sd,
   output lcd_scl,
   output lcd_cs
);


always @(posedge clk or negedge rst) begin
   if (~rst) begin

   end else begin

   end
end


endmodule
