/*
 * schoolMIPS - small MIPS CPU for "Young Russian Chip Architects" 
 *              summer school ( yrca@googlegroups.com )
 *
 * the pipeline version of Sarah L. Harris MIPS CPU 
 * 
 * Copyright(c) 2017-2018 Stanislav Zhelnio
 *                        Anton Kulichkov
 *                        Dmitriy Vlasov
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
    output          dmValid,    // data memory read/write request
    input           dmReady,    // data memory read/write done
    input   [31:0]  dmRData     // data memory read data
);
    // **********************************************************
    // F - Instruction Fetch
    // **********************************************************

    //control wires
    wire cw_pcSrc_D;
    wire [ 1:0] cw_pcExc_D;

    //hazard wires
    wire hz_stall_n_F;
    wire hz_cancel_branch_F;
    wire hz_stall_n_D;
    wire hz_flush_n_D;   //flush D stage
    wire [1:0] hz_forwardEPC_F;

    //program counter
    wire [31:0] pc_F;
    wire [31:0] pcBranch_D;
    wire [31:0] pcNext_F  = pc_F + 4;
    wire [31:0] pcFlow_F  = cw_pcSrc_D & ~hz_cancel_branch_F ? pcBranch_D : pcNext_F;

    wire [31:0] cp0_ExcHandler_M;
    wire [31:0] cp0_EPC_M;
    wire [31:0] writeData_E;
    wire [31:0] writeData_M;

    wire [31:0] EPC_F     = ( hz_forwardEPC_F == `HZ_FW_EF ) ? writeData_E :
                            ( hz_forwardEPC_F == `HZ_FW_MF ) ? writeData_M :
                           /* hz_forwardEPC_F == `HZ_FW_NONE */ cp0_EPC_M;

    wire [31:0] pcNew_F   = cw_pcExc_D == `PC_EXC  ?  cp0_ExcHandler_M :
                            cw_pcExc_D == `PC_ERET ?  EPC_F            :
                         /* cw_pcExc_D == `PC_FLOW */ pcFlow_F;

    sm_register_we #(32) r_pc_f (clk ,rst_n, hz_stall_n_F, pcNew_F, pc_F);

    //program memory access
    assign imAddr = pc_F >> 2;  //schoolMIPS instruction memory is word addressable
    wire [31:0] instr_F = imData;

    //stage data border
    wire [31:0] pc_D;
    wire [31:0] pcNext_D;
    wire [31:0] instr_D;
    sm_register_wes #(32) r_pc_D (clk, rst_n, hz_flush_n_D, hz_stall_n_D, pc_F, pc_D);
    sm_register_wes #(32) r_pcNext_D (clk, rst_n, hz_flush_n_D, hz_stall_n_D, pcNext_F, pcNext_D);
    sm_register_wes #(32) r_instr_D  (clk, rst_n, hz_flush_n_D, hz_stall_n_D, instr_F, instr_D);

    // **********************************************************
    // D - Instruction Decode & Register
    // **********************************************************

    //debug register access
    wire [31:0] regData0_D;
    assign regData = (regAddr != 0) ? regData0_D : pc_F;

    //control wires
    wire cw_regWrite_W;
    wire cw_branch_D;

    //hazard wires
    wire hz_forwardA_D;  //forward srcA
    wire hz_forwardB_D;  //forward srcB
    wire hz_irq_disable_D;
    wire hz_flush_n_E;
    wire hz_stall_n_E;

    // instaturction fields
    wire [ 5:0] instrOp_D  = instr_D[31:26];
    wire [ 5:0] instrFn_D  = instr_D[ 5:0 ];
    wire [ 4:0] instrRs_D  = instr_D[25:21];
    wire [ 4:0] instrRt_D  = instr_D[20:16];
    wire [ 4:0] instrRd_D  = instr_D[15:11];
    wire [15:0] instrImm_D = instr_D[15:0 ];
    wire [ 4:0] instrSa_D  = instr_D[10:6 ];
    wire [ 2:0] instrSel_D = instr_D[ 2:0 ];

    //register file
    wire [ 4:0] writeReg_W;
    wire [31:0] regData1_D;
    wire [31:0] regData2_D;
    wire [31:0] writeData_W;

    sm_register_file rf
    (
        .clk        ( clk           ),
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

    //branch address
    assign pcBranch_D = pcNext_D + (signImm_D << 2);

    wire [31:0] aluResult_M;
    wire [31:0] regData1F_D = hz_forwardA_D ? aluResult_M : regData1_D;
    wire [31:0] regData2F_D = hz_forwardB_D ? aluResult_M : regData2_D;

    //early branch resolution
    wire        aluZero_D = ( regData1F_D == regData2F_D );

    //control unit
    wire        cw_regDst_D;
    wire        cw_regWrite_D;
    wire        cw_aluSrc_D;
    wire [ 2:0] cw_aluCtrl_D;
    wire        cw_memWrite_D;
    wire        cw_memToReg_D;
    wire        cw_memAccess_D;
    wire        cw_cpzToReg_D;
    wire        cw_cpzRegWrite_D;
    wire        cw_cpzExcEret_D;
    wire        excRiFound_D;

    //exceptions
    wire        cp0_ExcAsyncReq_M;
    wire        irqRequest_D  = cp0_ExcAsyncReq_M & ~hz_irq_disable_D;  
    wire        excSync_D     = excRiFound_D;
    wire        cw_epcSrc_D;
    wire [31:0] epcNext_D =  cw_epcSrc_D ? pc_D : pcFlow_F;

    sm_control sm_control
    (
        .cmdOper    ( instrOp_D       ),
        .cmdRegS    ( instrRs_D       ),
        .cmdFunk    ( instrFn_D       ),
        .aluZero    ( aluZero_D       ),
        .pcSrc      ( cw_pcSrc_D      ),
        .pcExc      ( cw_pcExc_D      ),
        .regDst     ( cw_regDst_D     ),
        .regWrite   ( cw_regWrite_D   ),
        .aluSrc     ( cw_aluSrc_D     ),
        .aluControl ( cw_aluCtrl_D    ),
        .memWrite   ( cw_memWrite_D   ),
        .memToReg   ( cw_memToReg_D   ),
        .memAccess  ( cw_memAccess_D  ),
        .branch     ( cw_branch_D     ),
        .cw_cpzToReg    ( cw_cpzToReg_D    ),
        .cw_cpzRegWrite ( cw_cpzRegWrite_D ),
        .cw_cpzExcEret  ( cw_cpzExcEret_D  ),
        .excAsync       ( irqRequest_D     ),
        .excSync        ( excSync_D        ),
        .cw_epcSrc      ( cw_epcSrc_D      ),
        .excRiFound     ( excRiFound_D     ) 
    );

    //stage data border
    wire [31:0] epcNext_E;
    wire [31:0] regData1_E;
    wire [31:0] regData2_E;
    wire [31:0] signImm_E;
    wire [ 4:0] instrRs_E;
    wire [ 4:0] instrRt_E;
    wire [ 4:0] instrRd_E;
    wire [ 4:0] instrSa_E;
    wire [ 2:0] instrSel_E;
    wire        excRiFound_E;
    wire        irqRequest_E;
    sm_register_wes #(32) r_epcNext_E    (clk, rst_n, hz_flush_n_E, hz_stall_n_E, epcNext_D,    epcNext_E);
    sm_register_wes #(32) r_regData1_E   (clk, rst_n, hz_flush_n_E, hz_stall_n_E, regData1_D,   regData1_E);
    sm_register_wes #(32) r_regData2_E   (clk, rst_n, hz_flush_n_E, hz_stall_n_E, regData2_D,   regData2_E);
    sm_register_wes #(32) r_signImm_E    (clk, rst_n, hz_flush_n_E, hz_stall_n_E, signImm_D,    signImm_E);
    sm_register_wes #( 5) r_instrRs_E    (clk, rst_n, hz_flush_n_E, hz_stall_n_E, instrRs_D,    instrRs_E);
    sm_register_wes #( 5) r_instrRt_E    (clk, rst_n, hz_flush_n_E, hz_stall_n_E, instrRt_D,    instrRt_E);
    sm_register_wes #( 5) r_instrRd_E    (clk, rst_n, hz_flush_n_E, hz_stall_n_E, instrRd_D,    instrRd_E);
    sm_register_wes #( 5) r_instrSa_E    (clk, rst_n, hz_flush_n_E, hz_stall_n_E, instrSa_D,    instrSa_E);
    sm_register_wes #( 3) r_instrSel_E   (clk, rst_n, hz_flush_n_E, hz_stall_n_E, instrSel_D,   instrSel_E);
    sm_register_wes       r_excRiFound_E (clk, rst_n, hz_flush_n_E, hz_stall_n_E, excRiFound_D, excRiFound_E);
    sm_register_wes       r_irqRequest_E (clk, rst_n, hz_flush_n_E, hz_stall_n_E, irqRequest_D, irqRequest_E);

    //stage control border
    wire        cw_regWrite_E;
    wire        cw_regDst_E;
    wire        cw_aluSrc_E;
    wire [2:0]  cw_aluCtrl_E;
    wire        cw_memWrite_E;
    wire        cw_memToReg_E;
    wire        cw_memAccess_E;
    wire        cw_cpzRegWrite_E;
    wire        cw_cpzExcEret_E;
    wire        cw_cpzToReg_E;
    sm_register_wes      r_cw_regWrite_E    (clk, rst_n, hz_flush_n_E, hz_stall_n_E, cw_regWrite_D, cw_regWrite_E);
    sm_register_wes      r_cw_regDst_E      (clk, rst_n, hz_flush_n_E, hz_stall_n_E, cw_regDst_D,   cw_regDst_E);
    sm_register_wes      r_cw_aluSrc_E      (clk, rst_n, hz_flush_n_E, hz_stall_n_E, cw_aluSrc_D,   cw_aluSrc_E);
    sm_register_wes #(3) r_cw_aluCtrl_E     (clk, rst_n, hz_flush_n_E, hz_stall_n_E, cw_aluCtrl_D,  cw_aluCtrl_E);
    sm_register_wes      r_cw_memWrite_E    (clk, rst_n, hz_flush_n_E, hz_stall_n_E, cw_memWrite_D, cw_memWrite_E);
    sm_register_wes      r_cw_memToReg_E    (clk, rst_n, hz_flush_n_E, hz_stall_n_E, cw_memToReg_D, cw_memToReg_E);
    sm_register_wes      r_cw_memAccess_E   (clk, rst_n, hz_flush_n_E, hz_stall_n_E, cw_memAccess_D,   cw_memAccess_E);
    sm_register_wes      r_cw_cpzRegWrite_E (clk, rst_n, hz_flush_n_E, hz_stall_n_E, cw_cpzRegWrite_D, cw_cpzRegWrite_E);
    sm_register_wes      r_cw_cpzExcEret_E  (clk, rst_n, hz_flush_n_E, hz_stall_n_E, cw_cpzExcEret_D,  cw_cpzExcEret_E);
    sm_register_wes      r_cw_cpzToReg_E    (clk, rst_n, hz_flush_n_E, hz_stall_n_E, cw_cpzToReg_D,    cw_cpzToReg_E);

    //instruction code for debug
    wire [31:0] instr_E;
    sm_register_wes #(32) r_instr_E  (clk, rst_n, hz_flush_n_E, hz_stall_n_E, instr_D, instr_E);

    // **********************************************************
    // E - Execution
    // **********************************************************

    //hazard wires
    wire [ 1:0] hz_forwardA_E;  //forward srcA
    wire [ 1:0] hz_forwardB_E;  //forward srcB
    wire        hz_forwardEPC_E;
    wire        hz_stall_n_M;

    wire [31:0] aluSrcA_E = ( hz_forwardA_E == `HZ_FW_WE ) ? writeData_W : (
                            ( hz_forwardA_E == `HZ_FW_ME ) ? aluResult_M : regData1_E );

    //data to write from RF to Mem
    assign      writeData_E = ( hz_forwardB_E == `HZ_FW_WE ) ? writeData_W : (
                              ( hz_forwardB_E == `HZ_FW_ME ) ? aluResult_M : regData2_E );

    wire [31:0] aluSrcB_E =   cw_aluSrc_E ? signImm_E : writeData_E;

    //alu
    wire        aluZero_E;      //not used, branch prediction is on D stage
    wire [31:0] aluResult_E;

    sm_alu alu
    (
        .srcA       ( aluSrcA_E    ),
        .srcB       ( aluSrcB_E    ),
        .oper       ( cw_aluCtrl_E ),
        .shift      ( instrSa_E    ),
        .zero       ( aluZero_E    ),
        .result     ( aluResult_E  ) 
    );

    //reg to write
    wire [ 4:0] writeReg_E = cw_regDst_E ? instrRd_E : instrRt_E;

    //exceptions
    wire [31:0] epcNext_f_E = hz_forwardEPC_E ? pcBranch_D : epcNext_E;

    //stage data border
    wire [31:0] epcNext_M;
    wire [ 4:0] writeReg_M;
    wire [ 4:0] instrRd_M;
    wire [ 2:0] instrSel_M;
    wire        excRiFound_M;
    wire        irqRequest_M;
    sm_register_we #(32) r_epcNext_M    (clk, rst_n, hz_stall_n_M, epcNext_f_E,   epcNext_M);
    sm_register_we #(32) r_aluResult_M  (clk, rst_n, hz_stall_n_M, aluResult_E, aluResult_M);
    sm_register_we #(32) r_writeData_M  (clk, rst_n, hz_stall_n_M, writeData_E, writeData_M);
    sm_register_we #( 5) r_writeReg_M   (clk, rst_n, hz_stall_n_M, writeReg_E,  writeReg_M);
    sm_register_we #( 5) r_instrRd_M    (clk, rst_n, hz_stall_n_M, instrRd_E,   instrRd_M);
    sm_register_we #( 3) r_instrSel_M   (clk, rst_n, hz_stall_n_M, instrSel_E,  instrSel_M);
    sm_register_we       r_excRiFound_M (clk, rst_n, hz_stall_n_M, excRiFound_E, excRiFound_M);
    sm_register_we       r_irqRequest_M (clk, rst_n, hz_stall_n_M, irqRequest_E,  irqRequest_M);

    //stage control border
    wire          cw_regWrite_M;
    wire          cw_memWrite_M;
    wire          cw_memToReg_M;
    wire          cw_memAccess_M;
    wire          cw_cpzRegWrite_M;
    wire          cw_cpzExcEret_M;
    wire          cw_cpzToReg_M;
    sm_register_we r_cw_regWrite_M    (clk, rst_n, hz_stall_n_M, cw_regWrite_E, cw_regWrite_M);
    sm_register_we r_cw_memWrite_M    (clk, rst_n, hz_stall_n_M, cw_memWrite_E, cw_memWrite_M);
    sm_register_we r_cw_memToReg_M    (clk, rst_n, hz_stall_n_M, cw_memToReg_E, cw_memToReg_M);
    sm_register_we r_cw_memAccess_M   (clk, rst_n, hz_stall_n_M, cw_memAccess_E,   cw_memAccess_M);
    sm_register_we r_cw_cpzRegWrite_M (clk, rst_n, hz_stall_n_M, cw_cpzRegWrite_E, cw_cpzRegWrite_M);
    sm_register_we r_cw_cpzExcEret_M  (clk, rst_n, hz_stall_n_M, cw_cpzExcEret_E,  cw_cpzExcEret_M);
    sm_register_we r_cw_cpzToReg_M    (clk, rst_n, hz_stall_n_M, cw_cpzToReg_E,    cw_cpzToReg_M);

    //instruction code for debug
    wire [31:0] instr_M;
    sm_register_we #(32) r_instr_M  (clk, rst_n, hz_stall_n_M, instr_E, instr_M);

    // **********************************************************
    // M - Memory
    // **********************************************************

    //hazard wires
    wire hz_stall_n_W;

    // memory
    assign dmWe    = cw_memWrite_M;
    assign dmAddr  = aluResult_M;
    assign dmWData = writeData_M;
    assign dmValid = cw_memAccess_M;

    //coprocessor 0
    wire cp0_ExcSync_M;         //not used, branch processed on D stage
    wire cp0_ExcAsync_M;        //not used
    wire cp0_ExcOv_M  = 1'b0;   //TODO: overflow from E stage
    wire [31:0] cp0_Data_M;

    wire cp0_TI_M;
    wire [5:0] cp0_ExcIP_M = { cp0_TI_M, 5'b0 };

    sm_cpz sm_cpz
    (
        .clk            ( clk              ),
        .rst_n          ( rst_n            ),
        .cp0_PC         ( epcNext_M        ),
        .cp0_EPC        ( cp0_EPC_M        ),
        .cp0_ExcHandler ( cp0_ExcHandler_M ),
        .cp0_ExcAsyncReq ( cp0_ExcAsyncReq_M ),
        .cp0_ExcAsyncAck ( irqRequest_M    ),
        .cp0_ExcAsync   ( cp0_ExcAsync_M   ),
        .cp0_ExcSync    ( cp0_ExcSync_M    ),
        .cp0_ExcEret    ( cw_cpzExcEret_M  ),
        .cp0_regNum     ( instrRd_M        ),
        .cp0_regSel     ( instrSel_M       ),
        .cp0_regRD      ( cp0_Data_M       ),
        .cp0_regWD      ( writeData_M      ),
        .cp0_regWE      ( cw_cpzRegWrite_M ),
        .cp0_ExcIP      ( cp0_ExcIP_M      ),
        .cp0_ExcRI      ( excRiFound_M     ),
        .cp0_ExcOv      ( cp0_ExcOv_M      ),
        .cp0_TI         ( cp0_TI_M         )
    );

    //stage data border
    wire [31:0] aluResult_W;
    wire [31:0] cp0_Data_W;
    sm_register_we #(32) r_aluResult_W (clk, rst_n, hz_stall_n_W, aluResult_M, aluResult_W);
    sm_register_we #(32) r_cp0_Data_W  (clk, rst_n, hz_stall_n_W, cp0_Data_M,  cp0_Data_W);
    sm_register_we #(5)  r_writeReg_W  (clk, rst_n, hz_stall_n_W, writeReg_M,  writeReg_W);

    //stage control border
    wire          cw_memToReg_W;
    wire          cw_cpzToReg_W;
    sm_register_we r_cw_memToReg_W (clk, rst_n, hz_stall_n_W, cw_memToReg_M, cw_memToReg_W);
    sm_register_we r_cw_cpzToReg_W (clk, rst_n, hz_stall_n_W, cw_cpzToReg_M, cw_cpzToReg_W);
    sm_register_we r_cw_regWrite_W (clk, rst_n, hz_stall_n_W, cw_regWrite_M, cw_regWrite_W);

    //instruction code for debug
    wire [31:0] instr_W;
    sm_register_we #(32) r_instr_W (clk, rst_n, hz_stall_n_W, instr_M, instr_W);

    // **********************************************************
    // W - Writeback
    // **********************************************************

    // memory
    wire [31:0] readData_W =  dmRData;
    wire         memBusy_W = ~dmReady;

    //data to write from Mem to RF
    assign writeData_W = cw_memToReg_W ? readData_W : 
                         cw_cpzToReg_W ? cp0_Data_W : aluResult_W;

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
        .hz_forwardB_E  ( hz_forwardB_E ),

        .instrRs_D      ( instrRs_D     ),
        .instrRt_D      ( instrRt_D     ),
        .writeReg_E     ( writeReg_E    ),
        .cw_memToReg_E  ( cw_memToReg_E ),
        .hz_stall_n_F   ( hz_stall_n_F  ),
        .hz_stall_n_D   ( hz_stall_n_D  ),
        .hz_flush_n_E   ( hz_flush_n_E  ),

        .memBusy_W      ( memBusy_W     ),
        .cw_memWrite_M  ( cw_memWrite_M ),
        .hz_stall_n_E   ( hz_stall_n_E  ),
        .hz_stall_n_M   ( hz_stall_n_M  ),
        .hz_stall_n_W   ( hz_stall_n_W  ),

        .cw_branch_D    ( cw_branch_D   ),
        .cw_regWrite_E  ( cw_regWrite_E ),
        .cw_memToReg_M  ( cw_memToReg_M ),
        .hz_forwardA_D  ( hz_forwardA_D ),
        .hz_forwardB_D  ( hz_forwardB_D ),

        .cw_cpzToReg_E      ( cw_cpzToReg_E      ),
        .cw_pcSrc_D         ( cw_pcSrc_D         ),
        .irqRequest_E       ( irqRequest_E       ),
        .irqRequest_M       ( irqRequest_M       ),
        .hz_flush_n_D       ( hz_flush_n_D       ),
        .cw_cpzExcEret_D    ( cw_cpzExcEret_D    ),
        .excSync_D          ( excSync_D          ),
        .hz_cancel_branch_F ( hz_cancel_branch_F ),
        .hz_forwardEPC_E    ( hz_forwardEPC_E    ),
        .hz_irq_disable_D   ( hz_irq_disable_D   ),
        .hz_forwardEPC_F    ( hz_forwardEPC_F    ),
        .cw_cpzRegWrite_E   ( cw_cpzRegWrite_E   ),
        .cw_cpzRegWrite_M   ( cw_cpzRegWrite_M   ),
        .instrRd_E          ( instrRd_E          ),
        .instrRd_M          ( instrRd_M          ),
        .instrSel_E         ( instrSel_E         ),
        .instrSel_M         ( instrSel_M         )
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
    output  [ 1:0]  hz_forwardB_E,  //forward srcB

    input   [ 4:0]  instrRs_D,
    input   [ 4:0]  instrRt_D,
    input   [ 4:0]  writeReg_E,
    input           cw_memToReg_E,
    output          hz_stall_n_F,   //stall F stage
    output          hz_stall_n_D,   //stall D stage
    output          hz_flush_n_E,   //flush_n E stage

    input           memBusy_W,
    input           cw_memWrite_M,
    output          hz_stall_n_E,
    output          hz_stall_n_M,
    output          hz_stall_n_W,

    input           cw_branch_D,
    input           cw_regWrite_E,
    input           cw_memToReg_M,
    output          hz_forwardA_D,  //forward srcA
    output          hz_forwardB_D,  //forward srcB

    input           cw_cpzToReg_E,
    input           cw_pcSrc_D,
    input           irqRequest_E,
    input           irqRequest_M,
    output          hz_flush_n_D,      //flush_n D stage
    input           cw_cpzExcEret_D,
    input           excSync_D,
    output          hz_cancel_branch_F,
    output          hz_forwardEPC_E,
    output          hz_irq_disable_D,
    output   [ 1:0] hz_forwardEPC_F,
    input           cw_cpzRegWrite_E,
    input           cw_cpzRegWrite_M,
    input   [ 4:0]  instrRd_E,
    input   [ 4:0]  instrRd_M,
    input   [ 2:0]  instrSel_E,
    input   [ 2:0]  instrSel_M
);
    //data forwarding
    assign hz_forwardA_E =  ( instrRs_E == 5'b0                        ) ? `HZ_FW_NONE : (
                            ( instrRs_E == writeReg_M && cw_regWrite_M ) ? `HZ_FW_ME   : (
                            ( instrRs_E == writeReg_W && cw_regWrite_W ) ? `HZ_FW_WE   : `HZ_FW_NONE ));

    assign hz_forwardB_E =  ( instrRt_E == 5'b0                        ) ? `HZ_FW_NONE : (
                            ( instrRt_E == writeReg_M && cw_regWrite_M ) ? `HZ_FW_ME   : (
                            ( instrRt_E == writeReg_W && cw_regWrite_W ) ? `HZ_FW_WE   : `HZ_FW_NONE ));

    //stalling for memory fetch
    wire hz_mem_stall = ( cw_cpzToReg_E || cw_memToReg_E ) && ( instrRs_D == writeReg_E || instrRt_D == writeReg_E );

    //control forwarding && branch stalling
    assign hz_forwardA_D = ( instrRs_D != 5'b0 && instrRs_D == writeReg_M && cw_regWrite_M );
    assign hz_forwardB_D = ( instrRt_D != 5'b0 && instrRt_D == writeReg_M && cw_regWrite_M );

    wire hz_branch_stall =  cw_branch_D && (
                             ( cw_regWrite_E && ( instrRs_D == writeReg_E || instrRt_D == writeReg_E ))
                          || ( cw_memToReg_M && ( instrRs_D == writeReg_M || instrRt_D == writeReg_M ))
                            );

    wire hz_stall_prior_to_E = hz_mem_stall || hz_branch_stall;

    //exceptions branch hazards
    wire   hz_branch_after_irq = cw_pcSrc_D & irqRequest_E;     // when branch was fetched after async exception request
    assign hz_cancel_branch_F  = hz_branch_after_irq;           // - canceling branch execution
    assign hz_forwardEPC_E     = hz_branch_after_irq;           // - forwarding branch PC to EPC

    //prevents from continious entering into interrupt handler
    assign hz_irq_disable_D = irqRequest_E | irqRequest_M;

    //flushing D stage
    assign hz_flush_n_D = ~((cw_pcSrc_D & ~irqRequest_E) // branching when no irq was before
                           | cw_cpzExcEret_D             // after eret
                           | excSync_D );                // after sync interrupt

    // forward EPC from E or M stage
    //  when EPC was written just before ERET
    assign hz_forwardEPC_F = ( cw_cpzExcEret_D && cw_cpzRegWrite_E && 
                               instrRd_E  == `CP0_REG_NUM_EPC && 
                               instrSel_E == `CP0_REG_SEL_EPC ) ? `HZ_FW_EF :
                             ( cw_cpzExcEret_D && cw_cpzRegWrite_M && 
                               instrRd_M  == `CP0_REG_NUM_EPC && 
                               instrSel_M == `CP0_REG_SEL_EPC ) ? `HZ_FW_MF : `HZ_FW_NONE;

    // stalling for data memory long fetch
    wire hz_stall_prior_to_W = memBusy_W;

    //stalling
    assign hz_stall_n_F = ~hz_stall_prior_to_E & ~hz_stall_prior_to_W;
    assign hz_stall_n_D = ~hz_stall_prior_to_E & ~hz_stall_prior_to_W;
    assign hz_flush_n_E = ~hz_stall_prior_to_E;
    assign hz_stall_n_E = ~hz_stall_prior_to_W;
    assign hz_stall_n_M = ~hz_stall_prior_to_W;
    assign hz_stall_n_W = ~hz_stall_prior_to_W;

endmodule
