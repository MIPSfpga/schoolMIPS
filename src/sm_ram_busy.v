

module sm_ram_busy
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
    wire [31:0] ram_a;
    wire [31:0] ram_wd;
    wire        ram_we;
    wire ram_a_we  = ready & valid;
    wire ram_wd_we = ready & valid & we;

    sm_register_we #(32) r_ram_a  (clk, rst_n, ram_a_we,  a,  ram_a );
    sm_register_we #(32) r_ram_wd (clk, rst_n, ram_wd_we, wd, ram_wd);
    sm_register_we       r_ram_we (clk, rst_n, ram_a_we,  we, ram_we);

    wire [ 7:0] delay;
    wire [ 7:0] delay_next = ready ? delay : delay + 1;
    sm_register_cs #(8)  r_delay (clk, rst_n, ~ram_a_we, delay_next, delay);

    assign ready = delay[DELAY];

    sm_ram #(SIZE) ram
    (
        .clk ( clk    ),
        .a   ( ram_a  ),
        .we  ( ram_we ),
        .wd  ( ram_wd ),
        .rd  ( rd     )
    );

endmodule


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
