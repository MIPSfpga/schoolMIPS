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

package sm_cpu_config;
    // ALU commands
    typedef enum logic[2:0] {
        ALU_ADD, ALU_OR, ALU_LUI,
        ALU_SRL, ALU_SLTU, ALU_SUBU
    } ALU_Command;

    // CPU commands
    typedef enum logic[11:0] {
        // {operation code, function field}
        ADDIU = {6'b001001, 6'b??????}, // I-type, Integer Add Immediate Unsigned
                                        // Rd = Rs + Immed
        LUI   = {6'b001111, 6'b??????}, // I-type, Load Upper Immediate
                                        // Rt = Immed << 16
        LW    = {6'b100011, 6'b??????}, // I-type, Load Word
                                        // Rt = memory[Rs + Immed]
        SW    = {6'b101011, 6'b??????}, // I-type,  Store Word
                                        // memory[Rs + Immed] = Rt
        BEQ   = {6'b000100, 6'b??????}, // I-type, Branch On Equal
                                        // if (Rs == Rt) PC += (int)offset
        BNE   = {6'b000101, 6'b??????}, // I-type, Branch on Not Equal
                                        // if (Rs != Rt) PC += (int)offset

        ADDU = {6'b000000, 6'b100001}, // R-type, Integer Add Unsigned
                                       // Rd = Rs + Rt
        OR   = {6'b000000, 6'b100101}, // R-type, Logical OR
                                       // Rd = Rs | Rt
        SRL  = {6'b000000, 6'b000010}, // R-type, Shift Right Logical
                                       // Rd = Rs∅ >> shift
        SLTU = {6'b000000, 6'b101011}, // R-type, Set on Less Than Unsigned
                                       // Rd = (Rs∅ < Rt∅) ? 1 : 0
        SUBU = {6'b000000, 6'b100011}  // R-type, Unsigned Subtract
                                       // Rd = Rs – Rt
    } Command;
endpackage : sm_cpu_config
