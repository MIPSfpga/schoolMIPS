/*
 * schoolMIPS - small MIPS CPU for "Young Russian Chip Architects" 
 *              summer school ( yrca@googlegroups.com )
 *
 * the pipeline version of Sarah L. Harris MIPS CPU 
 * 
 * Copyright(c) 2017 Stanislav Zhelnio 
 */

 `include "sm_cpu.vh"

module sm_cpu
(
    input           clk,        // clock
    input           rst_n,      // reset
    input   [ 4:0]  regAddr,    // debug access reg address
    output  [31:0]  regData,    // debug access reg data
    output  [31:0]  imAddr,     // instruction memory address
    input   [31:0]  imData,     // instruction memory data
    output  [31:0]  dmAddr,     // data memory address
    output          dmWe,       // data memory write enable
    output  [31:0]  dmWData,    // data memory write data
    input   [31:0]  dmRData     // data memory read data
);
    // **********************************************************
    // F - Instruction Fetch
    // **********************************************************

    //control wires
    wire cw_pcSrc_F;

    //program counter
    wire [31:0] pc_F;
    wire [31:0] pcBranch_M;
    wire [31:0] pcNext_F  = pc_F + 1;
    wire [31:0] pcNew_F  = ~cw_pcSrc_F ? pcNext_F : pcBranch_M;

    sm_register r_pc_f(clk ,rst_n, pcNew_F, pc_F);

    //program memory access
    assign imAddr = pc_F;
    wire [31:0] instr_F = imData;

    //stage border
    wire [31:0] pcNext_D
    wire [31:0] instr_D
    sm_register r_pcNext_D(clk ,rst_n, pcNext_F, pcNext_D);
    sm_register r_instr_D (clk ,rst_n, instr_F, instr_D);

    // **********************************************************
    // D - Instruction Decode & Register
    // **********************************************************

    //debug register access
    wire [31:0] regData0_D;
    assign regData = (regAddr != 0) ? regData0_D : pc_F;

    //control wires
    wire cw_regWrite_D;

    //register file
    wire [ 4:0] writeReg_W;

    wire [31:0] regData1_D;
    wire [31:0] regData2_D;
    wire [31:0] writeData_W;

    wire [ 4:0] instrRs_D  = instr_D[25:21];
    wire [ 4:0] instrRt_D  = instr_D[20:16];
    wire [ 4:0] instrRd_D  = instr_D[15:11];
    wire [15:0] instrImm_D = instr_D[15:0 ];
    wire [ 4:0] instrSa_D  = instr_D[10:6 ];

    sm_register_file rf
    (
        .clk        ( ~clk          ),
        .a0         ( regAddr       ),
        .a1         ( instrRs_D     ),
        .a2         ( instrRt_D     ),
        .a3         ( writeReg_W    ),
        .rd0        ( regData0_D    ),
        .rd1        ( regData1_D    ),
        .rd2        ( regData2_D    ),
        .wd3        ( writeData_W   ),
        .we3        ( cw_regWrite_D )
    );

    //sign extension
    wire [31:0] signImm_D = { {16 { instrImm_D[15] }}, instrImm_D };

    //stage border
    wire [31:0] pcNext_E;
    wire [31:0] regData1_E;
    wire [31:0] regData2_E;
    wire [31:0] signImm_E;
    wire [ 4:0] instrRt_E;
    wire [ 4:0] instrRd_E;
    wire [ 4:0] instrSa_E;
    sm_register r_pcNext_E  (clk ,rst_n, pcNext_D, pcNext_E);
    sm_register r_regData1_E(clk ,rst_n, regData1_D, regData1_E);
    sm_register r_regData2_E(clk ,rst_n, regData2_D, regData2_E);
    sm_register r_signImm_E (clk ,rst_n, signImm_D,  signImm_E);
    sm_register #(.WIDTH(5)) r_instrRt_E (clk ,rst_n, instrRt_D,  instrRt_E);
    sm_register #(.WIDTH(5)) r_instrRd_E (clk ,rst_n, instrRd_D,  instrRd_E);
    sm_register #(.WIDTH(5)) r_signImm_E (clk ,rst_n, instrSa_D,  instrSa_E);

    // **********************************************************
    // E - Execution
    // **********************************************************

    //control wires
    wire cw_aluSrc_E;
    wire cw_aluCtrl_E;
    wire cw_regDst_E;

    //alu
    wire        aluZero_E;
    wire [31:0] aluResult_E;
    wire [31:0] aluSrcB_E = cw_aluSrc_E ? signImm_E : regData2_E;

    sm_alu alu
    (
        .srcA       ( regData1_E   ),
        .srcB       ( aluSrcB_E    ),
        .oper       ( cw_aluCtrl_E ),
        .shift      ( signImm_E    ),
        .zero       ( aluZero_E    ),
        .result     ( aluResult_E  ) 
    );

    //data to write from RF to Mem
    wire [31:0] writeData_E = regData2_E;

    //reg to write
    wire [ 4:0] writeReg_E = cw_regDst_E ? instrRd_E : instrRt_E;

    //branch address
    wire [31:0] pcBranch_E = pcNext_E + signImm_E;

    //stage border
    wire [31:0] aluResult_M;
    wire [31:0] writeData_M;
    wire [ 4:0] writeReg_M
    wire        aluZero_M;  //TODO!

    sm_register r_pcBranch_M  (clk ,rst_n, pcBranch_E, pcBranch_M);
    sm_register r_aluResult_M (clk ,rst_n, aluResult_E, aluResult_M);
    sm_register r_writeData_M (clk ,rst_n, writeData_E, writeData_M);
    sm_register #(.WIDTH(5)) r_writeReg_M (clk ,rst_n, writeReg_E,  writeReg_M);
    sm_register #(.WIDTH(1)) r_aluZero_M  (clk ,rst_n, aluZero_E,  aluZero_M);

    // **********************************************************
    // M - Memory
    // **********************************************************

    //control wires
    wire cw_memWrite_M;

    // memory
    wire [31:0] readData_M = dmRData;
    assign dmWe    = cw_memWrite_M;
    assign dmAddr  = aluResult_M;
    assign dmWData = writeData_M;

    //stage border
    wire [31:0] aluResult_W;
    wire [31:0] readData_W;
    wire [ 4:0] writeReg_W;

    sm_register r_aluResult_W (clk ,rst_n, aluResult_M, aluResult_W);
    sm_register r_readData_W  (clk ,rst_n, readData_M, readData_W);
    sm_register #(.WIDTH(5)) r_writeReg_M (clk ,rst_n, writeReg_M,  writeReg_W);

    // **********************************************************
    // W - Writeback
    // **********************************************************

    //control wires
    wire cw_memToReg_W;

    //data to write from Mem to RF
    assign writeData_W = cw_memToReg_W ? readData_W : aluResult_W;

    // **********************************************************
    // Control Unit
    // **********************************************************

    


    // **********************************************************
    // Hazard Unit
    // **********************************************************



endmodule