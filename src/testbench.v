
`timescale 1 ns / 100 ps

module sm_testbench;

    // simulation options
    parameter Tt     = 20;
    parameter Ncycle = 200;

    reg clk;
    reg rst_n;

    // DUT
    sm_cpu sm_cpu
    (
        .clk    ( clk   ),
        .rst_n  ( rst_n )
    );

    // simulation init
    initial begin
        clk = 0;
        forever clk = #(Tt/2) ~clk;
    end

    initial
    begin
        rst_n   <= 0;
        repeat (4)  @(posedge clk);
        rst_n   <= 1;

        repeat (Ncycle)  @(posedge clk);
        $display ("Timeout");
        $finish;
    end

endmodule
