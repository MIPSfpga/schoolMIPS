/*
 * schoolMIPS - small MIPS CPU for "Young Russian Chip Architects"
 *              summer school ( yrca@googlegroups.com )
 *
 * originally based on Sarah L. Harris MIPS CPU
 *
 * Copyright(c) 2017-2018 Stanislav Zhelnio
 *                        Alexander Romanov
 */

`include "sm_cpu.vh"
`include "sm_settings.vh"

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
    output          dmValid,    // data memory read/write request
    input           dmReady,    // data memory read/write done
    input   [31:0]  dmRData     // data memory read data
);
    //control wires
    wire        pcSrc;
    wire [ 1:0] pcExc;
    wire        regDst;
    wire        regWrite;
    wire        aluSrc;
    wire        aluZero;
    wire [ 2:0] aluControl;
    wire        memToReg;
    wire        memWrite;
    wire        memAccess;
    wire        hz_stall;
    wire        hz_mem_en;

    //program counter
    wire [31:0] pc;
    wire [31:0] pcBranch;
    wire [31:0] pcNext  = pc + 4;
    wire [31:0] pc_new;
    wire [31:0] pc_flow = ~pcSrc ? pcNext : pcBranch;
    sm_register_we #(32) r_pc(clk ,rst_n, ~hz_stall, pc_new, pc);

    //program memory access
    assign imAddr = pc >> 2;  //schoolMIPS instruction memory is word addressable
    wire [31:0] instr = imData;

    //debug register access
    wire [31:0] rd0;
    assign regData = (regAddr != 0) ? rd0 : pc;

    //register file
    wire [ 4:0] a3  = regDst ? instr[15:11] : instr[20:16];
    wire [31:0] rd1;
    wire [31:0] rd2;
    wire [31:0] wd3;

    sm_register_file rf
    (
        .clk        ( clk          ),
        .a0         ( regAddr      ),
        .a1         ( instr[25:21] ),
        .a2         ( instr[20:16] ),
        .a3         ( a3           ),
        .rd0        ( rd0          ),
        .rd1        ( rd1          ),
        .rd2        ( rd2          ),
        .wd3        ( wd3          ),
        .we3        ( regWrite     )
    );

    //sign extension
    wire [31:0] signImm = { {16 { instr[15] }}, instr[15:0] };
    assign pcBranch = pcNext + (signImm << 2);

    //alu
    wire [31:0] aluResult;
    wire [31:0] srcB = aluSrc ? signImm : rd2;

    sm_alu alu
    (
        .srcA       ( rd1          ),
        .srcB       ( srcB         ),
        .oper       ( aluControl   ),
        .shift      ( instr[10:6 ] ),
        .zero       ( aluZero      ),
        .result     ( aluResult    )
    );

    //data memory access
    assign dmWe = memWrite;
    assign dmAddr = aluResult;
    assign dmWData = rd2;
    assign dmValid = hz_mem_en;

    //control
    wire        cw_cpzToReg;
    wire        cw_cpzRegWrite;
    wire        cp0_ExcAsync;       // request for Exception (async)
    wire        cp0_ExcSync;        // request for Exception (sync)
    wire        cw_cpzExcEret;      // return from Exception
    wire        excRiFound;         // reserved instruction found
    wire        cw_epcSrc;
    wire        cw_branch;          // not used

    sm_control sm_control
    (
        .cmdOper    ( instr[31:26] ),
        .cmdRegS    ( instr[25:21] ),
        .cmdFunk    ( instr[ 5:0 ] ),
        .aluZero    ( aluZero      ),
        .pcSrc      ( pcSrc        ),
        .pcExc      ( pcExc        ),
        .regDst     ( regDst       ),
        .regWrite   ( regWrite     ),
        .aluSrc     ( aluSrc       ),
        .aluControl ( aluControl   ),
        .memWrite   ( memWrite     ),
        .memToReg   ( memToReg     ),
        .memAccess  ( memAccess    ),
        .branch     ( cw_branch    ),
        .cw_cpzToReg    ( cw_cpzToReg    ),
        .cw_cpzRegWrite ( cw_cpzRegWrite ),
        .cw_cpzExcEret  ( cw_cpzExcEret  ),
        .excAsync       ( cp0_ExcAsync   ),
        .excSync        ( cp0_ExcSync    ),
        .cw_epcSrc      ( cw_epcSrc      ),
        .excRiFound     ( excRiFound     )
    );

    wire [31:0] cp0_EPC;                    // return address for eret
    wire [31:0] cp0_ExcHandler;             // exception Handler Addr
    wire [ 4:0] cp0_regNum = instr[15:11];  // cp0 register access num
    wire [ 2:0] cp0_regSel = instr[ 2:0 ];  // cp0 register access sel
    wire [31:0] cp0_regRD;                  // cp0 register access Read Data
    wire [31:0] cp0_regWD   = rd2;          // cp0 register access Write Data
    wire        cp0_TI;                     // cp0 timer interrupt
    wire [ 5:0] cp0_ExcIP = { cp0_TI, 5'b0 }; //TODO: External Interrupt
    wire        cp0_ExcRI   = excRiFound;   // Reserved Instruction exception
    wire        cp0_ExcOv   = 1'b0;         // TODO: Arithmetic Overflow exception
    wire        cp0_ExcAsyncRq;             // IRQ request feedback (used in pipeline)
    
    wire [31:0] cp0_PC = cw_epcSrc ? pc : pc_flow;

    sm_cpz sm_cpz
    (
        .clk            ( clk            ),
        .rst_n          ( rst_n          ),
        .cp0_PC         ( cp0_PC         ),
        .cp0_EPC        ( cp0_EPC        ),
        .cp0_ExcHandler ( cp0_ExcHandler ),
        .cp0_ExcAsyncReq( cp0_ExcAsyncRq ),
        .cp0_ExcAsyncAck( cp0_ExcAsyncRq ),
        .cp0_ExcAsync   ( cp0_ExcAsync   ),
        .cp0_ExcSync    ( cp0_ExcSync    ),
        .cp0_ExcEret    ( cw_cpzExcEret  ),
        .cp0_regNum     ( cp0_regNum     ),
        .cp0_regSel     ( cp0_regSel     ),
        .cp0_regRD      ( cp0_regRD      ),
        .cp0_regWD      ( cp0_regWD      ),
        .cp0_regWE      ( cw_cpzRegWrite ),
        .cp0_ExcIP      ( cp0_ExcIP      ),
        .cp0_ExcRI      ( cp0_ExcRI      ),
        .cp0_ExcOv      ( cp0_ExcOv      ),
        .cp0_TI         ( cp0_TI         )
    );

    assign wd3 = memToReg    ? dmRData   :
                ( cw_cpzToReg ? cp0_regRD : aluResult );

    assign pc_new = pcExc == `PC_EXC  ?  cp0_ExcHandler :
                    pcExc == `PC_ERET ?  cp0_EPC        :
                 /* pcExc == `PC_FLOW */ pc_flow;

    // hazards
    wire memWait;
    wire memAccessStart    = ~memWait &  memAccess;
    wire memAccessDone     =  memWait &  dmReady;
    wire memAccessProgress =  memWait & ~dmReady;

    wire memWait_new = memAccessStart ? 1 : // set when memory access start
                       memAccessDone  ? 0 : // unset when memory ready
                       memWait;
    sm_register_c r_memWait(clk ,rst_n, memWait_new, memWait);

    // stall for memory access
    // - 1st cycle of memory access and no info about ready signal on 2nd cycle
    // - 2nd and other cycles waiting for ready signal
    assign hz_stall  = memAccessStart | memAccessProgress;

    // memory request allowed:
    // - should be requested only on 1st cycle of mem access
    assign hz_mem_en = memAccessStart;

endmodule

module sm_control
(
    input      [5:0] cmdOper,
    input      [4:0] cmdRegS,
    input      [5:0] cmdFunk,
    input            aluZero,
    output           pcSrc,
    output     [1:0] pcExc,
    output reg       regDst,
    output reg       regWrite,
    output reg       aluSrc,
    output reg [2:0] aluControl,
    output reg       memWrite,
    output reg       memToReg,
    output reg       memAccess,
    output reg       branch,
    output reg       cw_cpzToReg,
    output reg       cw_cpzRegWrite,
    output reg       cw_cpzExcEret,
    input            excAsync,
    input            excSync,
    output           cw_epcSrc,
    output reg       excRiFound     // reserved instruction found
);
    reg          condZero;

    assign pcSrc = branch & (aluZero == condZero);

    assign cw_epcSrc = excSync;

    wire   exception = excAsync | excSync;
    assign pcExc = exception      ? `PC_EXC  :
                   cw_cpzExcEret  ? `PC_ERET : `PC_FLOW;

    always @ (*) begin
        branch      = 1'b0;
        condZero    = 1'b0;
        regDst      = 1'b0;
        regWrite    = 1'b0;
        aluSrc      = 1'b0;
        aluControl  = `ALU_ADD;
        memWrite    = 1'b0;
        memToReg    = 1'b0;
        memAccess   = 1'b0;
        cw_cpzToReg    = 1'b0;
        cw_cpzRegWrite = 1'b0;
        cw_cpzExcEret  = 1'b0;
        excRiFound  = 1'b0;

        casez( {cmdOper,cmdFunk, cmdRegS} )
            default               : excRiFound = 1'b1;

            { `C_SPEC,  `F_ADDU, `S_ANY } : begin regDst = 1'b1; regWrite = 1'b1; aluControl = `ALU_ADD;  end
            { `C_SPEC,  `F_OR,   `S_ANY } : begin regDst = 1'b1; regWrite = 1'b1; aluControl = `ALU_OR;   end
            { `C_SPEC,  `F_SRL,  `S_ANY } : begin regDst = 1'b1; regWrite = 1'b1; aluControl = `ALU_SRL;  end
            { `C_SPEC,  `F_SLL,  `S_ANY } : begin regDst = 1'b1; regWrite = 1'b1; aluControl = `ALU_SLL;  end
            { `C_SPEC,  `F_SLTU, `S_ANY } : begin regDst = 1'b1; regWrite = 1'b1; aluControl = `ALU_SLTU; end
            { `C_SPEC,  `F_SUBU, `S_ANY } : begin regDst = 1'b1; regWrite = 1'b1; aluControl = `ALU_SUBU; end

            { `C_ADDIU, `F_ANY,  `S_ANY } : begin regWrite = 1'b1; aluSrc = 1'b1; aluControl = `ALU_ADD;  end
            { `C_LUI,   `F_ANY,  `S_ANY } : begin regWrite = 1'b1; aluSrc = 1'b1; aluControl = `ALU_LUI;  end
            { `C_LW,    `F_ANY,  `S_ANY } : begin regWrite = 1'b1; aluSrc = 1'b1; aluControl = `ALU_ADD; 
                                                  memToReg = 1'b1; memAccess = 1'b1; end
            { `C_SW,    `F_ANY,  `S_ANY } : begin memWrite = 1'b1; aluSrc = 1'b1; aluControl = `ALU_ADD; 
                                                  memAccess = 1'b1; end

            { `C_BEQ,   `F_ANY,  `S_ANY } : begin branch = 1'b1; condZero = 1'b1; aluControl = `ALU_SUBU; end
            { `C_BNE,   `F_ANY,  `S_ANY } : begin branch = 1'b1; aluControl = `ALU_SUBU; end

            { `C_COP0, `F_ANY, `S_COP0_MF } : begin cw_cpzToReg = 1'b1; regWrite = 1'b1; end
            { `C_COP0, `F_ANY, `S_COP0_MT } : begin cw_cpzRegWrite = 1'b1; end
            { `C_COP0, `F_ERET, `S_ERET   } : begin cw_cpzExcEret  = 1'b1; end
            { `C_NOP,  `F_NOP,  `S_NOP    } : ;
        endcase
    end
endmodule


module sm_alu
(
    input  [31:0] srcA,
    input  [31:0] srcB,
    input  [ 2:0] oper,
    input  [ 4:0] shift,
    output        zero,
    output reg [31:0] result
);
    always @ (*) begin
        case (oper)
            default   : result = srcA + srcB;
            `ALU_ADD  : result = srcA + srcB;
            `ALU_OR   : result = srcA | srcB;
            `ALU_LUI  : result = (srcB << 16);
            `ALU_SRL  : result = srcB >> shift;
            `ALU_SLL  : result = srcB << shift;
            `ALU_SLTU : result = (srcA < srcB) ? 1 : 0;
            `ALU_SUBU : result = srcA - srcB;
        endcase
    end

    assign zero   = (result == 0);
endmodule

module sm_register_file
(
    input         clk,
    input  [ 4:0] a0,
    input  [ 4:0] a1,
    input  [ 4:0] a2,
    input  [ 4:0] a3,
    output [31:0] rd0,
    output [31:0] rd1,
    output [31:0] rd2,
    input  [31:0] wd3,
    input         we3
);
    reg [31:0] rf [31:0];

    `ifdef SM_FORCE_RF_RDW
        //Pass-through logic to match the read-during-write behavior
        assign rd0 = ( a0 == 5'b0      ) ? 32'b0 :
                     ( a0 == a3 && we3 ) ? wd3   : rf [a0];
        assign rd1 = ( a1 == 5'b0      ) ? 32'b0 :
                     ( a1 == a3 && we3 ) ? wd3   : rf [a1];
        assign rd2 = ( a2 == 5'b0      ) ? 32'b0 :
                     ( a2 == a3 && we3 ) ? wd3   : rf [a2];
    `else
        assign rd0 = (a0 != 0) ? rf [a0] : 32'b0;
        assign rd1 = (a1 != 0) ? rf [a1] : 32'b0;
        assign rd2 = (a2 != 0) ? rf [a2] : 32'b0;
    `endif

    always @ (posedge clk)
        if(we3) rf [a3] <= wd3;
endmodule
