`include "lcd_st7789v3.vh"
`default_nettype none

`ifdef FPGA
   `define CLKFREQ 13.5*1000000
   `define LONG_DLY_CYCLES 0.2*`CLKFREQ // 200ms
   `define SHORT_DLY_CYCLES 0.01*`CLKFREQ // 10ms
   `define HWRST_CYCLES 0.00002*`CLKFREQ // 20us
`else
   `define LONG_DLY_CYCLES 50
   `define SHORT_DLY_CYCLES 10
   `define HWRST_CYCLES 4
`endif

module lcd_st7789v3 (
   input  clk,
   input  rst,
   output lcd_rst,
   output lcd_rs,
   output lcd_sd,
   output lcd_scl,
   output lcd_cs
);

reg io_rst;
wire io_rs;
wire io_sd;
wire io_scl;
wire io_cs;

localparam INITSEQ_SIZE  =  22;
localparam LONG_DLY      =  8'h40; // 200 ms
localparam SHORT_DLY     =  8'h80; // 10 ms
localparam ARG_BITS      =  8'h3f; // max 63 args
localparam DISP_WIDTH    =  16'd135;
localparam DISP_HEIGHT   =  16'd240;


reg [(INITSEQ_SIZE*8)-1:0] INITSEQ = {
   `SWRESET_CMD, LONG_DLY ,
   `SLPOUT_CMD , LONG_DLY ,
   `CASET_CMD  , 8'd4     , 8'd0, 8'd0, DISP_WIDTH[15:8] , DISP_WIDTH[7:0] ,
   `RASET_CMD  , 8'd4     , 8'd0, 8'd0, DISP_HEIGHT[15:8], DISP_HEIGHT[7:0],
   `INVON_CMD  , SHORT_DLY,
   `NORON_CMD  , SHORT_DLY,
   `DISPON_CMD , SHORT_DLY
   }; // implied initial

typedef enum reg[1:0] {
   INITSEQ_CMD,
   INITSEQ_META,
   INITSEQ_ARG
} initseq_type;

typedef enum reg[2:0] {
   DRIVER_IDLE,
   DRIVER_HWRST,
   DRIVER_INITSEQ,
   DRIVER_WRMEM,
   DRIVER_START
} driver_state_t;

typedef enum reg[2:0] {
   BUSY_IDLE,
   BUSY_ACTIVE
} busy_state_t;

localparam   BUSY_CTR_WIDTH = 16;

busy_state_t busy_state ;
reg busy_en;
wire busy_active = busy_state == BUSY_ACTIVE;
reg [BUSY_CTR_WIDTH-1:0] busy_dly;
reg [BUSY_CTR_WIDTH-1:0] busy_ctr;
wire busy_done = busy_en && busy_active && busy_ctr == 0;

always @(posedge clk or negedge rst) begin
   if (~rst) begin
      busy_state <= BUSY_IDLE;
      busy_ctr <= 0;
   end else begin
      if (busy_state == BUSY_IDLE) begin
         if (busy_en) begin
            busy_ctr <= busy_dly - 1;
            busy_state <= BUSY_ACTIVE;
         end
      end else begin
         if (|busy_ctr) begin
            busy_ctr <= busy_ctr - 1;
         end else begin
            busy_state <= BUSY_IDLE;
         end
      end
   end
end

/* serializer */

reg [7:0] frame;
reg [2:0] frame_ptr;
wire msb_first = 1'b1;
wire wr_frame = 0;

always @(posedge clk or negedge rst) begin
   if (~rst) begin
      frame <= 0;
      frame_ptr <= 0;
   end else begin
      if (wr_frame) begin
         frame <= 8'b0;
      end
   end
end

driver_state_t cur_state, nxt_state;

always @(*) begin
   nxt_state = cur_state;

   busy_en = 1'b0;
   busy_dly = 0;

   io_rst = 1'b1;
   case (cur_state)
      DRIVER_START: begin
         busy_en = 1'b1;
         busy_dly = `LONG_DLY_CYCLES;
         if (busy_done) nxt_state = DRIVER_HWRST;
      end
      DRIVER_HWRST: begin
         io_rst = 1'b0;
         busy_en = 1'b1;
         busy_dly = `HWRST_CYCLES;
         if(busy_done) nxt_state = DRIVER_INITSEQ;
      end
      DRIVER_INITSEQ: begin
         if (initseq_done) nxt_state = DRIVER_WRMEM;
      end
      DRIVER_WRMEM: begin
      end
   endcase

end

always @(posedge clk or negedge rst) begin
   if (~rst) begin
      cur_state <= DRIVER_START;
   end else begin
      cur_state <= nxt_state;
   end
end

integer initseq_ptr = 0;
wire initseq_en
reg [1:0] initseq_type;
assign io_rs = initseq_type == INITSEQ_CMD ? 1'b0 : 1'b1;

always @(posedge clk or negedge rst) begin
   if (~rst) begin
      initseq_type <= INITSEQ_CMD;
   end else begin

   end
end



assign lcd_rst = io_rst;
assign lcd_rs = io_rs;
assign lcd_sd = io_sd;
assign lcd_cs = io_cs;
assign lcd_scl = io_scl;

endmodule
