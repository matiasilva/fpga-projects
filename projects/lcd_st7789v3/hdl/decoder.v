// LCD display command sequence decoder
// used for: init sequence, on-the-fly configuration
// assumption: FIFO is deep enough for command (1 byte) + max args (4 bytes)
// assumption: same clock domain as serdes, data is clocked out at the same
// rate

`include "lcd_st7789v3.vh"
`default_nettype none

module decoder #(
   parameter WORD_WIDTH = 8,
   parameter PACKET_WIDTH = 9
)(
   input wire clk,
   input wire rst,

   input wire en,
   input wire upstream_wait,

   // to FIFO
   input wire ready,
   output wire valid,
   output wire [PACKET_WIDTH-1:0] data,

   output wire last_page
);

localparam INITSEQ_SIZE  =  22;
localparam ARG_MSB       =  2;
localparam STALL_CTR_WIDTH = 24;
// localparam ARG_BITS      =  (1 << (ARG_MSB + 1)) - 1;

reg [(INITSEQ_SIZE*8)-1:0] INITSEQ = {
   `SWRESET_CMD, `LONG_DLY ,
   `SLPOUT_CMD , `LONG_DLY ,
   `CASET_CMD  , 8'd4     , 8'h00, 8'h28, 8'h01, 8'h17 ,
   `RASET_CMD  , 8'd4     , 8'h00, 8'h35, 8'h00, 8'hbb,
   `INVON_CMD  , `SHORT_DLY,
   `NORON_CMD  , `SHORT_DLY,
   `DISPON_CMD , `SHORT_DLY
}; // implied initial

localparam IDLE          = 3'b000;
localparam CMD           = 3'b001;
localparam ARGS          = 3'b010;
localparam STALL         = 3'b011;
localparam UPSTREAM_WAIT = 3'b100;

reg [2:0] state, state_nxt;

reg [ARG_MSB:0] arg_ctr, arg_ctr_nxt;
reg [$clog2(INITSEQ_SIZE)-1:0] ptr, ptr_nxt;
reg [STALL_CTR_WIDTH-1:0] stall_ctr, stall_ctr_nxt;

wire [WORD_WIDTH-1:0] meta               = INITSEQ[WORD_WIDTH*(ptr-1)+:WORD_WIDTH];
wire [$clog2(INITSEQ_SIZE)-1:0] ptr_page_end = ptr - 1 - meta[ARG_MSB:0];
wire stall                               = meta[`LONG_DLY_MSB] | meta[`SHORT_DLY_MSB];

reg [PACKET_WIDTH-1:0] frame;
reg frame_valid;

always @(*) begin
   state_nxt = state;
   arg_ctr_nxt = arg_ctr;
   ptr_nxt = ptr;
   stall_ctr_nxt = stall_ctr;

   frame = 0;
   frame_valid = 1'b0;
   case (state)
      IDLE: if (en) state_nxt = CMD;
      CMD: begin
         frame = {1'b0, INITSEQ[WORD_WIDTH*ptr+:WORD_WIDTH]};
         frame_valid = 1'b1;
         if (meta[ARG_MSB:0] == 0) begin // no args
            state_nxt = UPSTREAM_WAIT;
         end else begin
            state_nxt = ARGS;
            arg_ctr_nxt = meta[ARG_MSB:0];
         end
      end
      ARGS: begin
         frame = {1'b1, INITSEQ[WORD_WIDTH*(ptr-arg_ctr)+:WORD_WIDTH]};
         frame_valid = 1'b1;
         if (arg_ctr == 0) begin
            // state_nxt = stall ? STALL : (last_page ? IDLE : CMD);
            // only need above line if serdes is in a diff clock domain (and
            // below line should really be redone)
            state_nxt = UPSTREAM_WAIT;
         end else
            arg_ctr_nxt = arg_ctr - 1;
      end
      STALL: begin
         stall_ctr_nxt = stall_ctr - 1;
         if (stall_ctr == 0) state_nxt = last_page ? IDLE : CMD;
      end
      UPSTREAM_WAIT: begin
         // we will stay here for one cycle if serdes has somehow clocked out
         // all 8 bits in one cycle
         if (!upstream_wait) begin
            state_nxt = stall ? STALL : (last_page ? IDLE : CMD);
            stall_ctr_nxt = meta[`LONG_DLY_MSB] ? `LONG_DLY_CYCLES : (meta[`SHORT_DLY_MSB] ? `SHORT_DLY_CYCLES : 0);
            ptr_nxt = ptr_page_end - 1; // set pointer
         end
      end
   endcase
end

always @(posedge clk or negedge rst) begin
   if (~rst) begin
      state <= IDLE;
      arg_ctr <= 0;
      ptr <= INITSEQ_SIZE - 1;
      stall_ctr <= 0;
   end else begin
      state <= state_nxt;
      arg_ctr <= arg_ctr_nxt;
      ptr <= ptr_nxt;
      stall_ctr <= stall_ctr_nxt;
   end
end

assign data      = frame;
assign valid     = frame_valid;
assign last_page = ptr_page_end == 0;

endmodule
