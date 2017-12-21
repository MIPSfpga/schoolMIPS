/*
 * schoolMIPS - small MIPS CPU for "Young Russian Chip Architects" 
 *              summer school ( yrca@googlegroups.com )
 *
 * the pipeline version of Sarah L. Harris MIPS CPU 
 * 
 * Copyright(c) 2017 Stanislav Zhelnio
 */

 `include "sm_cpu.vh"
 `include "sm_pcpu.vh"



module sm_pcpu
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

    //stage data border
    wire [31:0] pcNext_D;
    wire [31:0] instr_D;
    sm_register r_pcNext_D(clk ,rst_n, pcNext_F, pcNext_D);
    sm_register r_instr_D (clk ,rst_n, instr_F, instr_D);

    // **********************************************************
    // D - Instruction Decode & Register
    // **********************************************************

    //debug register access
    wire [31:0] regData0_D;
    assign regData = (regAddr != 0) ? regData0_D : pc_F;

    //control wires
    wire cw_regWrite_W;

    // instaturction fields
    wire [ 5:0] instrOp_D  = instr_D[31:26];
    wire [ 5:0] instrFn_D  = instr_D[ 5:0 ];
    wire [ 4:0] instrRs_D  = instr_D[25:21];
    wire [ 4:0] instrRt_D  = instr_D[20:16];
    wire [ 4:0] instrRd_D  = instr_D[15:11];
    wire [15:0] instrImm_D = instr_D[15:0 ];
    wire [ 4:0] instrSa_D  = instr_D[10:6 ];

    //register file
    wire [ 4:0] writeReg_W;
    wire [31:0] regData1_D;
    wire [31:0] regData2_D;
    wire [31:0] writeData_W;

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
        .we3        ( cw_regWrite_W )
    );

    //sign extension
    wire [31:0] signImm_D = { {16 { instrImm_D[15] }}, instrImm_D };

    //control unit
    wire        cw_regDst_D;
    wire        cw_regWrite_D;
    wire        cw_aluSrc_D;
    wire [ 2:0] cw_aluCtrl_D;
    wire        cw_memWrite_D;
    wire        cw_memToReg_D;
    wire        cw_branch_D;
    wire        cw_condZero_D;

    wire        aluZero;    //TODO! not used now
    wire        pcSrc;      //TODO! not used now

    sm_control sm_control
    (
        .cmdOper    ( instrOp_D       ),
        .cmdFunk    ( instrFn_D       ),
        .aluZero    ( aluZero         ), //TODO!
        .pcSrc      ( pcSrc           ), //TODO!
        .regDst     ( cw_regDst_D     ),
        .regWrite   ( cw_regWrite_D   ),
        .aluSrc     ( cw_aluSrc_D     ),
        .aluControl ( cw_aluCtrl_D    ),
        .memWrite   ( cw_memWrite_D   ),
        .memToReg   ( cw_memToReg_D   ),
        .branch     ( cw_branch_D     ),
        .condZero   ( cw_condZero_D   )
    );

    //stage data border
    wire [31:0] pcNext_E;
    wire [31:0] regData1_E;
    wire [31:0] regData2_E;
    wire [31:0] signImm_E;
    wire [ 4:0] instrRs_E;
    wire [ 4:0] instrRt_E;
    wire [ 4:0] instrRd_E;
    wire [ 4:0] instrSa_E;
    sm_register r_pcNext_E  (clk ,rst_n, pcNext_D, pcNext_E);
    sm_register r_regData1_E(clk ,rst_n, regData1_D, regData1_E);
    sm_register r_regData2_E(clk ,rst_n, regData2_D, regData2_E);
    sm_register r_signImm_E (clk ,rst_n, signImm_D,  signImm_E);
    sm_register #(.WIDTH(5)) r_instrRs_E (clk ,rst_n, instrRs_D,  instrRs_E);
    sm_register #(.WIDTH(5)) r_instrRt_E (clk ,rst_n, instrRt_D,  instrRt_E);
    sm_register #(.WIDTH(5)) r_instrRd_E (clk ,rst_n, instrRd_D,  instrRd_E);
    sm_register #(.WIDTH(5)) r_instrSa_E (clk ,rst_n, instrSa_D,  instrSa_E);

    //stage control border
    wire        cw_regWrite_E;
    wire        cw_regDst_E;
    wire        cw_aluSrc_E;
    wire [2:0]  cw_aluCtrl_E;
    wire        cw_memWrite_E;
    wire        cw_memToReg_E;
    wire        cw_branch_E;
    wire        cw_condZero_E;
    sm_register #(.WIDTH(1)) r_cw_regWrite_E (clk ,rst_n, cw_regWrite_D, cw_regWrite_E);
    sm_register #(.WIDTH(1)) r_cw_regDst_E   (clk ,rst_n, cw_regDst_D,   cw_regDst_E);
    sm_register #(.WIDTH(1)) r_cw_aluSrc_E   (clk ,rst_n, cw_aluSrc_D,   cw_aluSrc_E);
    sm_register #(.WIDTH(3)) r_cw_aluCtrl_E  (clk ,rst_n, cw_aluCtrl_D,  cw_aluCtrl_E);
    sm_register #(.WIDTH(1)) r_cw_memWrite_E (clk ,rst_n, cw_memWrite_D, cw_memWrite_E);
    sm_register #(.WIDTH(1)) r_cw_memToReg_E (clk ,rst_n, cw_memToReg_D, cw_memToReg_E);
    sm_register #(.WIDTH(1)) r_cw_branch_E   (clk ,rst_n, cw_branch_D,   cw_branch_E);
    sm_register #(.WIDTH(1)) r_cw_condZero_E (clk ,rst_n, cw_condZero_D, cw_condZero_E);

    // **********************************************************
    // E - Execution
    // **********************************************************

    wire [31:0] aluResult_M;

    //hazard wires
    wire [ 1:0] hz_forwardA_E;  //forward srcA
    wire [ 1:0] hz_forwardB_E;  //forward srcB

    wire [31:0] aluSrcA_E = ( hz_forwardA_E == `HZ_FW_WE ) ? writeData_W : (
                            ( hz_forwardA_E == `HZ_FW_ME ) ? aluResult_M : regData1_E );

    wire [31:0] aluSrcB_E =   cw_aluSrc_E                  ? signImm_E   : (
                            ( hz_forwardB_E == `HZ_FW_WE ) ? writeData_W : (
                            ( hz_forwardB_E == `HZ_FW_ME ) ? aluResult_M : regData2_E ));

    //alu
    wire        aluZero_E;
    wire [31:0] aluResult_E;

    sm_alu alu
    (
        .srcA       ( aluSrcA_E    ),
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

    //stage data border
    wire [31:0] writeData_M;
    wire [ 4:0] writeReg_M;
    wire        aluZero_M;  //TODO!

    sm_register r_pcBranch_M  (clk ,rst_n, pcBranch_E, pcBranch_M);
    sm_register r_aluResult_M (clk ,rst_n, aluResult_E, aluResult_M);
    sm_register r_writeData_M (clk ,rst_n, writeData_E, writeData_M);
    sm_register #(.WIDTH(5)) r_writeReg_M (clk ,rst_n, writeReg_E,  writeReg_M);
    sm_register #(.WIDTH(1)) r_aluZero_M  (clk ,rst_n, aluZero_E,  aluZero_M);

    //stage control border
    wire        cw_regWrite_M;
    wire        cw_memWrite_M;
    wire        cw_memToReg_M;
    wire        cw_branch_M;
    wire        cw_condZero_M;
    sm_register #(.WIDTH(1)) r_cw_regWrite_M (clk ,rst_n, cw_regWrite_E, cw_regWrite_M);
    sm_register #(.WIDTH(1)) r_cw_memWrite_M (clk ,rst_n, cw_memWrite_E, cw_memWrite_M);
    sm_register #(.WIDTH(1)) r_cw_memToReg_M (clk ,rst_n, cw_memToReg_E, cw_memToReg_M);
    sm_register #(.WIDTH(1)) r_cw_branch_M   (clk ,rst_n, cw_branch_E,   cw_branch_M);
    sm_register #(.WIDTH(1)) r_cw_condZero_M (clk ,rst_n, cw_condZero_E, cw_condZero_M);

    // **********************************************************
    // M - Memory
    // **********************************************************

    // memory
    wire [31:0] readData_M = dmRData;
    assign dmWe    = cw_memWrite_M;
    assign dmAddr  = aluResult_M;
    assign dmWData = writeData_M;

    //stage data border
    wire [31:0] aluResult_W;
    wire [31:0] readData_W;

    sm_register r_aluResult_W (clk ,rst_n, aluResult_M, aluResult_W);
    sm_register r_readData_W  (clk ,rst_n, readData_M, readData_W);
    sm_register #(.WIDTH(5)) r_writeReg_W (clk ,rst_n, writeReg_M,  writeReg_W);

    //stage control border
    wire        cw_memToReg_W;
    sm_register #(.WIDTH(1)) r_cw_memToReg_W (clk ,rst_n, cw_memToReg_M, cw_memToReg_W);
    sm_register #(.WIDTH(1)) r_cw_regWrite_W (clk ,rst_n, cw_regWrite_M, cw_regWrite_W);

    //branch decision (TODO: refactoring)
    assign cw_pcSrc_F = cw_branch_M & (aluZero_M == cw_condZero_M);

    // **********************************************************
    // W - Writeback
    // **********************************************************

    //data to write from Mem to RF
    assign writeData_W = cw_memToReg_W ? readData_W : aluResult_W;

    // **********************************************************
    // Hazard Unit
    // **********************************************************

    sm_hazard_unit sm_hazard_unit
    (
        .instrRs_E      ( instrRs_E     ),
        .instrRt_E      ( instrRt_E     ),
        .writeReg_M     ( writeReg_M    ),
        .writeReg_W     ( writeReg_W    ),
        .cw_regWrite_M  ( cw_regWrite_M ),
        .cw_regWrite_W  ( cw_regWrite_W ),
        .hz_forwardA_E  ( hz_forwardA_E ),
        .hz_forwardB_E  ( hz_forwardB_E )
    );

endmodule


module sm_hazard_unit
(
    input   [ 4:0]  instrRs_E,
    input   [ 4:0]  instrRt_E,
    input   [ 4:0]  writeReg_M,
    input   [ 4:0]  writeReg_W,
    input           cw_regWrite_M,
    input           cw_regWrite_W,
    output  [ 1:0]  hz_forwardA_E,  //forward srcA
    output  [ 1:0]  hz_forwardB_E   //forward srcB
);
    //data forwarding
    assign hz_forwardA_E =  ( instrRs_E == 5'b0                        ) ? `HZ_FW_NONE : (
                            ( instrRs_E == writeReg_M && cw_regWrite_M ) ? `HZ_FW_ME   : (
                            ( instrRs_E == writeReg_W && cw_regWrite_W ) ? `HZ_FW_WE   : `HZ_FW_NONE ));

    assign hz_forwardB_E =  ( instrRt_E == 5'b0                        ) ? `HZ_FW_NONE : (
                            ( instrRt_E == writeReg_M && cw_regWrite_M ) ? `HZ_FW_ME   : (
                            ( instrRt_E == writeReg_W && cw_regWrite_W ) ? `HZ_FW_WE   : `HZ_FW_NONE ));



endmodule
