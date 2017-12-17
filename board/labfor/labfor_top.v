module labfor_top (
	input			CLK,	// Clock 50 MHz
	input			A1,		// Switches
	input			B1,
	input			C1,
	input			D1,
	input			A2,
	input			B2,
	input			C2,
	input			D2,
	
	output	[7:0]	LED,
	output			IND_1A,		// The 1st 7-segment indicator
	output			IND_1B,
	output			IND_1C,
	output			IND_1D,
	output			IND_1E,
	output			IND_1F,
	output			IND_1G,		
	output			IND_1H,		// Decimal point
	output			IND_2A,		// The 2nd 7-segment indicator
	output			IND_2B,
	output			IND_2C,
	output			IND_2D,
	output			IND_2E,
	output			IND_2F,
	output			IND_2G,
	output			IND_2H		// Decimal point
);


wire			clkIn = CLK;
wire			rst_n = A2;
wire			clkEnable = B2;
wire	[3:0]	clkDevide = 4'b1010;
wire	[4:0]	regAddr = {C1, B1, A1, D2, C2};	// Управляем выводом регистра с помощью пяти переключателей
wire	[31:0]	regData;						// Выводимый регистр с номером regAddr
wire 			clk_n;


sm_top sm_top
    (
        .clkIn      ( clkIn     ),
        .rst_n      ( rst_n     ),
        .clkDevide  ( clkDevide ),
        .clkEnable  ( clkEnable ),
        .clk        ( clk_n     ),
        .regAddr    ( regAddr   ),	// Подключение адреса
        .regData    ( regData   )	// Подключение вывода регистра
    );

assign IND_1H = 1'b1;
assign IND_2H = 1'b1;

wire	[31:0]	h7segment = regData;	// Вывод значения на другой wire
wire	[6:0]	HEX0_D = {IND_1A, IND_1B, IND_1C, IND_1D, IND_1E, IND_1F, IND_1G};
wire	[6:0]	HEX1_D = {IND_2A, IND_2B, IND_2C, IND_2D, IND_2E, IND_2F, IND_2G};

assign LED[7:1] = h7segment[6:0];	// Вывод младших бит на светодиоды 
assign LED[0] = clk_n;				// Вывод тактового сигнала на первый светодиод

sm_hex_display digit_1 ( h7segment [ 7: 4] , {IND_1A, IND_1B, IND_1C, IND_1D, IND_1E, IND_1F, IND_1G} );
sm_hex_display digit_0 ( h7segment [ 3: 0] , {IND_2A, IND_2B, IND_2C, IND_2D, IND_2E, IND_2F, IND_2G} );



endmodule 