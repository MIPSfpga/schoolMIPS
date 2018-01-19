
module sm_als
(
    input             clk,
    input             rst_n,
    output            cs,
    output            sck,
    input             sdo,
    output     [31:0] value
);
    wire [ 8:0] cnt;
    wire [ 8:0] cntNext = cnt + 1;
    sm_register #(.SIZE(9)) r_counter(clk, rst_n, cntNext, cnt);

    assign sck = ~ cnt [3];
    assign cs  = ~ cnt [8];

    wire sample_bit = ( cs == 1'b0 && cnt [3:0] == 4'b1111 );
    wire value_done = ( cs == 1'b1 && cnt [7:0] == 8'b0 );

    wire [15:0] shift;
    wire [15:0] shiftNext = (shift << 1) | sdo;
    sm_register_we #(.SIZE(16)) r_shift(clk, rst_n, sample_bit, shiftNext, shift);

    wire [15:0] val;
    sm_register_we #(.SIZE(16)) r_value(clk, rst_n, value_done, shift, val);

    assign value = { {16 {1'b0}}, val };

endmodule
