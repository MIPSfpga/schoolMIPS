
module sm_rom
#(
    parameter SIZE = 64
)
(
    input  [31:0] addr,
    output [31:0] data
);
    reg [31:0] rom [SIZE - 1:0];
    assign data = rom [addr];

    initial begin
        $readmemh ("program.hex", rom);
    end

endmodule
