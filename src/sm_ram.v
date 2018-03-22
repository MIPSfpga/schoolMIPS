

module sm_ram
#(
    parameter SIZE = 64
)
(
    input         clk,
    input  [31:0] a,
    input         we,
    input  [31:0] wd,
    output [31:0] rd
);
    //TODO: fix width

    reg [31:0] ram [SIZE - 1:0];
    //assign rd = ram [a[31:2]];
    assign rd = ram [a[7:2]];

    always @(posedge clk)
        if (we)
            //ram[a[31:2]] <= wd;
            ram[a[7:2]] <= wd;

endmodule
