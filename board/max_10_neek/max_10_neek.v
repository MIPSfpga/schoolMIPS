
`define ENABLE_ADC
`define ENABLE_AUDIO
`define ENABLE_CAMERA
`define ENABLE_DAC
// `define ENABLE_DDR3
`define ENABLE_FLASH
`define ENABLE_GPIO
`define ENABLE_GSENSOR
`define ENABLE_HDMI
`define ENABLE_HEX0
`define ENABLE_HEX1
`define ENABLE_KEY
`define ENABLE_LEDR
`define ENABLE_LSENSOR
`define ENABLE_MAX10
`define ENABLE_MIPI
`define ENABLE_MTL2
`define ENABLE_NET
`define ENABLE_PM
`define ENABLE_PS2
`define ENABLE_RH
`define ENABLE_SD
`define ENABLE_SW
`define ENABLE_UART

module golden_top(

`ifdef ENABLE_ADC
      ///////// ADC 3.3 V /////////
      input              ADC_CLK_10,
`endif	  
        
`ifdef ENABLE_AUDIO
      ///////// AUDIO 2.5 V /////////
      inout              AUDIO_BCLK,
      output             AUDIO_DIN_MFP1,
      input              AUDIO_DOUT_MFP2,
      inout              AUDIO_GPIO_MFP5,
      output             AUDIO_MCLK,
      input              AUDIO_MISO_MFP4,
      inout              AUDIO_RESET_n,
      output             AUDIO_SCLK_MFP3,
      output             AUDIO_SCL_SS_n,
      inout              AUDIO_SDA_MOSI,
      output             AUDIO_SPI_SELECT,
      inout              AUDIO_WCLK,
`endif
        
`ifdef ENABLE_CAMERA	
      // 2.5 V
      output             CAMERA_I2C_SCL,
      inout              CAMERA_I2C_SDA,
      // 3.3 V LVTTL
      output             CAMERA_PWDN_n,
`endif
        
`ifdef ENABLE_DAC	  
      ///////// DAC 3.3 V LVTTL /////////
      inout              DAC_DATA,
      output             DAC_SCLK,
      output             DAC_SYNC_n,
`endif
        
`ifdef ENABLE_DDR3
      // "SSTL-15 CLASS I"
      output      [14:0] DDR3_A,
      output      [2:0]  DDR3_BA,
      output             DDR3_CKE, 
      output             DDR3_CAS_n,
      output             DDR3_CS_n,
      output      [2:0]  DDR3_DM,
      inout       [23:0] DDR3_DQ,
      output             DDR3_ODT,
      output             DDR3_RAS_n,
      output             DDR3_RESET_n,
      output             DDR3_WE_n,
      // "DIFFERENTIAL 1.5-V SSTL CLASS I"
      inout              DDR3_CK_n,
      inout              DDR3_CK_p,
      inout       [2:0]  DDR3_DQS_n,
      inout       [2:0]  DDR3_DQS_p,
`endif 

`ifdef ENABLE_FLASH
      // "3.3-V LVTTL"
      inout       [3:0]  FLASH_DATA,
      output             FLASH_DCLK,
      output             FLASH_NCSO,
      output             FLASH_RESET_n,
`endif
       
      `ifdef ENABLE_GPIO
      // "3.3-V LVTTL"
      inout       [7:0]  GPIO,	 
      `endif	
       
`ifdef ENABLE_GSENSOR  
      // 2.5 V
      output             GSENSOR_CS_n,
      input       [2:1]  GSENSOR_INT,
      inout              GSENSOR_SCLK,
      inout              GSENSOR_SDI,
      inout              GSENSOR_SDO,
`endif  
        
`ifdef ENABLE_HDMI  
      // "3.3-V LVTTL"
      input              HDMI_AP,
      inout              HDMI_I2C_SCL,
      inout              HDMI_I2C_SDA,
      inout              HDMI_LRCLK,
      inout              HDMI_MCLK,
      input              HDMI_RX_CLK,
      input       [23:0] HDMI_RX_D,
      input              HDMI_RX_DE,
      inout              HDMI_RX_HS,
      input              HDMI_RX_INT1,
      inout              HDMI_RX_RESET_n,
      input              HDMI_RX_VS,
      inout              HDMI_SCLK,
`endif
        
`ifdef ENABLE_HEX0	  
      // "3.3-V LVTTL"
      output      [6:0]  HEX0,
`endif

`ifdef ENABLE_HEX1
      // "3.3-V LVTTL"
      output      [6:0]  HEX1,
`endif
        
`ifdef ENABLE_KEY
      // "1.5 V SCHMITT TRIGGER" 
      input       [4:0]  KEY,
`endif
        
`ifdef ENABLE_LEDR	  
      // "3.3-V LVTTL"
      output      [9:0]  LEDR,
`endif
        
`ifdef ENABLE_LSENSOR	  
      // "3.3-V LVTTL"
      inout              LSENSOR_INT,
      output             LSENSOR_SCL,
      inout              LSENSOR_SDA,
`endif
        
`ifdef ENABLE_MAX10	 
      //  "3.3-V LVTTL"
      input              MAX10_CLK1_50,
      input              MAX10_CLK2_50,
      input              MAX10_CLK3_50,
`endif
        
`ifdef ENABLE_MIPI
      // "3.3-V LVTTL"
      output             MIPI_CS_n,
      output             MIPI_I2C_SCL,
      inout              MIPI_I2C_SDA,
      input              MIPI_PIXEL_CLK,
      input       [23:0] MIPI_PIXEL_D,
      input              MIPI_PIXEL_HS,
      input              MIPI_PIXEL_VS,
      output             MIPI_REFCLK,
      output             MIPI_RESET_n,
`endif

`ifdef ENABLE_MTL2	  
      // "3.3-V LVTTL"
      output      [7:0]  MTL2_B,
      inout              MTL2_BL_ON_n,
      output             MTL2_DCLK,
      output      [7:0]  MTL2_G,
      output             MTL2_HSD,
      output             MTL2_I2C_SCL,
      inout              MTL2_I2C_SDA,
      input              MTL2_INT,
      output      [7:0]  MTL2_R,
      output             MTL2_VSD,
`endif
        
`ifdef ENABLE_NET
      // 2.5 V 
      output             NET_GTX_CLK,
      input              NET_INT_n,
      input              NET_LINK100,
      output             NET_MDC,
      inout              NET_MDIO,
      output             NET_RST_N,
      input              NET_RX_CLK,
      input              NET_RX_COL,
      input              NET_RX_CRS,
      input       [3:0]  NET_RX_D,
      input              NET_RX_DV,
      input              NET_RX_ER,
      input              NET_TX_CLK,
      output      [3:0]  NET_TX_D,
      output             NET_TX_EN,
      output             NET_TX_ER,
`endif
        
`ifdef ENABLE_PM	  
      //  "3.3-V LVTTL"
      output             PM_I2C_SCL,
      inout              PM_I2C_SDA,
`endif

`ifdef ENABLE_PS2
      // "3.3-V LVTTL"
      inout              PS2_CLK,
      inout              PS2_CLK2,
      inout              PS2_DAT,
      inout              PS2_DAT2,
`endif

`ifdef ENABLE_RH
      // "3.3-V LVTTL"
      input              RH_TEMP_DRDY_n,
      output             RH_TEMP_I2C_SCL,
      inout              RH_TEMP_I2C_SDA,
`endif
        
`ifdef ENABLE_SD
      // 2.5 V  
      output             SD_CLK,
      inout              SD_CMD,
      inout       [3:0]  SD_DATA,
`endif

`ifdef ENABLE_SW
      // 1.5 V 
      input       [9:0]  SW,
`endif
        
`ifdef ENABLE_UART
      // 2.5 V 
      output             UART_RESET_n,
      input              UART_RX,
      output             UART_TX,
`endif

      ///////// FPGA /////////
      input              FPGA_RESET_n

);

  // wires & inputs
    wire          clk;
    wire          clkIn     =  MAX10_CLK1_50;
    wire          rst_n     =  KEY[0];
    wire          clkEnable =  SW [9] | ~KEY[1];
    wire [  3:0 ] devide    =  SW [8:5];
    wire [  4:0 ] regAddr   =  SW [4:0];
    wire [ 31:0 ] regData;

    //cores
    sm_clk_divider sm_clk_divider
    (
        .clkIn      ( clkIn     ),
        .rst_n      ( rst_n     ),
        .devide     ( devide    ),
        .enable     ( clkEnable ),
        .clkOut     ( clk       )
    );

    sm_cpu sm_cpu
    (
        .clk        ( clk       ),
        .rst_n      ( rst_n     ),
        .regAddr    ( regAddr   ),
        .regData    ( regData   )
    );

    //outputs
    assign LEDR[0]   = clk;
    assign LEDR[9:1] = regData[8:0];

    wire [ 31:0 ] h7segment = regData;

    sm_hex_display digit_1 ( h7segment [ 7: 4] , HEX1 [6:0] );
    sm_hex_display digit_0 ( h7segment [ 3: 0] , HEX0 [6:0] );

endmodule
