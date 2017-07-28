
module de10_nano
(
    output          ADC_CONVST,
    output          ADC_SCK,
    output          ADC_SDI,
    input           ADC_SDO,

    inout   [15:0]  ARDUINO_IO,
    inout           ARDUINO_RESET_N,

    input           FPGA_CLK1_50,
    input           FPGA_CLK2_50,
    input           FPGA_CLK3_50,

    inout           HDMI_I2C_SCL,
    inout           HDMI_I2C_SDA,
    inout           HDMI_I2S,
    inout           HDMI_LRCLK,
    inout           HDMI_MCLK,
    inout           HDMI_SCLK,
    output          HDMI_TX_CLK,
    output          HDMI_TX_DE,
    output  [23:0]  HDMI_TX_D,
    output          HDMI_TX_HS,
    input           HDMI_TX_INT,
    output          HDMI_TX_VS,

    input   [ 1:0]  KEY,
    output  [ 7:0]  LED,
    input   [ 3:0]  SW,

    inout   [35:0]  GPIO_0,
    inout   [35:0]  GPIO_1
);

    // wires & inputs
    wire          clk;
    wire          clkIn     =  FPGA_CLK1_50;
    wire          rst_n     =  KEY[0];
    wire          clkEnable =  ~KEY[1];
    wire [  3:0 ] clkDevide =  4'b1000;
    wire [  4:0 ] regAddr   =  { 1'b0, SW [3:0] };
    wire [ 31:0 ] regData;

    //cores
    sm_top sm_top
    (
        .clkIn      ( clkIn     ),
        .rst_n      ( rst_n     ),
        .clkDevide  ( clkDevide ),
        .clkEnable  ( clkEnable ),
        .clk        ( clk       ),
        .regAddr    ( regAddr   ),
        .regData    ( regData   )
    );

    //outputs
    assign LED[0]   = clk;
    assign LED[7:1] = regData[6:0];

endmodule
