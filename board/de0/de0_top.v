
module de0_top
    (
        input           CLOCK_50,       //    Clock 50 MHz
        input           CLOCK_50_2,     //    Clock 50 MHz

        input    [ 2:0] BUTTON,         //    Pushbutton[2:0]

        input    [ 9:0] SW,             //    Toggle Switch[9:0]

        output   [ 6:0] HEX0_D,         //    Seven Segment Digit 0
        output          HEX0_DP,        //    Seven Segment Digit DP 0
        output   [ 6:0] HEX1_D,         //    Seven Segment Digit 1
        output          HEX1_DP,        //    Seven Segment Digit DP 1
        output   [ 6:0] HEX2_D,         //    Seven Segment Digit 2
        output          HEX2_DP,        //    Seven Segment Digit DP 2
        output   [ 6:0] HEX3_D,         //    Seven Segment Digit 3
        output          HEX3_DP,        //    Seven Segment Digit DP 3

        output   [ 9:0] LEDG,           //    LED Green[9:0]

        output          UART_TXD,       //    UART Transmitter
        input           UART_RXD,       //    UART Receiver
        output          UART_CTS,       //    UART Clear To Send
        input           UART_RTS,       //    UART Request To Send

        inout    [15:0] DRAM_DQ,        //    SDRAM Data bus 16 Bits
        output   [12:0] DRAM_ADDR,      //    SDRAM Address bus 13 Bits
        output          DRAM_LDQM,      //    SDRAM Low-byte Data Mask
        output          DRAM_UDQM,      //    SDRAM High-byte Data Mask
        output          DRAM_WE_N,      //    SDRAM Write Enable
        output          DRAM_CAS_N,     //    SDRAM Column Address Strobe
        output          DRAM_RAS_N,     //    SDRAM Row Address Strobe
        output          DRAM_CS_N,      //    SDRAM Chip Select
        output          DRAM_BA_0,      //    SDRAM Bank Address 0
        output          DRAM_BA_1,      //    SDRAM Bank Address 1
        output          DRAM_CLK,       //    SDRAM Clock
        output          DRAM_CKE,       //    SDRAM Clock Enable

        inout    [14:0] FL_DQ,          //    FLASH Data bus 15 Bits
        inout           FL_DQ15_AM1,    //    FLASH Data bus Bit 15 or Address A-1
        output   [21:0] FL_ADDR,        //    FLASH Address bus 22 Bits
        output          FL_WE_N,        //    FLASH Write Enable
        output          FL_RST_N,       //    FLASH Reset
        output          FL_OE_N,        //    FLASH Output Enable
        output          FL_CE_N,        //    FLASH Chip Enable
        output          FL_WP_N,        //    FLASH Hardware Write Protect
        output          FL_BYTE_N,      //    FLASH Selects 8/16-bit mode
        input           FL_RY,          //    FLASH Ready/Busy

        inout    [ 7:0] LCD_DATA,       //    LCD Data bus 8 bits
        output          LCD_BLON,       //    LCD Back Light ON/OFF
        output          LCD_RW,         //    LCD Read/Write Select, 0 = Write, 1 = Read
        output          LCD_EN,         //    LCD Enable
        output          LCD_RS,         //    LCD Command/Data Select, 0 = Command, 1 = Data

        inout           SD_DAT0,        //    SD Card Data 0
        inout           SD_DAT3,        //    SD Card Data 3
        inout           SD_CMD,         //    SD Card Command Signal
        output          SD_CLK,         //    SD Card Clock
        input           SD_WP_N,        //    SD Card Write Protect

        inout           PS2_KBDAT,      //    PS2 Keyboard Data
        inout           PS2_KBCLK,      //    PS2 Keyboard Clock
        inout           PS2_MSDAT,      //    PS2 Mouse Data
        inout           PS2_MSCLK,      //    PS2 Mouse Clock

        output          VGA_HS,         //    VGA H_SYNC
        output          VGA_VS,         //    VGA V_SYNC
        output   [3:0]  VGA_R,          //    VGA Red[3:0]
        output   [3:0]  VGA_G,          //    VGA Green[3:0]
        output   [3:0]  VGA_B,          //    VGA Blue[3:0]

        input    [ 1:0] GPIO0_CLKIN,    //    GPIO Connection 0 Clock In Bus
        output   [ 1:0] GPIO0_CLKOUT,   //    GPIO Connection 0 Clock Out Bus
        inout    [31:0] GPIO0_D,        //    GPIO Connection 0 Data Bus
        input    [ 1:0] GPIO1_CLKIN,    //    GPIO Connection 1 Clock In Bus
        output   [ 1:0] GPIO1_CLKOUT,   //    GPIO Connection 1 Clock Out Bus
        inout    [31:0] GPIO1_D         //    GPIO Connection 1 Data Bus
    );

    // wires & inputs
    wire          clk;
    wire          clkIn     =  CLOCK_50;
    wire          rst_n     =  BUTTON[0];
    wire          clkEnable =  SW [9] | ~BUTTON[1];
    wire [  3:0 ] clkDevide =  SW [8:5];
    wire [  4:0 ] regAddr   =  SW [4:0];
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
    assign LEDG[0]   = clk;
    assign LEDG[9:1] = regData[8:0];

    wire [ 31:0 ] h7segment = regData;

    assign HEX0_DP = 1'b1;
    assign HEX0_DP = 1'b1;
    assign HEX0_DP = 1'b1;
    assign HEX0_DP = 1'b1;

    sm_hex_display digit_3 ( h7segment [15:12] , HEX3_D [6:0] );
    sm_hex_display digit_2 ( h7segment [11: 8] , HEX2_D [6:0] );
    sm_hex_display digit_1 ( h7segment [ 7: 4] , HEX1_D [6:0] );
    sm_hex_display digit_0 ( h7segment [ 3: 0] , HEX0_D [6:0] );

endmodule
