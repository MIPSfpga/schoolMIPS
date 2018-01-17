/*
 * schoolMIPS - small MIPS CPU for "Young Russian Chip Architects" 
 *              summer school ( yrca@googlegroups.com )
 *
 * originally based on Sarah L. Harris MIPS CPU 
 * 
 * Copyright(c) 2017 Stanislav Zhelnio 
 *                   Alexander Romanov 
 */ 

//ALU commands
`define ALU_ADD     3'b000
`define ALU_OR      3'b001
`define ALU_LUI     3'b010
`define ALU_SRL     3'b011
`define ALU_SLTU    3'b100
`define ALU_SUBU    3'b101

//instruction operation code
`define C_SPEC      6'b000000 // Special instructions (depends on function field)
`define C_ADDIU     6'b001001 // I-type, Integer Add Immediate Unsigned
                              //         Rd = Rs + Immed
`define C_BEQ       6'b000100 // I-type, Branch On Equal
                              //         if (Rs == Rt) PC += (int)offset
`define C_LUI       6'b001111 // I-type, Load Upper Immediate
                              //         Rt = Immed << 16
`define C_BNE       6'b000101 // I-type, Branch on Not Equal
                              //         if (Rs != Rt) PC += (int)offset
`define C_LW        6'b100011 // I-type, Load Word
                              //         Rt = memory[Rs + Immed]
`define C_SW        6'b101011 // I-type,  Store Word
                              //         memory[Rs + Immed] = Rt
`define C_NOP       6'b000000 // No Operation

//instruction function field
`define F_ADDU      6'b100001 // R-type, Integer Add Unsigned
                              //         Rd = Rs + Rt
`define F_OR        6'b100101 // R-type, Logical OR
                              //         Rd = Rs | Rt
`define F_SRL       6'b000010 // R-type, Shift Right Logical
                              //         Rd = Rs∅ >> shift
`define F_SLTU      6'b101011 // R-type, Set on Less Than Unsigned
                              //         Rd = (Rs∅ < Rt∅) ? 1 : 0
`define F_SUBU      6'b100011 // R-type, Unsigned Subtract
                              //         Rd = Rs – Rt
`define F_ERET      6'b011000 // ERET,   Exception Return
                              //        
`define F_NOP       6'b000000 // No Operation
`define F_ANY       6'b??????


//coprocessor 
`define C_COP0      6'b010000 // Soprocessor 0 instruction
`define S_COP0_MF   5'b00000  // MFC0, Move from Coprocessor 0
                              //         Rt = CP0 [Rd, Sel]
`define S_COP0_MT   5'b00100  // MTC0, Move to Coprocessor 0
                              //         CP0 [Rd, Sel] = Rt
`define S_ERET      5'b10000  // ERET, Exception Return
                              //         CP0 [Rd, Sel] = Rt
`define S_NOP       5'b00000  // No Operation
`define S_ANY       5'b?????

//PC_new selector
`define PC_FLOW     2'b00
`define PC_EXC      2'b01
`define PC_ERET     2'b10

//cp0 registers
`define CP0_REG_NUM_COUNT   5'd9
`define CP0_REG_SEL_COUNT   3'd0
`define CP0_REG_NUM_COMPARE 5'd11
`define CP0_REG_SEL_COMPARE 3'd0
`define CP0_REG_NUM_STATUS  5'd12
`define CP0_REG_SEL_STATUS  3'd0
`define CP0_REG_NUM_CAUSE   5'd13
`define CP0_REG_SEL_CAUSE   3'd0
`define CP0_REG_NUM_EPC     5'd14
`define CP0_REG_SEL_EPC     3'd0

`define CP0_EXCCODE_INT     5'h00
`define CP0_EXCCODE_RI      5'h0a
`define CP0_EXCCODE_OV      5'h0c
