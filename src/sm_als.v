module sm_als
(
    input             clk,
    input             rst_n,
    output logic cs,
    output logic sck,
    input             sdo,
    output logic [31:0] value
);
    logic sample_bit, value_done;
    logic [8:0] cnt, cntNext;
    logic [15:0] shift, shiftNext, val;

    sm_register #(.SIZE(9)) r_counter(clk, rst_n, cntNext, cnt);
    sm_register_we #(.SIZE(16)) r_shift(clk, rst_n, sample_bit, shiftNext, shift);
    sm_register_we #(.SIZE(16)) r_value(clk, rst_n, value_done, shift, val);

    always_comb begin
        cntNext = cnt + 1;
        sck = ~cnt[3];
        cs  = ~cnt[8];

        sample_bit = ( cs == 1'b0 && cnt [3:0] == 4'b1111 );
        value_done = ( cs == 1'b1 && cnt [7:0] == 8'b0 );

        shiftNext = (shift << 1) | sdo;
        value = { {16 {1'b0}}, val };

    end

endmodule : sm_als
