

`include "sm_config.vh"

`define SM_GPIO_REG_INPUT   4'h0
`define SM_GPIO_REG_OUTPUT  4'h4

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
    input  [`SM_GPIO_WIDTH - 1:0] gpioInput,
    output [`SM_GPIO_WIDTH - 1:0] gpioOutput
);
    wire   [`SM_GPIO_WIDTH - 1:0] gpioIn;    // debounced input signals
    wire                          gpioOutWe; // output Pin value write enable
    wire   [`SM_GPIO_WIDTH - 1:0] gpioOut;   // output Pin next value

    assign gpioOut   = bWData [`SM_GPIO_WIDTH - 1:0];
    assign gpioOutWe = bSel & bWrite & (bAddr[3:0] == `SM_GPIO_REG_OUTPUT);

    sm_debouncer   #(.SIZE(`SM_GPIO_WIDTH)) debounce(clk, gpioInput, gpioIn);
    sm_register_we #(.SIZE(`SM_GPIO_WIDTH)) r_output(clk, rst_n, gpioOutWe, gpioOut, gpioOutput);

    localparam BLANK_WIDTH = 32 - `SM_GPIO_WIDTH;

    always @ (*)
        case(bAddr[3:0])
            default              : bRData = { { BLANK_WIDTH {1'b0}}, gpioIn  };
            `SM_GPIO_REG_INPUT   : bRData = { { BLANK_WIDTH {1'b0}}, gpioIn  };
            `SM_GPIO_REG_OUTPUT  : bRData = { { BLANK_WIDTH {1'b0}}, gpioOut };
        endcase

endmodule
