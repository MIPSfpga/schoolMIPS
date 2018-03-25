/*
 * schoolMIPS - small MIPS CPU for "Young Russian Chip Architects" 
 *              summer school ( yrca@googlegroups.com )
 *
 * RAM with ready delay
 * 
 * Copyright(c) 2017-2018 Stanislav Zhelnio
 */ 

`include "sm_settings.vh"

//TODO: 
// - add irq & memory access test programm

module sm_ram_busy
#(
    parameter WIDTH = 6 // memory internal bus width (determines RAM size)
)
(
    input             clk,
    input             rst_n,
    input      [31:0] a,        // address
    input             we,       // write enable
    input      [31:0] wd,       // write data
    input             valid,    // read/write request
    output            ready,    // read/write done
    output     [31:0] rd        // read data
);
    // Input data buffer
    wire        ibuf_we;
    wire [31:0] ram_a;
    wire [31:0] ram_wd;
    wire        ram_we;
    sm_register_we #(32) r_ram_a  (clk, rst_n, ibuf_we, a,  ram_a );
    sm_register_we #(32) r_ram_wd (clk, rst_n, ibuf_we, wd, ram_wd);
    sm_register_we       r_ram_we (clk, rst_n, ibuf_we, we, ram_we);

    // Valid to Ready delay 
    sm_delay #(`SM_CONFIG_BUSY_RAM_DELAY) dly 
    (
        .clk   ( clk     ),
        .rst_n ( rst_n   ),
        .valid ( valid   ),
        .ready ( ready   ),
        .start ( ibuf_we )
    );

    // Requested Memory
    wire [31:0] ram_rd;
    sm_ram #(WIDTH) ram
    (
        .clk   ( clk     ),
        .a     ( ram_a   ),
        .we    ( ram_we  ),
        .wd    ( ram_wd  ),
        .rd    ( ram_rd  )
    );

    `ifdef SIMULATION
        assign rd = ready & ~ram_we ? ram_rd : 32'bx;
    `else
        assign rd = ram_rd;
    `endif

endmodule

module sm_delay
#(
    parameter DELAY = 2 // busy delay, from 0 to 255
)
(
    input       clk,
    input       rst_n,
    input       valid,  // read/write request
    output      ready,  // read/write done
    output      start   // work started strobe
);
    localparam EFFECTIVE_DELAY = (DELAY > 255) ? 255 : DELAY;

    wire [7:0] delay;
    wire delay_min = (delay == 0);
    wire delay_max = (delay == EFFECTIVE_DELAY);

    wire [7:0] delay_next = delay_max ? 0 : 
                            delay_min & ~valid ? 0 :
                            delay + 1;

    sm_register_c #(8)  r_delay (clk, rst_n, delay_next, delay);

    assign ready = delay_min;
    assign start = delay_min & valid;

endmodule

// Memory with output buffer
module sm_ram_outbuf
#(
    parameter WIDTH = 6 // memory internal bus width (determines RAM size)
)
(
    input         clk,
    input         rst_n,
    input  [31:0] a,        // address
    input         we,       // write enable
    input  [31:0] wd,       // write data
    input         valid,    // read/write request
    output        ready,    // read/write done
    output [31:0] rd        // read data
);
    wire [31:0] ram_rd;

    sm_ram #(WIDTH) ram
    (
        .clk ( clk    ),
        .a   ( a      ),
        .we  ( we     ),
        .wd  ( wd     ),
        .rd  ( ram_rd )
    );
    assign ready = 1'b1;

    sm_register_we #(32) r_ram_rd (clk, rst_n, valid, ram_rd, rd);

endmodule
