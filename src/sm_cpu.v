/*
 * schoolMIPS - small MIPS CPU for "Young Russian Chip Architects" 
 *              summer school ( yrca@googlegroups.com )
 *
 * originally based on Sarah L. Harris MIPS CPU 
 * 
 * Copyright(c) 2017 Stanislav Zhelnio 
 *                   Alexander Romanov 
 */ 

module sm_cpu
(
    input           clk,
    input           rst_n,
    input   [ 4:0]  regAddr,
    output  [31:0]  regData
);
    //control wires
    wire        pcSrc;
    wire        regDst;
    wire        regWrite;
    wire        aluSrc;
    wire        aluZero;
    wire [ 2:0] aluControl;

    //program counter
    wire [31:0] pc;
    wire [31:0] pcBranch;
    wire [31:0] pcNext  = pc + 1;
    wire [31:0] pc_new   = ~pcSrc ? pcNext : pcBranch;
    sm_register r_pc(clk ,rst_n, pc_new, pc);

    //program memory
    wire [31:0] instr;
    sm_rom reset_rom(pc, instr);

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
    assign pcBranch = pcNext + signImm;

    //alu
    wire [31:0] srcB = aluSrc ? signImm : rd2;

    sm_alu alu
    (
        .srcA       ( rd1          ),
        .srcB       ( srcB         ),
        .oper       ( aluControl   ),
        .shift      ( instr[10:6 ] ),
        .zero       ( aluZero      ),
        .result     ( wd3          ) 
    );

    //control
    sm_control sm_control
    (
        .cmdOper    ( instr[31:26] ),
        .cmdFunk    ( instr[ 5:0 ] ),
        .aluZero    ( aluZero      ),
        .pcSrc      ( pcSrc        ), 
        .regDst     ( regDst       ), 
        .regWrite   ( regWrite     ), 
        .aluSrc     ( aluSrc       ),
        .aluControl ( aluControl   )
    );

endmodule

module sm_control
(
    input  [5:0] cmdOper,
    input  [5:0] cmdFunk,
    input        aluZero,
    output       pcSrc, 
    output       regDst, 
    output       regWrite, 
    output       aluSrc,
    output [2:0] aluControl
);
    wire         branch;
    wire         condZero;
    assign pcSrc = branch & (aluZero == condZero);

    // cmdOper values
    localparam  C_SPEC  = 6'b000000, // Special instructions (depends on cmdFunk field)
                C_ADDIU = 6'b001001, // I-type, Integer Add Immediate Unsigned
                                     //         Rd = Rs + Immed
                C_BEQ   = 6'b000100, // I-type, Branch On Equal
                                     //         if (Rs == Rt) PC += (int)offset
                C_LUI   = 6'b001111, // I-type, Load Upper Immediate
                                     //         Rt = Immed << 16
                C_BNE   = 6'b000101; // I-type, Branch on Not Equal
                                     //         if (Rs != Rt) PC += (int)offset

    // cmdFunk values
    localparam  F_ADDU  = 6'b100001, // R-type, Integer Add Unsigned
                                     //         Rd = Rs + Rt
                F_OR    = 6'b100101, // R-type, Logical OR
                                     //         Rd = Rs | Rt
                F_SRL   = 6'b000010, // R-type, Shift Right Logical
                                     //         Rd = Rs∅ >> shift
                F_SLTU  = 6'b101011, // R-type, Set on Less Than Unsigned
                                     //         Rd = (Rs∅  < Rt∅) ? 1 : 0
                F_SUBU  = 6'b100011, // R-type, Unsigned Subtract
                                     //         Rd = Rs – Rt
                F_ANY   = 6'b??????;

    reg    [7:0] conf;
    assign { branch, condZero, regDst, regWrite, aluSrc, aluControl } = conf;

    always @ (*) begin
        casez( {cmdOper,cmdFunk} )
            default             : conf = 8'b00;
            { C_SPEC,  F_ADDU } : conf = 8'b00110000;
            { C_SPEC,  F_OR   } : conf = 8'b00110001;
            { C_ADDIU, F_ANY  } : conf = 8'b00011000;
            { C_BEQ,   F_ANY  } : conf = 8'b11000000;
            { C_LUI,   F_ANY  } : conf = 8'b00011010;
            { C_SPEC,  F_SRL  } : conf = 8'b00110011;
            { C_SPEC,  F_SLTU } : conf = 8'b00110100;
            { C_BNE,   F_ANY  } : conf = 8'b10000000;
            { C_SPEC,  F_SUBU } : conf = 8'b00110101;
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
    localparam ALU_ADD  = 3'b000,
               ALU_OR   = 3'b001,
               ALU_LUI  = 3'b010,
               ALU_SRL  = 3'b011,
               ALU_SLTU = 3'b100,
               ALU_SUBU = 3'b101;

    always @ (*) begin
        case (oper)
            default  : result = srcA + srcB;
            ALU_ADD  : result = srcA + srcB;
            ALU_OR   : result = srcA | srcB;
            ALU_LUI  : result = (srcB << 16);
            ALU_SRL  : result = srcB >> shift;
            ALU_SLTU : result = (srcA < srcB) ? 1 : 0;
            ALU_SUBU : result = srcA - srcB;
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

    assign rd0 = (a0 != 0) ? rf [a0] : 32'b0;
    assign rd1 = (a1 != 0) ? rf [a1] : 32'b0;
    assign rd2 = (a2 != 0) ? rf [a2] : 32'b0;

    always @ (posedge clk)
        if(we3) rf [a3] <= wd3;
endmodule
