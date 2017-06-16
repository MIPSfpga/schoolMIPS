
`timescale 1 ns / 100 ps

module sm_testbench;

    // simulation options
    parameter Tt     = 20;
    parameter Ncycle = 40;

    reg clk;
    reg rst_n;

    // ***** DUT start ************************

    sm_cpu sm_cpu
    (
        .clk    ( clk   ),
        .rst_n  ( rst_n )
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

    //rom & ram init
    reg [7:0] rom [0 : 255];
    integer i;

    initial begin
        //program memory init
        $readmemh ("program.hex", rom);
        for (i = 0; i < 256; i = i + 4)
            sm_cpu.rom [i / 4] = { rom [i + 3], rom [i + 2], 
                                   rom [i + 1], rom [i + 0] };

        //register file reset
        for (i = 0; i < 32; i = i + 1)
            sm_cpu.rf.rf[i] = 0;
    end

    //simulation debug output
    integer cycle; initial cycle = 0;

    always @ (posedge clk)
    begin
        $display ("%5d v0= %d", cycle, sm_cpu.rf.rf[2]);

        cycle = cycle + 1;

        if (cycle > Ncycle)
        begin
            $display ("Timeout");
            $finish;
        end
    end

endmodule
