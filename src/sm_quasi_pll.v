

module sm_quasi_pll
#(
    parameter shift = 16
)
(
    input           clkIn,
    input           rst_n,
    input   [ 3:0 ] devide,
    input           forceOut,
    output          clkOut
);
    wire [31:0] cntr;
    wire [31:0] cntrNext = cntr + 1;
    sm_register r_cntr(clkIn, rst_n, cntrNext, cntr);

    assign clkOut = (devide != 0) ? cntr[shift + devide] | forceOut
                                  : forceOut;
endmodule
