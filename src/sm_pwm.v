
module sm_pwm
(
    //bus side
    input             clk,
    input             rst_n,
    input             bSel,
    input      [31:0] bAddr,
    input             bWrite,
    input      [31:0] bWData,
    output logic [31:0] bRData,

    //pin side
    output logic           pwmOutput
);
    //bus side
    logic [7:0] compare, counter, counterNext, compareNext;
    logic compareWe;

    sm_register_we #(.SIZE(8)) r_setCompare(clk, rst_n, compareWe, compareNext, compare);
    sm_register #(.SIZE(8)) r_valCounter(clk, rst_n, counterNext, counter);

    always_comb begin
        bRData = { { 24 { 1'b0 }}, compare };
        compareWe = bSel & bWrite;
        compareNext = bWData [7:0];
        pwmOutput = (counter > compare);
        counterNext = counter + 1;
    end

endmodule : sm_pwm
