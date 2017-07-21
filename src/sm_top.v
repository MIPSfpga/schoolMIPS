
//hardware top level module
module sm_top
(
    input           clkIn,
    input           rst_n,
    input   [ 3:0 ] clkDevide,
    input           clkEnable,
    output          clk,
    input   [ 4:0 ] regAddr,
    output  [31:0 ] regData
);
    //metastability input filters
    wire    [ 3:0 ] devide;
    wire            enable;
    wire    [ 4:0 ] addr;

    sm_metafilter #(.SIZE(4)) f0(clkIn, clkDevide, devide);
    sm_metafilter #(.SIZE(1)) f1(clkIn, clkEnable, enable);
    sm_metafilter #(.SIZE(5)) f2(clkIn, regAddr,   addr  );

    //cores
    sm_clk_divider sm_clk_divider
    (
        .clkIn      ( clkIn     ),
        .rst_n      ( rst_n     ),
        .devide     ( devide    ),
        .enable     ( enable    ),
        .clkOut     ( clk       )
    );

    sm_cpu sm_cpu
    (
        .clk        ( clk       ),
        .rst_n      ( rst_n     ),
        .regAddr    ( addr      ),
        .regData    ( regData   )
    );

endmodule

//metastability input filter module
module sm_metafilter
#(
    parameter SIZE = 1
)
(
    input                      clk,
    input      [ SIZE - 1 : 0] d,
    output reg [ SIZE - 1 : 0] q
);
    reg        [ SIZE - 1 : 0] data;

    always @ (posedge clk) begin
        data <= d;
        q    <= data;
    end

endmodule

//tunable clock devider
module sm_clk_divider
#(
    parameter shift = 16
)
(
    input           clkIn,
    input           rst_n,
    input   [ 3:0 ] devide,
    input           enable,
    output          clkOut
);
    wire [31:0] cntr;
    wire [31:0] cntrNext = cntr + 1;
    sm_register_we r_cntr(clkIn, rst_n, enable, cntrNext, cntr);

    assign clkOut = cntr[shift + devide];
endmodule
