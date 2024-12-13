`default_nettype none
`include "lcd_st7789v3.vh"

module ram_writer #(
   parameter WORD_WIDTH = 8,
   parameter PACKET_WIDTH = 9
)(
   input wire clk,
   input wire rst,

   output reg valid,
   input wire ready,
   output reg [PACKET_WIDTH-1:0] data,

   input wire en,
   output reg done
);

localparam IDLE = 2'b00;
localparam CMD = 2'b01;
localparam DATA = 2'b10;

localparam RED = {{6{1'b1}}, 2'b00};
localparam GREEN = {8{1'b0}};
localparam BLUE = {8{1'b0}};

localparam DATA_MAX_CNT = 3*135*120; // half

reg [1:0] state, state_nxt;
reg [$clog2(DATA_MAX_CNT)-1:0] data_ctr, data_ctr_nxt;

always @(*) begin
   state_nxt = state;
   data_ctr_nxt = data_ctr;
   valid = 1'b1;
   data = 0;

   case (state)
      IDLE: begin
         if (en) state_nxt = CMD;
         valid = 1'b0;
      end
      CMD: begin
         if (ready) begin // we expect to fill FIFO pretty quickly
            state_nxt = DATA;
            data_ctr_nxt = DATA_MAX_CNT - 1;
            data = {1'b0, 8'h2C}; // RAMWR
         end
      end
      DATA: begin
         if (ready) begin
            data_ctr_nxt = data_ctr - 1;
            case (data_ctr % 3)
               2'b00: data = {1'b1, BLUE};
               2'b01: data = {1'b1, GREEN};
               2'b10: data = {1'b1, RED};
            endcase
         end
         if (data_ctr == 0) begin
            state_nxt = IDLE;
            done = 1'b1;
         end
      end
   endcase
end

always @(posedge clk or negedge rst) begin
   if (~rst) begin
      state <= IDLE;
      data_ctr <= 0;
   end else begin
      state <= state_nxt;
      data_ctr <= data_ctr_nxt;
   end

end

endmodule
