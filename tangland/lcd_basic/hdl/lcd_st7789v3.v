`include "lcd_st7789v3.vh"
`default_nettype none

module lcd_st7789v3 (
   input  wire clk,
   input  wire rst,
   output wire lcd_rst,
   output wire lcd_rs,
   output wire lcd_sd,
   output wire lcd_scl,
   output wire lcd_cs
);

localparam STALL_CTR_WIDTH = 24;
localparam WORD_WIDTH      = 8;

typedef enum reg[2:0] {
   DRIVER_RESET,
   DRIVER_START,
   DRIVER_HWRST,
   DRIVER_INITSEQ,
   DRIVER_WRMEM
} driver_state_t;

driver_state_t state, state_nxt;

reg io_rst;
wire io_rs;
wire io_sd;
reg io_cs;
wire io_scl = ~io_cs && clk;

wire fifo_wr_ready;
wire fifo_rd_valid;
wire [WORD_WIDTH-1:0] fifo_rd_data;
wire decoder_valid;
wire decoder_idle;
reg decoder_en;
wire [WORD_WIDTH-1:0] decoder_data;
wire serdes_ready;

fifo f0 (
   .clk     (clk),
   .rst     (rst),
   .wr_ready(fifo_wr_ready),
   .wr_valid(decoder_valid),
   .wr_data (decoder_data),
   .rd_ready(serdes_ready),
   .rd_valid(fifo_rd_valid),
   .rd_data (fifo_rd_data)
);

serdes ser0 (
   .clk  (clk),
   .rst  (rst),
   .ready(serdes_ready),
   .valid(fifo_rd_valid),
   .data (fifo_rd_data),
   .sd   (io_sd)
);

decoder d0 (
.clk   (clk),
   .rst   (rst),
   .en    (decoder_en),
   .valid (decoder_valid),
   .ready (fifo_wr_ready),
   .data  (decoder_data),
   .is_cmd(io_rs),
   .idle  (decoder_idle)
);

reg stall_en;
reg [STALL_CTR_WIDTH-1:0] stall_cycles;
wire stall_done;

stall s0 (
   .clk   (clk),
   .rst   (rst),
   .en    (stall_en),
   .cycles(stall_cycles),
   .done  (stall_done)
);

always @(*) begin
   state_nxt = state;

   stall_en = 0;
   stall_cycles = 0;
   decoder_en = 0;

   io_rst = 1'b1;
   io_cs = 1'b1;
   case (state)
      DRIVER_RESET: begin
         state_nxt = DRIVER_START;
         stall_en = 1'b1;
         stall_cycles = `LONG_DLY_CYCLES;
      end
      DRIVER_START: begin
         if (stall_done) begin
            state_nxt = DRIVER_HWRST;
            stall_en = 1'b1;
            stall_cycles = `HWRST_CYCLES;
         end
      end
      DRIVER_HWRST: begin
         io_rst = 1'b0;
         if (stall_done) begin
            state_nxt = DRIVER_INITSEQ;
            decoder_en = 1'b1;
         end
      end
      DRIVER_INITSEQ: begin
         io_cs = 1'b0;
         if (decoder_idle && !fifo_rd_valid && serdes_ready) state_nxt = DRIVER_WRMEM;
      end
      DRIVER_WRMEM: begin
      end
   endcase

end

always @(posedge clk or negedge rst) begin
   if (~rst) begin
      state <= DRIVER_RESET;
   end else begin
      state <= state_nxt;
   end
end

assign lcd_rst = io_rst;
assign lcd_rs = io_rs;
assign lcd_sd = io_sd;
assign lcd_cs = io_cs;
assign lcd_scl = io_scl;

endmodule
