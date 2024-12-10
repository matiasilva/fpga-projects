`default_nettype none
// TODO: add MSB/LSB toggle

// Consumes data from a source, like a FIFO, and serializes it
// Data launches immediately as it is latched in

module serdes #(
   parameter WORD_WIDTH = 8,
   parameter PACKET_WIDTH = 9 // packet = metadata + word
) (
   input clk,
   input rst,

   // data in port
   output reg ready,
   input wire valid,
   input wire [PACKET_WIDTH-1:0] data,

   // serial data
   output wire sd,
   output wire cs,
   output wire sck,
   output wire rs
);

localparam BIT_PTR_MAX = (1 << $clog2(WORD_WIDTH)) - 1;
localparam RSEL_MSB = PACKET_WIDTH-1;

reg [$clog2(WORD_WIDTH)-1:0] bit_ptr, bit_ptr_nxt;
reg [PACKET_WIDTH-1:0] frame, frame_nxt;
wire last_bit = bit_ptr == 0;

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

   ready = 1'b0;
   case (state)
      IDLE: begin
         ready = 1'b1;
         if (valid && ready) begin
            state_nxt = ACTIVE;
            frame_nxt = data;
         end
      end
      ACTIVE: begin
         if (last_bit) begin
            bit_ptr_nxt = BIT_PTR_MAX;
            ready = 1'b1;
            if (valid && ready) // continue in ACTIVE if FIFO has data
               frame_nxt = data;
            else
               state_nxt = IDLE;
         end else begin
            bit_ptr_nxt = bit_ptr - 1;
         end
      end
   endcase
end

assign sd = frame[bit_ptr];
assign rs = frame[RSEL_MSB];
assign cs = !(state == ACTIVE);
assign sck = clk && ~cs;

endmodule
