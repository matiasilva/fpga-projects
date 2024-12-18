`include "lcd_st7789v3.vh"
`default_nettype none

module lcd_st7789v3 (
   input  wire clk,
   input  wire rst,
   output wire lcd_rst,
   output wire lcd_rs,
   output wire lcd_sd,
   output wire lcd_sck,
   output wire lcd_cs
);

localparam STALL_CTR_WIDTH = 24;
localparam WORD_WIDTH      = 9;

localparam DRIVER_RESET   = 3'b000;
localparam DRIVER_START   = 3'b001;
localparam DRIVER_HWRST   = 3'b010;
localparam DRIVER_INITSEQ = 3'b011;
localparam DRIVER_WRMEM   = 3'b100;
localparam DRIVER_IDLE    = 3'b101;

reg[2:0] state, state_nxt;

reg io_rst;
wire io_rs;
wire io_sd;
wire io_cs;
wire io_sck;

wire fifo_wr_ready;
wire fifo_rd_valid;
wire [WORD_WIDTH-1:0] fifo_rd_data;
wire serdes_ready;
wire decoder_valid;
wire decoder_last_page;
reg decoder_en;
wire decoder_upstream_wait = fifo_rd_valid || !serdes_ready; // wait until FIFO empty and serdes done
wire [WORD_WIDTH-1:0] decoder_data;
wire [WORD_WIDTH-1:0] ram_writer_data;
wire ram_writer_valid;
wire ram_writer_done;
reg ram_writer_en;
wire [WORD_WIDTH-1:0] fifo_wr_data = state == DRIVER_INITSEQ ? decoder_data : ram_writer_data;
wire fifo_wr_valid = state == DRIVER_INITSEQ ? decoder_valid : ram_writer_valid;

fifo #(.WORD_WIDTH(WORD_WIDTH)) f0 (
   .clk     (clk),
   .rst     (rst),
   .wr_ready(fifo_wr_ready),
   .wr_valid(fifo_wr_valid),
   .wr_data (fifo_wr_data),
   .rd_ready(serdes_ready),
   .rd_valid(fifo_rd_valid),
   .rd_data (fifo_rd_data)
);

serdes #(.PACKET_WIDTH(WORD_WIDTH)) ser0 (
   .clk  (clk),
   .rst  (rst),
   .ready(serdes_ready),
   .valid(fifo_rd_valid),
   .data (fifo_rd_data),
   .sd   (io_sd),
   .cs   (io_cs),
   .sck  (io_sck),
   .rs   (io_rs)
);

decoder #(.PACKET_WIDTH(WORD_WIDTH)) d0 (
.clk              (clk),
   .rst           (rst),
   .en            (decoder_en),
   .upstream_wait (decoder_upstream_wait),
   .valid         (decoder_valid),
   .ready         (fifo_wr_ready),
   .data          (decoder_data),
   .last_page     (decoder_last_page)
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

ram_writer #(.PACKET_WIDTH(WORD_WIDTH)) rw0 (
   .clk   (clk),
   .rst   (rst),
   .en    (ram_writer_en),
   .done  (ram_writer_done),
   .ready (fifo_wr_ready),
   .valid (ram_writer_valid),
   .data  (ram_writer_data)
);

always @(*) begin
   state_nxt = state;

   stall_en = 0;
   stall_cycles = 0;
   decoder_en = 1'b0;
   ram_writer_en = 1'b0;

   io_rst = 1'b1;
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
         if (decoder_last_page && !decoder_upstream_wait) begin
            state_nxt = DRIVER_WRMEM;
            ram_writer_en = 1'b1;
         end
      end
      DRIVER_WRMEM: begin
         if (ram_writer_done) state_nxt = DRIVER_IDLE;
      end
      DRIVER_IDLE: begin
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
assign lcd_sck = io_sck;

endmodule
