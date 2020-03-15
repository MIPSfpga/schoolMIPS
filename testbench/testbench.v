`timescale 1 ns / 100 ps

`ifndef SIMULATION_CYCLES
    `define SIMULATION_CYCLES 120
`endif

module sm_testbench;

    // simulation options
    parameter Tt     = 20;

    reg         clk;
    reg         rst_n;
    reg  [ 4:0] regAddr;
    wire [31:0] regData;
    wire        cpuClk;

    wire [sm_config::GPIO_WIDTH - 1:0] gpioInput; // GPIO output pins
    wire [sm_config::GPIO_WIDTH - 1:0] gpioOutput; // GPIO intput pins
    wire                        pwmOutput;  // PWM output pin
    wire                        alsCS;      // Ligth Sensor chip select
    wire                        alsSCK;     // Light Sensor SPI clock
    wire                        alsSDO;     // Light Sensor SPI data

    assign gpioInput = 16'h0A;

    // ***** DUT start ************************

    sm_top sm_top
    (
        .clkIn     ( clk     ),
        .rst_n     ( rst_n   ),
        .clkDevide ( 4'b0    ),
        .clkEnable ( 1'b1    ),
        .clk       ( cpuClk  ),
        .regAddr   ( regAddr ),
        .regData   ( regData ),

        .gpioInput  ( gpioInput  ),
        .gpioOutput ( gpioOutput ),
        .pwmOutput  ( pwmOutput  ),
        .alsCS      ( alsCS      ),
        .alsSCK     ( alsSCK     ),
        .alsSDO     ( alsSDO     )
    );

    defparam sm_top.sm_clk_divider.bypass = 1;

    // ***** DUT  end  ************************

    // Light Sensor stub
    sm_als_stub sm_als_stub (alsCS, alsSCK, alsSDO);

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

        begin
            import sm_cpu_config::*;

            cmdOper = instr[31:26];
            cmdFunk = instr[ 5:0 ];
            cmdRs   = instr[25:21];
            cmdRt   = instr[20:16];
            cmdRd   = instr[15:11];
            cmdSa   = instr[10:6 ];
            cmdImm  = instr[15:0 ];
            cmdImmS = instr[15:0 ];

            $write("   ");

            casez (Command'({cmdOper,cmdFunk}))
                default               : if (instr == 32'b0) 
                                            $write ("nop");
                                        else
                                            $write ("new/unknown");

                ADDU: $write ("addu  $%1d, $%1d, $%1d", cmdRd, cmdRs, cmdRt);
                OR : $write ("or    $%1d, $%1d, $%1d", cmdRd, cmdRs, cmdRt);
                SRL : $write ("srl   $%1d, $%1d, $%1d", cmdRd, cmdRs, cmdRt);
                SLTU : $write ("sltu  $%1d, $%1d, $%1d", cmdRd, cmdRs, cmdRt);
                SUBU : $write ("subu  $%1d, $%1d, $%1d", cmdRd, cmdRs, cmdRt);

                ADDIU : $write ("addiu $%1d, $%1d, %1d", cmdRt, cmdRs, cmdImm);
                LUI : $write ("lui   $%1d, %1d",       cmdRt, cmdImm);
                LW : $write ("lw    $%1d, %1d($%1d)", cmdRt, cmdImm, cmdRs);
                SW : $write ("sw    $%1d, %1d($%1d)", cmdRt, cmdImm, cmdRs);

                BEQ : $write ("beq   $%1d, $%1d, %1d", cmdRs, cmdRt, cmdImmS + 1);
                BNE : $write ("bne   $%1d, $%1d, %1d", cmdRs, cmdRt, cmdImmS + 1);
            endcase
        end

    endtask


    //simulation debug output
    integer cycle; initial cycle = 0;

    initial regAddr = 0; // get PC

    always @ (posedge clk)
    begin
        $write ("%5d  pc = %2d  pcaddr = %h  instr = %h   v0 = %1d", 
                  cycle, regData, (regData << 2), sm_top.sm_cpu.instr, sm_top.sm_cpu.rf.rf[2]);

        disasmInstr(sm_top.sm_cpu.instr);

        $write("\n");

        cycle = cycle + 1;

        if (cycle > `SIMULATION_CYCLES)
        begin
            $display ("Timeout");
            $stop;
        end
    end

endmodule : sm_testbench
