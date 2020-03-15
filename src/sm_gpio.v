module sm_gpio
(
    //bus side
    input             clk,
    input             rst_n,
    input             bSel,
    input      [31:0] bAddr,
    input             bWrite,
    input      [31:0] bWData,
    output reg [31:0] bRData,

    //pin side
    input  [sm_config::GPIO_WIDTH - 1:0] gpioInput,
    output [sm_config::GPIO_WIDTH - 1:0] gpioOutput
);
    wire   [sm_config::GPIO_WIDTH - 1:0] gpioIn;    // debounced input signals
    wire                          gpioOutWe; // output Pin value write enable
    wire   [sm_config::GPIO_WIDTH - 1:0] gpioOut;   // output Pin next value

    assign gpioOut   = bWData [sm_config::GPIO_WIDTH - 1:0];
    assign gpioOutWe = bSel & bWrite & (bAddr[3:0] == sm_config::GPIO_REG_OUTPUT);

    sm_debouncer   #(.SIZE(sm_config::GPIO_WIDTH)) debounce(clk, gpioInput, gpioIn);
    sm_register_we #(.SIZE(sm_config::GPIO_WIDTH)) r_output(clk, rst_n, gpioOutWe, gpioOut, gpioOutput);

    localparam BLANK_WIDTH = 32 - sm_config::GPIO_WIDTH;

    always @ (*)
        case(bAddr[3:0])
            default              : bRData = { { BLANK_WIDTH {1'b0}}, gpioIn  };
            sm_config::GPIO_REG_INPUT   : bRData = { { BLANK_WIDTH {1'b0}}, gpioIn  };
            sm_config::GPIO_REG_OUTPUT  : bRData = { { BLANK_WIDTH {1'b0}}, gpioOut };
        endcase

endmodule
