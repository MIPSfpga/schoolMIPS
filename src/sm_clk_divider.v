

module sm_clk_divider
(
    input           clkIn,
    input           rst_n,
    input   [ 4:0 ] devide,
    output          clkOut
);
    wire [31:0] cntr;
    wire [31:0] cntrNext = cntr + 1;
    sm_register r_cntr(clkIn, rst_n, cntrNext, cntr);

    assign clkOut = cntr[devide];
endmodule
