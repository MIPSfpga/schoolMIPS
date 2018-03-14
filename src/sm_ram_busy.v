

module sm_ram_busy
#(
    parameter SIZE = 64, // memory size, in words
    parameter DELAY = 7  // busy delay, from 2 to 255
)
(
    input             clk,
    input             rst_n,
    input      [31:0] a,        // address
    input             we,       // write enable
    input      [31:0] wd,       // write data
    input             valid,    // read/write request
    output reg        ready,    // read/write done
    output     [31:0] rd        // read data
);
    // FSM States
    localparam  S_IDLE  = 2'h0, // waiting for request
                S_BUSY  = 2'h1, // waiting for data, not ready
                S_READY = 2'h2; // data ready

    // FSM State vars
    wire [1:0] state;
    reg  [1:0] state_next;
    sm_register_c #(2) r_state (clk, rst_n, state_next, state);

    wire [7:0] delay;
    wire [7:0] delay_next;
    sm_register #(8) r_delay (clk, delay_next, delay);

    // Next State value
    wire delay_finished = (delay == DELAY-2);
    assign delay_next = (state == S_BUSY) ? delay + 1 : 0;

    always @(*) begin
        state_next = state;
        case(state)
            S_IDLE  : state_next = valid ? S_BUSY : S_IDLE;
            S_BUSY  : state_next = delay_finished ? S_READY : S_BUSY;
            S_READY : state_next = S_IDLE;
        endcase
    end

    // FSM Output
    always @(*) begin
        ready = 1'b0;
        case(state)
            S_IDLE  : ready = ~valid;
            S_BUSY  : ready = 1'b0;
            S_READY : ready = 1'b1;
        endcase
    end

    // Input data buffer
    wire        ibuf_we = (state_next == S_BUSY);
    wire [31:0] ram_a;
    wire [31:0] ram_wd;
    wire        ram_we;
    sm_register_we #(32) r_ram_a  (clk, rst_n, ibuf_we, a,  ram_a );
    sm_register_we #(32) r_ram_wd (clk, rst_n, ibuf_we, wd, ram_wd);
    sm_register_we       r_ram_we (clk, rst_n, ibuf_we, we, ram_we);

    // Requested Memory
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
