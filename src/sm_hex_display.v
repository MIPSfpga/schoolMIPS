
module sm_hex_display
(
    input      [3:0] digit,
    output reg [6:0] seven_segments
);

    always @*
        case (digit)
        'h0: seven_segments = 'b1000000;  // a b c d e f g
        'h1: seven_segments = 'b1111001;
        'h2: seven_segments = 'b0100100;  //   --a--
        'h3: seven_segments = 'b0110000;  //  |     |
        'h4: seven_segments = 'b0011001;  //  f     b
        'h5: seven_segments = 'b0010010;  //  |     |
        'h6: seven_segments = 'b0000010;  //   --g--
        'h7: seven_segments = 'b1111000;  //  |     |
        'h8: seven_segments = 'b0000000;  //  e     c
        'h9: seven_segments = 'b0011000;  //  |     |
        'ha: seven_segments = 'b0001000;  //   --d-- 
        'hb: seven_segments = 'b0000011;
        'hc: seven_segments = 'b1000110;
        'hd: seven_segments = 'b0100001;
        'he: seven_segments = 'b0000110;
        'hf: seven_segments = 'b0001110;
        endcase

endmodule

//--------------------------------------------------------------------

module sm_hex_display_8
(
    input             clock,
    input             resetn,
    input      [31:0] number,

    output reg [ 6:0] seven_segments,
    output reg        dot,
    output reg [ 7:0] anodes
);

    function [6:0] bcd_to_seg (input [3:0] bcd);

        case (bcd)
        'h0: bcd_to_seg = 'b1000000;  // a b c d e f g
        'h1: bcd_to_seg = 'b1111001;
        'h2: bcd_to_seg = 'b0100100;  //   --a--
        'h3: bcd_to_seg = 'b0110000;  //  |     |
        'h4: bcd_to_seg = 'b0011001;  //  f     b
        'h5: bcd_to_seg = 'b0010010;  //  |     |
        'h6: bcd_to_seg = 'b0000010;  //   --g--
        'h7: bcd_to_seg = 'b1111000;  //  |     |
        'h8: bcd_to_seg = 'b0000000;  //  e     c
        'h9: bcd_to_seg = 'b0011000;  //  |     |
        'ha: bcd_to_seg = 'b0001000;  //   --d-- 
        'hb: bcd_to_seg = 'b0000011;
        'hc: bcd_to_seg = 'b1000110;
        'hd: bcd_to_seg = 'b0100001;
        'he: bcd_to_seg = 'b0000110;
        'hf: bcd_to_seg = 'b0001110;
        endcase

    endfunction

    reg [2:0] i;

    always @ (posedge clock or negedge resetn)
    begin
        if (! resetn)
        begin
            seven_segments <=   bcd_to_seg (0);
            dot            <= ~ 0;
            anodes         <= ~ 8'b00000001;

            i <= 0;
        end
        else
        begin
            seven_segments <=   bcd_to_seg (number [i * 4 +: 4]);
            dot            <= ~ 0;
            anodes         <= ~ (1 << i);

            i <= i + 1;
        end
    end

endmodule