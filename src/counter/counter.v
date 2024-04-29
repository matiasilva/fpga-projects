module counter(
    input CLK,
	output P1A1, P1A2, P1A3, P1A4, P1A7, P1A8, P1A9, P1A10
);

/*
    using the 1bitsquared 7 segment display PMOD

    ////AAAA////        ////AAAA//// 
    //        //        //        //
    FF        BB        FF        BB
    //        //        //        //
    ////GGGG////        ////GGGG////
    //        //        //        //
    EE        CC        EE        CC
    //        //        //        //
    ////DDDD////        ////DDDD////

    pin assignments:
    AA --> P1A1
    AB --> P1A2
    AC --> P1A3
    AD --> P1A4
    AE --> P1A7
    AF --> P1A8
    AG --> P1A9
    CA --> P1A10 (mux for digits)
    (decimal point unconnected)
*/
    localparam COUNT_MAX = 99;

    reg [7:0] count;
    wire [3:0] msd; // most significant digit
    wire [3:0] lsd;

    always @(*) begin
        
    end

    wire ss_ctrl;
    wire [6:0] ss_bits;
	wire [7:0] seven_segment = {ss_ctrl, ss_bits}; // control and data bus
	assign { P1A10, P1A9, P1A8, P1A7, P1A4, P1A3, P1A2, P1A1 } = seven_segment; // assign to PMOD

    seven_seg_decoder ss_decode_u(
        .din()
    );

    module seven_seg_decoder (
        input [3:0] din,
        output [6:0] dout
    );
        reg digit;
        always @(*) begin
            digit = 7'b 1000000; // no latches
            case (din)
                4'h0: digit = 7'b 0111111;
                4'h1: digit = 7'b 0000110;
                4'h2: digit = 7'b 1011011;
                4'h3: digit = 7'b 1011011;
                4'h4: digit = 7'b 1100110;
                4'h5: digit = 7'b 1101101;
                4'h6: digit = 7'b 1111101;
                4'h7: digit = 7'b 0000111;
                4'h8: digit = 7'b 1011011;
                4'h9: digit = 7'b 1101111;
                4'hA: digit = 7'b 1110111;
                4'hB: digit = 7'b 1111100;
                4'hC: digit = 7'b 0111001;
                4'hD: digit = 7'b 1011110;
                4'hE: digit = 7'b 1111001;
                4'hF: digit = 7'b 1110001;
            endcase
        end
        assign dout = digit;
    endmodule

endmodule
