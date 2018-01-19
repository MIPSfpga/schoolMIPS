
module sm_pwm
(
    //bus side
    input             clk,
    input             rst_n,
    input             bSel,
    input      [31:0] bAddr,
    input             bWrite,
    input      [31:0] bWData,
    output     [31:0] bRData,

    //pin side
    output            pwmOutput
);
    //bus side
    wire [7:0] compare;
    wire [7:0] counter;

    assign bRData = { { 24 { 1'b0 }}, compare };

    wire compareWe = bSel & bWrite;
    wire [7:0] compareNext = bWData [7:0];
    sm_register_we #(.SIZE(8)) r_setCompare(clk, rst_n, compareWe, compareNext, compare);

    //pwm side
    assign pwmOutput = (counter > compare);
    wire [7:0] counterNext = counter + 1;
    sm_register #(.SIZE(8)) r_valCounter(clk, rst_n, counterNext, counter);

endmodule
