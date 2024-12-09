`include "lcd_st7789v3.vh"
`default_nettype none

module lcd_st7789v3 (
   input  clk,
   input  rst,
   output lcd_rst,
   output lcd_rs,
   output lcd_sd,
   output lcd_scl,
   output lcd_cs
);

localparam   STALL_CTR_WIDTH = 24;

reg io_rst;
wire io_rs;
wire io_sd;
wire io_scl;
wire io_cs;

typedef enum reg[2:0] {
   DRIVER_IDLE,
   DRIVER_HWRST,
   DRIVER_INITSEQ,
   DRIVER_WRMEM,
   DRIVER_START
} driver_state_t;

driver_state_t state, state_nxt;

always @(*) begin
   state_nxt = state;

   busy_bgn = 1'b0;
   busy_ctr_nxt = 0;
   initseq_bgn = 1'b0;

   io_rst = 1'b1;
   case (state)
      DRIVER_IDLE: begin
         state_nxt = DRIVER_START;
         busy_bgn = 1'b1;
         busy_ctr_nxt = `LONG_DLY_CYCLES;
      end
      DRIVER_START: begin
         if (busy_done) begin
            state_nxt = DRIVER_HWRST;
            busy_ctr_nxt = `HWRST_CYCLES;
            busy_bgn = 1'b1;
         end
      end
      DRIVER_HWRST: begin
         io_rst = 1'b0;
         if(busy_done) begin
            state_nxt = DRIVER_INITSEQ;
            initseq_bgn = 1'b1;
         end
      end
      DRIVER_INITSEQ: begin
         if (initseq_done) state_nxt = DRIVER_WRMEM;
      end
      DRIVER_WRMEM: begin
      end
   endcase

end

always @(posedge clk or negedge rst) begin
   if (~rst) begin
      state <= DRIVER_IDLE;
   end else begin
      state <= state_nxt;
   end
end





assign io_rs = initseq_type == INITSEQ_CMD ? 1'b0 : 1'b1;

assign lcd_rst = io_rst;
assign lcd_rs = io_rs;
assign lcd_sd = io_sd;
assign lcd_cs = io_cs;
assign lcd_scl = io_scl;

endmodule
