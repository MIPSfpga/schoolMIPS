
module sm_register
#(
    parameter WIDTH = 1
)
(
    input                        clk,
    input      [ WIDTH - 1 : 0 ] d,
    output reg [ WIDTH - 1 : 0 ] q
);
    always @ (posedge clk)
        q <= d;
endmodule


module sm_register_c
#(
    parameter WIDTH = 1
)
(
    input                        clk,
    input                        rst,
    input      [ WIDTH - 1 : 0 ] d,
    output reg [ WIDTH - 1 : 0 ] q
);
    localparam RESET = { WIDTH { 1'b0 } };

    always @ (posedge clk or negedge rst)
        if(~rst)
            q <= RESET;
        else
            q <= d;
endmodule


module sm_register_we
#(
    parameter WIDTH = 1
)
(
    input                        clk,
    input                        rst,
    input                        we,
    input      [ WIDTH - 1 : 0 ] d,
    output reg [ WIDTH - 1 : 0 ] q
);
    localparam RESET = { WIDTH { 1'b0 } };
    
    always @ (posedge clk or negedge rst)
        if(~rst)
            q <= RESET;
        else
            if(we) q <= d;
endmodule
