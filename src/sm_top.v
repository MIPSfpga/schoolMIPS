
`include "sm_config.vh"

//hardware top level module
module sm_top
(
    input           clkIn,
    input           rst_n,
    input   [ 3:0 ] clkDevide,
    input           clkEnable,
    output          clk,
    input   [ 4:0 ] regAddr,
    output  [31:0 ] regData,

    input      [`SM_GPIO_WIDTH - 1:0] gpioInput, // GPIO output pins
    output     [`SM_GPIO_WIDTH - 1:0] gpioOutput, // GPIO intput pins
    output                            pwmOutput,  // PWM output pin
    output                            alsCS,      // Ligth Sensor chip select
    output                            alsSCK,     // Light Sensor SPI clock
    input                             alsSDO      // Light Sensor SPI data
);
    //metastability input filters
    wire    [ 3:0 ] devide;
    wire            enable;
    wire    [ 4:0 ] addr;

    sm_debouncer #(.SIZE(4)) f0(clkIn, clkDevide, devide);
    sm_debouncer #(.SIZE(1)) f1(clkIn, clkEnable, enable);
    sm_debouncer #(.SIZE(5)) f2(clkIn, regAddr,   addr  );

    //cores
    //clock devider
    sm_clk_divider sm_clk_divider
    (
        .clkIn      ( clkIn     ),
        .rst_n      ( rst_n     ),
        .devide     ( devide    ),
        .enable     ( enable    ),
        .clkOut     ( clk       )
    );

    //instruction memory
    wire    [31:0]  imAddr;
    wire    [31:0]  imData;
    sm_rom reset_rom(imAddr, imData);

    //data bus matrix
    wire    [31:0]  dmAddr;
    wire            dmWe;
    wire    [31:0]  dmWData;
    wire    [31:0]  dmRData;
    sm_matrix matrix
    (
        .clk        ( clk        ),
        .rst_n      ( rst_n      ),
        .bAddr      ( dmAddr     ),
        .bWrite     ( dmWe       ),
        .bWData     ( dmWData    ),
        .bRData     ( dmRData    ),
        .gpioInput  ( gpioInput  ),
        .gpioOutput ( gpioOutput ),
        .pwmOutput  ( pwmOutput  ),
        .alsCS      ( alsCS      ),
        .alsSCK     ( alsSCK     ),
        .alsSDO     ( alsSDO     )
    );

    //cpu core
    sm_cpu sm_cpu
    (
        .clk        ( clk       ),
        .rst_n      ( rst_n     ),
        .regAddr    ( addr      ),
        .regData    ( regData   ),
        .imAddr     ( imAddr    ),
        .imData     ( imData    ),
        .dmAddr     ( dmAddr    ),
        .dmWe       ( dmWe      ),
        .dmWData    ( dmWData   ),
        .dmRData    ( dmRData   )
    );

endmodule

//metastability input debouncer module
module sm_debouncer
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
    parameter shift  = 16,
              bypass = 0
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

    assign clkOut = bypass ? clkIn 
                           : cntr[shift + devide];
endmodule
