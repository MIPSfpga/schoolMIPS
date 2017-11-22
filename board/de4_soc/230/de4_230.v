// ============================================================================
// Copyright (c) 2012 by Terasic Technologies Inc.
// ============================================================================
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// ============================================================================
//           
//  Terasic Technologies Inc
//  9F., No.176, Sec.2, Gongdao 5th Rd, East Dist, Hsinchu City, 30070. Taiwan
//
//
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// ============================================================================
//
// Major Functions:	DE4 GODLDEN TOP
//
// ============================================================================
//
// Revision History :
// ============================================================================
//   Ver  :| Author            :| Mod. Date :| Changes Made:
//   V1.0 :| Johnny FAN        :| 07/07/09  :| Initial Revision
// 	 V1.01:| Johnny FAN        :| 12/24/09  :| Rename "BUTTON_90D" to "BUTTON_SLIDE"
//   V1.02:| Johnny FAN        :| 12/24/09  :| change "PCIE_REFCLK_p" i/o standatd
//												from "LVDS"	to "HCSL"
//   V1.03:| Johnny FAN        :| 12/26/09  :| UPDATE  SATSA and GPIO0_D PIN NAME
//   v1.04:| Johnny FAN        :| 12/28/09  :| Update ddr2 pin		
//	 v1.05:| Johnny FAN        :| 01/06/10  :| Update gpio max pin assignment	
//	 v1.06:| Johnny FAN        :| 01/06/10  :|i. Change pin direction of "CSENSE_SCK" from
//											   ""output" to "inout" 
//											  ii. Change pin direction of "CSENSE_SDI" from
//											   ""input" to "output"
//											  iii. Change pin direction of "CSENSE_SDO" from
//											   ""input" to "output"  
//	 v1.07:| Johnny FAN        :| 01/07/10  :| Correct I/o standard of "SATA_DEVICE_RX_p[0]" 
//												from LVDS to "1.4-V PCML"		
//   v1.08:| Johnny FAN        :| 01/11/10  :| Correct I/o standard of "GPIO" 
//												from 2.5V to "3.0-V PCI-X"		
//   v1.09:| Johnny FAN        :| 01/12/10  :| Modify Ethernt interface net
//   v1.10:| Johnny FAN        :| 01/12/10  :| Change pin direction of "PCIE_SMBCLK" from
//											   ""output" to "input" 	
//   v1.11:| Johnny FAN        :| 01/13/10  :| Rename "OSC_50_B[7:2]" to "OSC_50_BANK2~
//												OSC_50_BANK7"
//   v1.12:| Johnny FAN        :| 01/13/10  :| i.Rename "BUTTON_SLIDE" to "EXT_IO"
//											   ii. Correct I/o standard of "BUTTON[3:0]" from
//												 "2.5v" to "3.0-V PCI-X" 	
//   v1.13:| Johnny FAN        :| 01/18/10  :| i.Modify the pin assignemt of "HSMB_GXB",
//												 "HSMA_GXB_", "PCIE" .
//   v1.14:| Johnny FAN        :| 01/19/10  :| i.Rename "SMA_GXBCLK_p0" to "SMA_GXBCLK_p"
//											   ii. Modify HSMA & HSMB pin name and pin  //	
//                                              				 
//   v1.15:| Johnny FAN        :| 01/19/10  :| i.Rename "GCLK_IN" to "GCLKIN"
//   v1.16:| Johnny FAN        :| 01/27/10  :| modify pin assignment for "OSC_50_B3"
//												"OSC_50_B4", and "GCLKIN".	
//   v1.17:| Johnny FAN        :| 03/14/10  :| i. modify pin assginment for "GPIO0_D0",GPIO0_D2
//												GPIO0_D30, GPIO1_D33, SEG0_DP, SEG1_DP.
//											   ii. remove MAX_PLL_D[2:0]
//											   iii. add MAX_CONF_D3
//   v1.18:| Johnny FAN        :| 03/22/10  :| i. modify pin assginment for "LED,BUTTON,SLIDE_SW,
//											     SEG0_D,SEG0_DP , SEG1_D,SEG1_DP   
//   v1.19:| Bei He            :| 04/07/10  :| i. Rename   HSMC clock input pin from HSMA_CLKIN_n[1] 
//                                             to  HSMA_CLKIN_n1  
//                                             ii same with HSMB clock input pin    
//   v1.20:| Bei He            :| 05/12/10  :| i. remove "ETH_PSE_INT_n" ,ETH_PSE_RST_n",
//													"ETH_PSE_SCK","ETH_PSE_SDA"
//												ii. add  "UART_CTS","UART_RTS","UART_RXD","UART_TXD"
//	  V2.0 :| Dee Zeng          :|2012/02/04 :| Porting to Q11.1SP1  											
// ============================================================================

module DE4_GOLDEN_TOP(

	//////// CLOCK //////////
	OSC_50_BANK2,
	OSC_50_BANK3,
	OSC_50_BANK4,
	OSC_50_BANK5,
	OSC_50_BANK6,
	OSC_50_BANK7,
	PLL_CLKIN_p,
	SMA_CLKIN_p,
//	SMA_GXBCLK_p,  // xcvr 
	GCLKIN,
	GCLKOUT_FPGA,
	SMA_CLKOUT_p,

	//////// CPU RESET //////////
	CPU_RESET_n,

	//////// MAX I/O //////////
	MAX_CONF_D,
	MAX_I2C_SCLK,
	MAX_I2C_SDAT,

	//////// LED x 8 //////////
	LED,

	//////// BUTTON x 4 //////////
	BUTTON,
	
	//////// SWITCH x 8 //////////
	SW,

	//////// SLIDE SWITCH x 4 //////////
	SLIDE_SW,

	//////// Temperature //////////
	TEMP_SMCLK,
	TEMP_SMDAT,
	TEMP_INT_n,

	//////// Current //////////
	CSENSE_ADC_FO,
	CSENSE_SCK,
	CSENSE_SDI,
	CSENSE_SDO,
	CSENSE_CS_n,
	
	//////// Fan //////////
	FAN_CTRL,

	//////// EEPROM //////////
	EEP_SCL,
	EEP_SDA,

	//////// SDCARD //////////
	SD_CLK,
	SD_CMD,
	SD_DAT,
	SD_WP_n,

//	//////// Ethernet x 4 //////////
//	ETH_INT_n,
//	ETH_MDC,
//	ETH_MDIO,
//	ETH_RST_n,
//	ETH_RX_p,
//	ETH_TX_p,
//
//	//////// PCIe x 8 //////////
//	PCIE_PREST_n,
//	PCIE_REFCLK_p,
//	PCIE_RX_p,
//	PCIE_SMBCLK,
//	PCIE_SMBDAT,
//	PCIE_TX_p,
//	PCIE_WAKE_n,

	//////// Flash and SRAM Address/Data Share Bus //////////
	FSM_A,
	FSM_D,

	//////// Flash Control //////////
	FLASH_ADV_n,
	FLASH_CE_n,
	FLASH_CLK,
	FLASH_OE_n,
	FLASH_RESET_n,
	FLASH_RYBY_n,
	FLASH_WE_n,

	//////// SSRAM Control //////////
	SSRAM_ADV,
	SSRAM_BWA_n,
	SSRAM_BWB_n,
	SSRAM_CE_n,
	SSRAM_CKE_n,
	SSRAM_CLK,
	SSRAM_OE_n,
	SSRAM_WE_n,

	//////// Flash and SRAM Address/Data Share Bus //////////
	OTG_A,
	OTG_CS_n,
	OTG_D,
	OTG_DC_DACK,
	OTG_DC_DREQ,
	OTG_DC_IRQ,
	OTG_HC_DACK,
	OTG_HC_DREQ,
	OTG_HC_IRQ,
	OTG_OE_n,
	OTG_RESET_n,
	OTG_WE_n,

//	//////// SATA //////////
//	SATA_REFCLK_p,
//	SATA_HOST_RX_p,
//	SATA_HOST_TX_p,
//	SATA_DEVICE_RX_p,
//	SATA_DEVICE_TX_p,


//	//////// DDR2 SODIMM //////////
//	M1_DDR2_addr,
//	M1_DDR2_ba,
//	M1_DDR2_cas_n,
//	M1_DDR2_cke,
//	M1_DDR2_clk,
//	M1_DDR2_clk_n,
//	M1_DDR2_cs_n,
//	M1_DDR2_dm,
//	M1_DDR2_dq,
//	M1_DDR2_dqs,
//	M1_DDR2_dqsn,
//	M1_DDR2_odt,
//	M1_DDR2_ras_n,
//	M1_DDR2_SA,
//	M1_DDR2_SCL,
//	M1_DDR2_SDA,
//	M1_DDR2_we_n,
//
//	//////// DDR2 SODIMM //////////
//	M2_DDR2_addr,
//	M2_DDR2_ba,
//	M2_DDR2_cas_n,
//	M2_DDR2_cke,
//	M2_DDR2_clk,
//	M2_DDR2_clk_n,
//	M2_DDR2_cs_n,
//	M2_DDR2_dm,
//	M2_DDR2_dq,
//	M2_DDR2_dqs,
//	M2_DDR2_dqsn,
//	M2_DDR2_odt,
//	M2_DDR2_ras_n,
//	M2_DDR2_SA,
//	M2_DDR2_SCL,
//	M2_DDR2_SDA,
//	M2_DDR2_we_n,

	//////// GPIO_0 //////////
	GPIO0_D,

	//////// GPIO_1 //////////
	GPIO1_D,
	
	///////  EXT I/O /////////
	EXT_IO,
	
	//////////// HSMC_A //////////
	HSMA_CLKIN_n1,
	HSMA_CLKIN_n2,
	HSMA_CLKIN_p1,
	HSMA_CLKIN_p2,
	HSMA_CLKIN0,
	HSMA_CLKOUT_n2,
	HSMA_CLKOUT_p2,
	HSMA_D,
//	HSMA_GXB_RX_p,
//	HSMA_GXB_TX_p,
	HSMA_OUT_n1,
	HSMA_OUT_p1,
	HSMA_OUT0,
//	HSMA_REFCLK_p,
	HSMA_RX_n,
	HSMA_RX_p,
	HSMA_TX_n,
	HSMA_TX_p,
	
	//////////// HSMC_B //////////

   HSMB_CLKIN_n1,
	HSMB_CLKIN_n2,
	HSMB_CLKIN_p1,
	HSMB_CLKIN_p2,
	HSMB_CLKIN0,
	HSMB_CLKOUT_n2,
	HSMB_CLKOUT_p2,
	HSMB_D,
//	HSMB_GXB_RX_p,
//	HSMB_GXB_TX_p,
	HSMB_OUT_n1,
	HSMB_OUT_p1,
	HSMB_OUT0,
//	HSMB_REFCLK_p,
	HSMB_RX_n,
	HSMB_RX_p,
	HSMB_TX_n,
	HSMB_TX_p,

	//////////// HSMC I2C //////////
	HSMC_SCL,
	HSMC_SDA,

	//////////// 7-Segment Display //////////
	SEG0_D,
	SEG1_D,
	SEG0_DP,
	SEG1_DP,	
	
	//////////// Uart //////////
	
	UART_CTS,
	UART_RTS,
	UART_RXD,
	UART_TXD

	
);

//=======================================================
//  PARAMETER declarations
//=======================================================


//=======================================================
//  PORT declarations
//=======================================================

//////////// CLOCK //////////
input						OSC_50_BANK2;
input						OSC_50_BANK3;
input						OSC_50_BANK4;
input						OSC_50_BANK5;
input						OSC_50_BANK6;
input						OSC_50_BANK7;
input		          	PLL_CLKIN_p;
input						SMA_CLKIN_p;
//input						SMA_GXBCLK_p;  // xcvr 
input						GCLKIN;
output					GCLKOUT_FPGA;
output					SMA_CLKOUT_p;
//////// CPU RESET //////////
input		          	CPU_RESET_n;

//////// MAX I/O //////////
inout		     [3:0]	MAX_CONF_D;
output					MAX_I2C_SCLK;
inout						MAX_I2C_SDAT;

//////////// LED x 8 //////////
output		  [7:0]		LED;

//////////// BUTTON x 4 //////////
input		     [3:0]		BUTTON;

//////////// SWITCH x 8 //////////
input		     [7:0]		SW;

//////////// SLIDE SWITCH x 4 //////////
input		     [3:0]		SLIDE_SW;

//////////// Temperature //////////
output		        		TEMP_SMCLK;
inout		          		TEMP_SMDAT;
input		          		TEMP_INT_n;

//////////// Current //////////
output		        		CSENSE_ADC_FO;
inout		          		CSENSE_SCK;
output		        		CSENSE_SDI;
input		          		CSENSE_SDO;
output			[1:0]		CSENSE_CS_n;	

//////////// Fan //////////
output		        		FAN_CTRL;

//////////// EEPROM //////////
output		        		EEP_SCL;
inout		          		EEP_SDA;

//////////// SDCARD //////////
output		        		SD_CLK;
inout		          		SD_CMD;
inout		     [3:0]		SD_DAT;
input		          		SD_WP_n;

//////////// Ethernet x 4 //////////
//input		     [3:0] 		ETH_INT_n;
//output		     [3:0] 		ETH_MDC;
//inout		     [3:0] 		ETH_MDIO;
//output		          		ETH_RST_n;
//input		     [3:0]		ETH_RX_p;
//output		     [3:0]		ETH_TX_p;
//
////////////// PCIe x 8 //////////
//input		          		PCIE_PREST_n;
//input		          		PCIE_REFCLK_p;
//input		     [7:0]		PCIE_RX_p;
//input		          		PCIE_SMBCLK;
//inout		          		PCIE_SMBDAT;
//output		     [7:0]		PCIE_TX_p;
//output		          		PCIE_WAKE_n;

//////////// Flash and SRAM Address/Data Share Bus //////////
output		    [25:1]		FSM_A;
inout		       [15:0]		FSM_D;

//////////// Flash Control //////////
output		          		FLASH_ADV_n;
output		          		FLASH_CE_n;
output		          		FLASH_CLK;
output		          		FLASH_OE_n;
output		          		FLASH_RESET_n;
input		            		FLASH_RYBY_n;
output		          		FLASH_WE_n;

//////////// SSRAM Control //////////
output		          		SSRAM_ADV;
output		          		SSRAM_BWA_n;
output		          		SSRAM_BWB_n;
output		          		SSRAM_CE_n;
output		          		SSRAM_CKE_n;
output		          		SSRAM_CLK;
output		          		SSRAM_OE_n;
output		          		SSRAM_WE_n;

//////////// USB OTG //////////
output		    [17:1]		OTG_A;
output		          		OTG_CS_n;
inout		       [31:0]		OTG_D;
output		          		OTG_DC_DACK;
input		            		OTG_DC_DREQ;
input		            		OTG_DC_IRQ;
output		          		OTG_HC_DACK;
input		            		OTG_HC_DREQ;
input		          	   	OTG_HC_IRQ;
output		          		OTG_OE_n;
output		          		OTG_RESET_n;
output		          		OTG_WE_n;

//////////// SATA //////////
//input		          		SATA_REFCLK_p;
//input			[1:0]  		SATA_HOST_RX_p;
//output			[1:0]		   SATA_HOST_TX_p;
//input			[1:0]  		SATA_DEVICE_RX_p;
//output			[1:0]		   SATA_DEVICE_TX_p;


//////////// DDR2 SODIMM //////////
//output		    [15:0]		M1_DDR2_addr;
//output		     [2:0]		M1_DDR2_ba;
//output		          		M1_DDR2_cas_n;
//output		     [1:0]		M1_DDR2_cke;
//inout		     [1:0]		M1_DDR2_clk;
//inout		     [1:0]		M1_DDR2_clk_n;
//output		     [1:0]		M1_DDR2_cs_n;
//output		     [7:0]		M1_DDR2_dm;
//inout		    [63:0]		M1_DDR2_dq;
//inout		     [7:0]		M1_DDR2_dqs;
//inout		     [7:0]		M1_DDR2_dqsn;
//output		     [1:0]		M1_DDR2_odt;
//output		          		M1_DDR2_ras_n;
//output		     [1:0]		M1_DDR2_SA;
//output		          		M1_DDR2_SCL;
//inout		          		M1_DDR2_SDA;
//output		          		M1_DDR2_we_n;
//
////////////// DDR2 SODIMM //////////
//output		    [15:0]		M2_DDR2_addr;
//output		     [2:0]		M2_DDR2_ba;
//output		          		M2_DDR2_cas_n;
//output		     [1:0]		M2_DDR2_cke;
//inout		     [1:0]		M2_DDR2_clk;
//inout		     [1:0]		M2_DDR2_clk_n;
//output		     [1:0]		M2_DDR2_cs_n;
//output		     [7:0]		M2_DDR2_dm;
//inout		    [63:0]		M2_DDR2_dq;
//inout		     [7:0]		M2_DDR2_dqs;
//inout		     [7:0]		M2_DDR2_dqsn;
//output		     [1:0]		M2_DDR2_odt;
//output		          		M2_DDR2_ras_n;
//output		     [1:0]		M2_DDR2_SA;
//output		          		M2_DDR2_SCL;
//inout		          		M2_DDR2_SDA;
//output		          		M2_DDR2_we_n;

//////////// GPIO_0 //////////
inout		    [35:0]		GPIO0_D;

//////////// GPIO_1 //////////
inout		    [35:0]		GPIO1_D;

///////////  EXT_IO /////////
inout						   EXT_IO;

//////////// HSMC_A //////////
input		     		      HSMA_CLKIN_n1;
input		     		      HSMA_CLKIN_n2;
input		     		      HSMA_CLKIN_p1;
input		     		      HSMA_CLKIN_p2;
input						   HSMA_CLKIN0;
output						HSMA_CLKOUT_n2;
output						HSMA_CLKOUT_p2;
inout		    	[3:0]		HSMA_D;
//input			[3:0]		HSMA_GXB_RX_p;
//output			[3:0]		HSMA_GXB_TX_p;
inout			   			HSMA_OUT_n1;
inout				   		HSMA_OUT_p1;
inout					   	HSMA_OUT0;
//input						HSMA_REFCLK_p;
inout			[16:0]		HSMA_RX_n;
inout			[16:0]		HSMA_RX_p;
inout			[16:0]		HSMA_TX_n;
inout			[16:0]		HSMA_TX_p;
//////////// HSMC_B //////////
input		      		   HSMB_CLKIN_n1;
input		     		      HSMB_CLKIN_n2;
input		     		      HSMB_CLKIN_p1;
input		     		      HSMB_CLKIN_p2;
input					   	HSMB_CLKIN0;
output						HSMB_CLKOUT_n2;
output						HSMB_CLKOUT_p2;
inout			   [3:0]		HSMB_D;
//input			[7:0]		HSMB_GXB_RX_p;
//output			[7:0]		HSMB_GXB_TX_p;
inout		   				HSMB_OUT_n1;
inout			   			HSMB_OUT_p1;
inout				   		HSMB_OUT0;
//input						HSMB_REFCLK_p;
inout			[16:0]		HSMB_RX_n;
inout			[16:0]		HSMB_RX_p;
inout			[16:0]		HSMB_TX_n;
inout			[16:0]		HSMB_TX_p;

//////////// HSMC I2C //////////
output						HSMC_SCL;
inout				   		HSMC_SDA;

//////////// 7-Segment Display //////////
output			[6:0]		SEG0_D;
output			[6:0]		SEG1_D;
output						SEG0_DP;
output						SEG1_DP;

//////////// Uart //////////
output						UART_CTS;
input					   	UART_RTS;
input						   UART_RXD;
output						UART_TXD;

//=======================================================
//  REG/WIRE declarations
//=======================================================




//=======================================================
//  Structural coding
//=======================================================





endmodule
