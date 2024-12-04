module proj_wrapper (
   input clk,
   input rst,
   output [`N_LEDS-1:0] led,
   output lcd_rst,
   output lcd_rs,
   output lcd_sd,
   output lcd_scl,
   output lcd_cs
);

// divide by 2 to get freq of ~14MHz
wire hclk;
CLKDIV2 clkdiv2_inst (
    .CLKOUT(hclk),
    .HCLKIN(clk),
    .RESETN(rst)
);

lcd_st7789v3 lcd0 (  .clk(hclk),
                     .lcd_rst(rst),
                     .lcd_rs(lcd_rs),
                     .lcd_sd(lcd_sd),
                     .lcd_scl(lcd_scl),
                     .lcd_cs(lcd_cs));


always @(posedge clk or negedge rst) begin
   if (~rst) begin

   end else begin

   end
end


endmodule
