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

wire io_rst;
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

localparam INITSEQ_CMD  = 2'b00;
localparam INITSEQ_META = 2'b01;
localparam INITSEQ_ARG  = 2'b11;

localparam DRIVER_IDLE    = 3'b000;
localparam DRIVER_HWRST   = 3'b001;
localparam DRIVER_INITSEQ = 3'b010;
localparam DRIVER_WRMEM   = 3'b011;
localparam DRIVER_START   = 3'b100;

reg [2:0] cur_state, nxt_state;

always @(*) begin
   nxt_state = cur_state;

   case (cur_state)
      DRIVER_START: begin
         busy_en = 1'b1;
         busy_dly = 
         if (busy_done) nxt_state = DRIVER_HWRST;
      end
      DRIVER_HWRST: begin
      end
      DRIVER_INITSEQ: begin
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


wire busy_en;
wire [BUSY_CTR_WIDTH-1:0] busy_dly;
wire busy_done = busy_en && busy_active && busy_ctr == 0;
wire busy_active = busy_state == BUSY_ACTIVE;
reg [BUSY_CTR_WIDTH-1:0] busy_ctr;
reg busy_state;

localparam BUSY_IDLE = 0;
localparam BUSY_ACTIVE = 1;
localparam BUSY_CTR_WIDTH = 16;
localparam BUSY_CTR_DECR = 10;

always @(posedge clk or negedge rst) begin
   if (~rst) begin
      busy_state <= BUSY_IDLE;
      busy_ctr <= 0;
   end else begin
      if (!busy_state) begin
         if (busy_en) begin
            busy_ctr <= busy_dly;
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

/*

integer initseq_ptr = 0;
reg [1:0] initseq_type;
assign io_rs = initseq_type == INITSEQ_CMD ? 1'b0 : 1'b1;

always @(posedge clk or negedge rst) begin
   if (~rst) begin
      initseq_type <= INITSEQ_CMD;
   end else begin

   end
end
*/
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


assign lcd_rst = io_rst;
assign lcd_rs = io_rs;
assign lcd_sd = io_sd;
assign lcd_cs = io_cs;
assign lcd_scl = io_scl;

endmodule
