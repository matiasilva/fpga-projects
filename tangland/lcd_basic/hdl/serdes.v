`default_nettype none
// TODO: add MSB/LSB toggle

// Consumes data from a source, like a FIFO, and serializes it
// Data launches immediately as it is latched in

module serdes #(
   parameter WORD_WIDTH = 8
) (
   input clk,
   input rst,

   // data in port
   output wire ready,
   input wire valid,
   input wire [WORD_WIDTH-1:0] data,

   // serial data
   output wire sd
);

localparam BIT_PTR_MAX = (1 << $clog2(WORD_WIDTH)) - 1;

reg [$clog2(WORD_WIDTH)-1:0] bit_ptr, bit_ptr_nxt;
reg [7:0] frame, frame_nxt;

typedef enum reg[1:0] {
   IDLE,
   ACTIVE
} state_t;

state_t state, state_nxt;

always @(posedge clk or negedge rst) begin
   if (~rst) begin
      bit_ptr <= BIT_PTR_MAX; // MSB first
      frame <= 0;
      state <= IDLE;
   end else begin
      bit_ptr <= bit_ptr_nxt;
      frame <= frame_nxt;
      state <= state_nxt;
   end
end

always @(*) begin
   state_nxt = state;
   frame_nxt = frame;
   bit_ptr_nxt = bit_ptr;
   case (state)
      IDLE: begin
         if (valid && ready) begin
            state_nxt = ACTIVE;
            frame_nxt = data;
         end
      end
      ACTIVE: begin
         if (bit_ptr == 0) begin
            bit_ptr_nxt = BIT_PTR_MAX;
            state_nxt = IDLE;
         end else begin
            bit_ptr_nxt = bit_ptr - 1;
         end
      end
   endcase
end

assign ready = state == IDLE;
assign sd = frame[bit_ptr];

endmodule
