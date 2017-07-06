
module marsohod_3(
      input              CLK100MHZ,
      input       KEY0,
		input       KEY1,
      output      [7:0]  LED

);


//=======================================================
//  REG/WIRE declarations
//=======================================================


    // wires & inputs
    wire          clk;
    wire          clkIn     =  CLK100MHZ;
    wire          rst_n     =  KEY0;
    wire          clkEnable =  ~KEY1;
	 wire [ 31:0 ] regData;
    
    //cores
    sm_clk_divider sm_clk_divider
    (
        .clkIn      ( clkIn     ),
        .rst_n      ( rst_n     ),
        .devide     ( 4'b1000   ),
        .enable     ( clkEnable ),
        .clkOut     ( clk       )
    );

    sm_cpu sm_cpu
    (
        .clk        ( clk       ),
        .rst_n      ( rst_n     ),
        .regAddr    ( 4'b0010   ),
        .regData    ( regData   )
    );

    //outputs
    assign LED[0]   = clk;
    assign LED[7:1] = regData[6:0];

    //wire [ 31:0 ] h7segment = regData;

//    assign HEX0 [7] = 1'b1;
//    assign HEX1 [7] = 1'b1;
//    assign HEX2 [7] = 1'b1;
//    assign HEX3 [7] = 1'b1;
//    assign HEX4 [7] = 1'b1;
//    assign HEX5 [7] = 1'b1;

//    sm_hex_display digit_5 ( h7segment [23:20] , HEX5 [6:0] );
//    sm_hex_display digit_4 ( h7segment [19:16] , HEX4 [6:0] );
//    sm_hex_display digit_3 ( h7segment [15:12] , HEX3 [6:0] );
//    sm_hex_display digit_2 ( h7segment [11: 8] , HEX2 [6:0] );
//    sm_hex_display digit_1 ( h7segment [ 7: 4] , HEX1 [6:0] );
//    sm_hex_display digit_0 ( h7segment [ 3: 0] , HEX0 [6:0] );


//=======================================================
//  Structural coding
//=======================================================





endmodule
