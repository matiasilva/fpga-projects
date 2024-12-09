// LCD display command sequence decoder
// used for: init sequence, on-the-fly configuration
`include "lcd_st7789v3.vh"
`default_nettype none

module decoder #(
   parameter WORD_WIDTH = 8
)(
   input wire clk,
   input wire rst,

   input wire en,

   // to FIFO
   input wire ready,
   output wire valid,
   output wire [WORD_WIDTH-1:0] data,

   output wire is_cmd
);

localparam INITSEQ_SIZE  =  22;
localparam ARG_MSB       =  2;
// localparam ARG_BITS      =  (1 << (ARG_MSB + 1)) - 1;

reg [(INITSEQ_SIZE*8)-1:0] INITSEQ = {
   `SWRESET_CMD, `LONG_DLY ,
   `SLPOUT_CMD , `LONG_DLY ,
   `CASET_CMD  , 8'd4     , 8'd0, 8'd0, 8'd0, `DISP_WIDTH ,
   `RASET_CMD  , 8'd4     , 8'd0, 8'd0, 8'd0, `DISP_HEIGHT,
   `INVON_CMD  , `SHORT_DLY,
   `NORON_CMD  , `SHORT_DLY,
   `DISPON_CMD , `SHORT_DLY
}; // implied initial

typedef enum reg[1:0] {
   IDLE,
   CMD,
   ARGS,
   STALL
} state_t;

state_t state, state_nxt;

reg [ARG_MSB:0] arg_ctr, arg_ctr_nxt;
reg [$clog2(INITSEQ_SIZE)-1:0] ptr, ptr_nxt;
reg [23:0] stall_ctr, stall_ctr_nxt;

wire [WORD_WIDTH-1:0] meta               = INITSEQ[8*(ptr+1)-:8];
wire [$clog2(INITSEQ_SIZE)-1:0] ptr_incr = ptr + 2 + meta[ARG_MSB:0];
wire stall                               = meta[`LONG_DLY_MSB] | meta[`SHORT_DLY_MSB];

reg [WORD_WIDTH-1:0] frame;
reg frame_valid;

always @(*) begin
   state_nxt = state;
   arg_ctr_nxt = arg_ctr;
   ptr_nxt = ptr;
   stall_ctr_nxt = meta[`LONG_DLY_MSB] ? `LONG_DLY_CYCLES : (meta[`SHORT_DLY_MSB] ? `SHORT_DLY_CYCLES : 0);

   frame = 0;
   frame_valid = 1'b0;

   case (state)
      IDLE: if (en) state_nxt = CMD;
      CMD: begin
         frame = INITSEQ[8*ptr-:8];
         frame_valid = 1'b1;
         if (ready) begin
            if (meta[ARG_MSB:0] == 0) begin
               ptr_nxt = ptr_incr;
               if (stall) state_nxt = STALL;
            end else begin
               state_nxt = ARGS;
               arg_ctr_nxt = meta[ARG_MSB:0];
            end
         end
      end
      ARGS: begin
         frame = INITSEQ[8*(ptr_incr-arg_ctr)-:8];
         frame_valid = 1'b1;
         if (ready) begin
            if (arg_ctr == 0) begin
               ptr_nxt = ptr + ptr_incr;
               state_nxt = stall ? STALL : (ptr == (INITSEQ_SIZE - 1) ? IDLE : CMD);
            end else
               arg_ctr_nxt = arg_ctr - 1;
         end
      end
      STALL: begin
         stall_ctr_nxt = stall_ctr - 1;
         if (stall_ctr == 0) state_nxt = IDLE;
      end
   endcase
end

always @(posedge clk or negedge rst) begin
   if (~rst) begin
      state <= IDLE;
      arg_ctr <= 0;
      ptr <= 0;
      stall_ctr <= 0;
   end else begin
      state <= state_nxt;
      arg_ctr <= arg_ctr_nxt;
      ptr <= ptr_nxt;
      stall_ctr <= stall_ctr_nxt;
   end
end

assign data = frame;
assign valid = frame_valid;
assign is_cmd = state == CMD;

endmodule
