/*
 * schoolMIPS - small MIPS CPU for "Young Russian Chip Architects" 
 *              summer school ( yrca@googlegroups.com )
 *
 * originally based on Sarah L. Harris MIPS CPU 
 * 
 * Copyright(c) 2017 Stanislav Zhelnio 
 *                   Aleksandr Romanov
 *                   Andrey Popov
 *                   Vladislav Tarasevish
 */ 


module sm_cpu
(
    input           clk,        // clock
    input           rst_n,      // reset
    input   [ 4:0]  regAddr,    // debug access reg address
    output logic [31:0]  regData,    // debug access reg data
    output logic [31:0]  imAddr,     // instruction memory address
    input   [31:0]  imData,     // instruction memory data
    output  logic [31:0]  dmAddr,     // data memory address
    output  logic dmWe,       // data memory write enable
    output  logic [31:0]  dmWData,    // data memory write data
    input   [31:0]  dmRData     // data memory read data
);
    // control wires
    wire        pcSrc;
    wire        regDst;
    wire        regWrite;
    wire        aluSrc;
    wire        aluZero;
    sm_cpu_config::ALU_Command aluControl;
    wire        memToReg;
    wire        memWrite;

    // program counter
    logic [31:0] pc, pcBranch, pcNext, pc_new;
    always_comb begin
        pcNext = pc + 1;
        pc_new = ~pcSrc ? pcNext : pcBranch;
    end
    sm_register r_pc(clk ,rst_n, pc_new, pc);

    // program memory access
    logic [31:0] instr;
    always_comb begin
        imAddr = pc;
        instr = imData;
    end

    // debug register access
    wire [31:0] rd0;
    always_comb begin
        regData = (regAddr != 0) ? rd0 : pc;
    end


    // register file
    logic [31:0] rd1, rd2, wd3;
    logic [4:0] a3;
    always_comb begin
        a3 = regDst ? instr[15:11] : instr[20:16];
    end

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

    // sign extension
    logic [31:0] signImm;
    always_comb begin
        signImm = { {16 { instr[15] }}, instr[15:0] };
        pcBranch = pcNext + signImm;
    end

    // alu
    logic [31:0] aluResult, srcB;
    always_comb begin
        srcB = aluSrc ? signImm : rd2;
    end

    sm_alu alu
    (
        .srcA       ( rd1          ),
        .srcB       ( srcB         ),
        .oper       ( aluControl   ),
        .shift      ( instr[10:6 ] ),
        .zero       ( aluZero      ),
        .result     ( aluResult    ) 
    );

    // data memory access
    always_comb begin
        wd3 = memToReg ? dmRData : aluResult;
        dmWe = memWrite;
        dmAddr = aluResult;
        dmWData = rd2;
    end

    // control
    sm_control sm_control
    (
        .cmd (sm_cpu_config::Command'({instr[31:26], instr[5:0]})),
        .aluZero    ( aluZero      ),
        .pcSrc      ( pcSrc        ), 
        .regDst     ( regDst       ), 
        .regWrite   ( regWrite     ), 
        .aluSrc     ( aluSrc       ),
        .aluControl ( aluControl   ),
        .memWrite   ( memWrite     ),
        .memToReg   ( memToReg     )
    );

endmodule : sm_cpu


module sm_control
(
    input sm_cpu_config::Command cmd,
    input            aluZero,
    output logic          pcSrc,
    output reg       regDst, 
    output reg       regWrite, 
    output reg       aluSrc,
    output sm_cpu_config::ALU_Command aluControl,
    output reg       memWrite,
    output reg       memToReg
);
    import sm_cpu_config::*;

    reg          branch;
    reg          condZero;

    always_comb begin
        branch      = 1'b0;
        condZero    = 1'b0;
        regDst      = 1'b0;
        regWrite    = 1'b0;
        aluSrc      = 1'b0;
        aluControl  = ALU_ADD;
        memWrite    = 1'b0;
        memToReg    = 1'b0;

        casez (cmd)
            ADDU: begin regDst = 1'b1; regWrite = 1'b1; aluControl = ALU_ADD;  end
            OR: begin regDst = 1'b1; regWrite = 1'b1; aluControl = ALU_OR;   end
            SRL: begin regDst = 1'b1; regWrite = 1'b1; aluControl = ALU_SRL;  end
            SLTU: begin regDst = 1'b1; regWrite = 1'b1; aluControl = ALU_SLTU; end
            SUBU: begin regDst = 1'b1; regWrite = 1'b1; aluControl = ALU_SUBU; end

            ADDIU: begin regWrite = 1'b1; aluSrc = 1'b1; aluControl = ALU_ADD;  end
            LUI: begin regWrite = 1'b1; aluSrc = 1'b1; aluControl = ALU_LUI;  end
            LW : begin regWrite = 1'b1; aluSrc = 1'b1; aluControl = ALU_ADD; memToReg = 1'b1; end
            SW : begin memWrite = 1'b1; aluSrc = 1'b1; aluControl = ALU_ADD;  end
            BEQ : begin branch = 1'b1; condZero = 1'b1; aluControl = ALU_SUBU; end
            BNE : begin branch = 1'b1; aluControl = ALU_SUBU; end
        endcase

        pcSrc = branch & (aluZero == condZero);
    end

endmodule : sm_control


module sm_alu
(
    input  [31:0] srcA,
    input  [31:0] srcB,
    input sm_cpu_config::ALU_Command oper,
    input  [ 4:0] shift,
    output logic zero,
    output reg [31:0] result
);
    import sm_cpu_config::*;

    always_comb begin
        case (oper)
            ALU_ADD  : result = srcA + srcB;
            ALU_OR   : result = srcA | srcB;
            ALU_LUI  : result = (srcB << 16);
            ALU_SRL  : result = srcB >> shift;
            ALU_SLTU : result = (srcA < srcB) ? 1 : 0;
            ALU_SUBU : result = srcA - srcB;
        endcase

        zero = (result == 0);
    end

endmodule : sm_alu


module sm_register_file
(
    input         clk,
    input  [ 4:0] a0,
    input  [ 4:0] a1,
    input  [ 4:0] a2,
    input  [ 4:0] a3,
    output logic [31:0] rd0,
    output logic [31:0] rd1,
    output logic [31:0] rd2,
    input  [31:0] wd3,
    input         we3
);
    reg [31:0] rf [31:0];

    always_comb begin
        rd0 = (a0 != 0) ? rf [a0] : 32'b0;
        rd1 = (a1 != 0) ? rf [a1] : 32'b0;
        rd2 = (a2 != 0) ? rf [a2] : 32'b0;
    end

    always @ (posedge clk)
        if(we3) rf [a3] <= wd3;

endmodule : sm_register_file
