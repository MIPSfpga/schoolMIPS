/*
 * schoolMIPS - small MIPS CPU for "Young Russian Chip Architects" 
 *              summer school ( yrca@googlegroups.com )
 *
 * originally based on Sarah L. Harris MIPS CPU 
 * 
 * Copyright(c) 2017 Stanislav Zhelnio 
 */ 

`define CP0_REG_NUM_STATUS  5'd12
`define CP0_REG_SEL_STATUS  3'd0
`define CP0_REG_NUM_CAUSE   5'd13
`define CP0_REG_SEL_CAUSE   3'd0
`define CP0_REG_NUM_EPC     5'd14
`define CP0_REG_SEL_EPC     3'd0

module sm_cp0
(
    input         clk,
    input         rst_n,

    input  [31:0] cp0_EPC_new,      // next PC addr
    output [31:0] cp0_EPC,          // the address at which processing resumes
                                    // after an exception has been serviced
    output [31:0] cp0_ExcHandler,   // Exception Handler Addr
    output        cp0_ExcRequest,   // request for Exception

    input  [ 4:0] cp0_regNum,       // cp0 register access num
    input  [ 2:0] cp0_regSel,       // cp0 register access sel
    output [31:0] cp0_regRD,        // cp0 register access Read Data
    input  [31:0] cp0_regWD,        // cp0 register access Write Data
    input  [31:0] cp0_regWE,        // cp0 register access Write Enable

    input         cp0_ExcIP2,       // Hardware Interrupt 0
    input         cp0_ExcRI,        // Reserved Instruction exception
    input         cp0_ExcOv         // Arithmetic Overflow exception
);
    assign cp0_ExcHandler = `SM_CONFIG_EXCEPTION_HANDLER_ADDR;

    // ####################################################################
    // Status register

    // Register Select
    wire        cp0_Status_select =  (cp0_regNum == `CP0_REG_NUM_STATUS)
                                  && (cp0_regSel == `CP0_REG_SEL_STATUS);

    // Register Write Enable
    wire        cp0_Status_we = (cp0_regWE && cp0_Status_select);

    // Interrupt Enable
    wire        cp0_StatusIE;
    wire        cp0_StatusIE_new = cp0_regWD [0];
    sm_register_we r_cp0_StatusIE(clk, rst_n, cp0_Status_we, cp0_StatusIE_new, cp0_StatusIE);
    
    // Interrupt Mask
    wire [ 7:0] cp0_StatusIM;
    wire [ 7:0] cp0_StatusIM_new = cp0_regWD [15:8];
    sm_register_we #(8) r_cp0_StatusIM(clk, rst_n, cp0_Status_we, cp0_StatusIM_new, cp0_StatusIM);

    // Exception Level
    wire        cp0_StatusEXL;
    wire        cp0_StatusEXL_new;
    sm_register_we r_cp0_StatusEXL(clk, rst_n, cp0_Status_we, cp0_StatusIE_new, cp0_StatusIE);

    // Status register read access
    wire [31:0] cp0_Status = { 16'b0, cp0_StatusIM, 6'b0, cp0_StatusEXL, cp0_StatusIE };

    // ####################################################################
    // Cause register

    // Register Select
    wire        cp0_Cause_select =  (cp0_regNum == `CP0_REG_NUM_CAUSE)
                                 && (cp0_regSel == `CP0_REG_SEL_CAUSE);

    // Interrupt is pending
    wire [ 7:0] cp0_CauseIP;
    wire [ 7:0] cp0_CauseIP_next;
    sm_register_we #(32) r_cp0_CauseIP(clk, rst_n, cp0_Status_we, cp0_CauseIP_next, cp0_CauseIP);

    // Exception Code
    wire [ 4:0] cp0_CauseExcCode;

    // Cause register read access
    wire [31:0] cp0_Cause = { 16'b0, cp0_CauseIP, 1'b0, cp0_CauseExcCode, 2'b0 };

    // ####################################################################
    // Exception Program Counter (EPC) Register

    // Register Select
    wire        cp0_EPC_select =    (cp0_regNum == `CP0_REG_NUM_EPC)
                                 && (cp0_regSel == `CP0_REG_SEL_EPC);

    wire        cp0_EPC_we;
    sm_register_we #(32) r_cp0_epc(clk, rst_n, cp0_EPC_we, cp0_EPC_new, cp0_EPC);

    // ####################################################################
    // Registers read access

    assign cp0_regRD =  cp0_Status_select ? cp0_Status : (
                        cp0_Cause_select  ? cp0_Cause  : (
                        cp0_EPC_select    ? cp0_EPC    : 32'b0 ));

endmodule
