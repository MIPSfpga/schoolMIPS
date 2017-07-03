
`timescale 1 ns / 100 ps

module sm_testbench;

    // simulation options
    parameter Tt     = 20;
    parameter Ncycle = 120;

    reg         clk;
    reg         rst_n;
    reg  [ 4:0] regAddr;
    wire [31:0] regData;

    // ***** DUT start ************************

    sm_cpu sm_cpu
    (
        .clk     ( clk     ),
        .rst_n   ( rst_n   ),
        .regAddr ( regAddr ),
        .regData ( regData )
    );

    // ***** DUT  end  ************************

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
            sm_cpu.rf.rf[i] = 0;
    end

    //simulation debug output
    integer cycle; initial cycle = 0;

    initial regAddr = 0; // get PC

    always @ (posedge clk)
    begin
        $display ("%5d  pc = %2d  pcaddr= %h  instr = %h   v0 = %1d ", 
                  cycle, regData, (regData << 2), sm_cpu.instr, sm_cpu.rf.rf[2]);

        cycle = cycle + 1;

        if (cycle > Ncycle)
        begin
            $display ("Timeout");
            $stop;
        end
    end

endmodule
