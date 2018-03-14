

//TODO: 
// - add irq & memory access test programm

module sm_ram_busy
#(
    parameter SIZE = 64, // memory size, in words
    parameter DELAY = 2  // busy delay, from 2 to 255
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
    sm_delay #(DELAY) dly 
    (
        .clk   ( clk     ),
        .rst_n ( rst_n   ),
        .valid ( valid   ),
        .ready ( ready   ),
        .start ( ibuf_we )
    );

    // Requested Memory
    wire [31:0] ram_rd;
    sm_ram #(SIZE) ram
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
        assign rd = ram_rd
    `endif

endmodule

module sm_delay
#(
    parameter DELAY = 2
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

    assign ready = delay_min | delay_max;
    assign start = delay_min & valid;

endmodule

// Memory wout delay
module sm_ram_fast
#(
    parameter SIZE = 64,
    parameter DELAY = 2
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
    sm_ram #(SIZE) ram
    (
        .clk ( clk  ),
        .a   ( a    ),
        .we  ( we   ),
        .wd  ( wd   ),
        .rd  ( rd   )
    );
    assign ready = 1'b1;

endmodule
