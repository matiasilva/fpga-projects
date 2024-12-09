// LCD display command sequence decoder
// used for: init sequence, on-the-fly configuration

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

   output wire is_cmd,
);

localparam INITSEQ_SIZE  =  22;
localparam ARG_MSB       =  2;
localparam ARG_BITS      =  (1 << (ARG_MSB + 1)) - 1;

reg [(SIZE*8)-1:0] INITSEQ = {
   `SWRESET_CMD, LONG_DLY ,
   `SLPOUT_CMD , LONG_DLY ,
   `CASET_CMD  , 8'd4     , 8'd0, 8'd0, DISP_WIDTH[15:8] , DISP_WIDTH[7:0] ,
   `RASET_CMD  , 8'd4     , 8'd0, 8'd0, DISP_HEIGHT[15:8], DISP_HEIGHT[7:0],
   `INVON_CMD  , SHORT_DLY,
   `NORON_CMD  , SHORT_DLY,
   `DISPON_CMD , SHORT_DLY
}; // implied initial

typedef enum reg[1:0] {
   IDLE,
   CMD,
   ARGS
} state_t;

state_t state, state_nxt;

reg [ARG_BITS:0] arg_ctr, arg_ctr_nxt;
reg [$clog2(INITSEQ_SIZE)-1:0] ptr, ptr_nxt;

wire [7:0] cmd = INITSEQ[8*ptr-:8];
wire [7:0] meta = INITSEQ[(8*ptr)+1-:8];
wire nargs = meta & ARG_BITS;
wire [$clog2(SIZE)-1:0] ptr_nxt = ptr + 2 + nargs;
reg [ARG_MSB-1:0] tx_ctr, tx_ctr_nxt;
wire data_loc = ptr + 2;

always @(*) begin
   state_nxt = state;
   arg_ctr_nxt = arg_ctr;
   case (state)
      IDLE: begin
         state_nxt <
      end
      CMD:
      ARGS:
   endcase
end

always @(posedge clk or negedge rst) begin
   if (~rst) begin
      state <= IDLE;
      arg_ctr <= 0;
      ptr <= 0;
   end else begin
      state <= state_nxt;
      arg_ctr <= arg_ctr_nxt;
      ptr <= ptr_nxt;
   end
end

endmodule
