

module sm_register
#(
    parameter WIDTH = 32,
    parameter RESET = { WIDTH { 1'b0 } }
)
(
    input                        clk,
    input                        rst,
    input      [ WIDTH - 1 : 0 ] d,
    output reg [ WIDTH - 1 : 0 ] q
);
    always @ (posedge clk or negedge rst)
        if(~rst)
            q <= RESET;
        else
            q <= d;
endmodule


module sm_register_we
#(
    parameter WIDTH = 32,
    parameter RESET = { WIDTH { 1'b0 } }
)
(
    input                        clk,
    input                        rst,
    input                        we,
    input      [ WIDTH - 1 : 0 ] d,
    output reg [ WIDTH - 1 : 0 ] q
);
    always @ (posedge clk or negedge rst)
        if(~rst)
            q <= RESET;
        else
            if(we) q <= d;
endmodule
