/*
 * schoolMIPS - small MIPS CPU for "Young Russian Chip Architects" 
 *              summer school ( yrca@googlegroups.com )
 *
 * originally based on Sarah L. Harris MIPS CPU 
 * 
 * Copyright(c) 2017-2018 Stanislav Zhelnio
 */ 

`timescale 1 ns / 100 ps

`include "sm_settings.vh"
`include "sm_cpu.vh"

`ifndef SIMULATION_CYCLES
    `define SIMULATION_CYCLES   120
`endif

module sm_testbench;

    // simulation options
    parameter Tt     = 20;

    reg         clk;
    reg         rst_n;
    reg  [ 4:0] regAddr;
    wire [31:0] regData;
    wire        cpuClk;

    // peripheral wires
    `ifdef SM_CONFIG_AHB_GPIO
    wire [`SM_GPIO_WIDTH - 1:0] port_gpioIn  = 32'h2;
    wire [`SM_GPIO_WIDTH - 1:0] port_gpioOut;
    `endif

    // ***** DUT start ************************

    sm_top sm_top
    (
        .clkDevide ( 4'b0    ),
        .clkEnable ( 1'b1    ),
        .clk       ( cpuClk  ),
        .regAddr   ( regAddr ),
        .regData   ( regData ),

        `ifdef SM_CONFIG_AHB_GPIO
        .port_gpioIn  ( port_gpioIn  ),
        .port_gpioOut ( port_gpioOut ),
        `endif

        .clkIn     ( clk     ),
        .rst_n     ( rst_n   )
    );

    defparam sm_top.sm_clk_divider.bypass = 1;

    // ***** DUT  end  ************************

`ifdef ICARUS
    //iverilog memory dump init workaround
    initial $dumpvars;
    genvar k;
    for (k = 0; k < 32; k = k + 1) begin
        initial $dumpvars(0, sm_top.sm_cpu.rf.rf[k]);
    end
`endif

    // simulation init
    initial begin
        clk = 0;
        forever clk = #(Tt/2) ~clk;
    end

    initial begin
        rst_n   = 0;
        repeat (4)  @(posedge clk);
        rst_n   = 1;
    end

    //register file reset
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            sm_top.sm_cpu.rf.rf[i] = 0;
    end

    task disasmInstr
    (
        input [31:0] instr
    );
        reg        [ 5:0] cmdOper;
        reg        [ 5:0] cmdFunk;
        reg        [ 4:0] cmdRs;
        reg        [ 4:0] cmdRt;
        reg        [ 4:0] cmdRd;
        reg        [ 4:0] cmdSa;
        reg        [15:0] cmdImm;
        reg signed [15:0] cmdImmS;
        reg        [ 2:0] cmdSel;

        begin
            cmdOper = instr[31:26];
            cmdFunk = instr[ 5:0 ];
            cmdRs   = instr[25:21];
            cmdRt   = instr[20:16];
            cmdRd   = instr[15:11];
            cmdSa   = instr[10:6 ];
            cmdImm  = instr[15:0 ];
            cmdImmS = instr[15:0 ];
            cmdSel  = instr[ 2:0 ];

            $write("   ");

            casez( {cmdOper, cmdFunk, cmdRs} )
                default                         : $write ("new/unknown           ");

                { `C_SPEC,  `F_ADDU, `S_ANY }   : $write ("addu  $%1d, $%1d, $%1d", cmdRd, cmdRs, cmdRt);
                { `C_SPEC,  `F_OR  , `S_ANY }   : $write ("or    $%1d, $%1d, $%1d", cmdRd, cmdRs, cmdRt);
                { `C_SPEC,  `F_SRL , `S_ANY }   : $write ("srl   $%1d, $%1d, $%1d", cmdRd, cmdRs, cmdRt);
                { `C_SPEC,  `F_SLL , `S_ANY }   : $write ("sll   $%1d, $%1d, $%1d", cmdRd, cmdRs, cmdRt);
                { `C_SPEC,  `F_SLTU, `S_ANY }   : $write ("sltu  $%1d, $%1d, $%1d", cmdRd, cmdRs, cmdRt);
                { `C_SPEC,  `F_SUBU, `S_ANY }   : $write ("subu  $%1d, $%1d, $%1d", cmdRd, cmdRs, cmdRt);
                 
                { `C_ADDIU, `F_ANY , `S_ANY }   : $write ("addiu $%1d, $%1d, %2d", cmdRt, cmdRs, cmdImm);
                { `C_LUI,   `F_ANY , `S_ANY }   : $write ("lui   $%1d, %2d      ", cmdRt, cmdImm);
                { `C_LW,    `F_ANY , `S_ANY }   : $write ("lw    $%1d, %2d($%1d)", cmdRt, cmdImm, cmdRs);
                { `C_SW,    `F_ANY , `S_ANY }   : $write ("sw    $%1d, %2d($%1d)", cmdRt, cmdImm, cmdRs);
                
                { `C_BEQ,   `F_ANY , `S_ANY }   : $write ("beq   $%1d, $%1d, %1d", cmdRs, cmdRt, cmdImmS + 1);
                { `C_BNE,   `F_ANY , `S_ANY }   : $write ("bne   $%1d, $%1d, %1d", cmdRs, cmdRt, cmdImmS + 1);

                { `C_COP0, `F_ANY, `S_COP0_MF } : $write ("mfc0  $%1d, $%1d, %2d", cmdRt, cmdRd, cmdSel);
                { `C_COP0, `F_ANY, `S_COP0_MT } : $write ("mtc0  $%1d, $%1d, %2d", cmdRt, cmdRd, cmdSel);
                { `C_COP0, `F_ERET, `S_ERET   } : $write ("eret            ");
                { `C_NOP,  `F_NOP,  `S_NOP    } : $write ("nop             ");

            endcase
        end

    endtask


    //simulation debug output
    integer cycle; initial cycle = 0;

    initial regAddr = 0; // get PC

    always @ (posedge clk)
    begin

    `ifdef SM_CONFIG_PIPELINE
        $write ("%5d  pc_F = %h  instr_D = %h   v0 = %1d", 
                  cycle, regData, sm_top.sm_cpu.instr_D, sm_top.sm_cpu.rf.rf[2]);
        disasmInstr(sm_top.sm_cpu.instr_D); $write (" ");
        disasmInstr(sm_top.sm_cpu.instr_E); $write (" ");
        disasmInstr(sm_top.sm_cpu.instr_M); $write (" ");
        disasmInstr(sm_top.sm_cpu.instr_W);
    `else
        $write ("%5d  pc = %h  instr = %h   v0 = %1d", 
                  cycle, regData, sm_top.sm_cpu.instr, sm_top.sm_cpu.rf.rf[2]);
        disasmInstr(sm_top.sm_cpu.instr);
    `endif

        $write("\n");

        cycle = cycle + 1;

        if (cycle > `SIMULATION_CYCLES)
        begin
            $display ("Timeout");
            $stop;
        end
    end

endmodule
