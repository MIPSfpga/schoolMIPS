
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

    //rom init
    reg [7:0] hex [4*SIZE - 1:0];
    integer i;

    initial begin
        $readmemh ("program.hex", hex);
        for (i = 0; i < SIZE; i = i + 4)
            rom [i / 4] = { hex [i + 3], hex [i + 2], 
                            hex [i + 1], hex [i + 0] };
    end

endmodule
