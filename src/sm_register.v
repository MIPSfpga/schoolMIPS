
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
    input                        rst_n,
    input      [ WIDTH - 1 : 0 ] d,
    output reg [ WIDTH - 1 : 0 ] q
);
    localparam RESET = { WIDTH { 1'b0 } };

    always @ (posedge clk or negedge rst_n)
        if(~rst_n)
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
    input                        rst_n,
    input                        we,
    input      [ WIDTH - 1 : 0 ] d,
    output reg [ WIDTH - 1 : 0 ] q
);
    localparam RESET = { WIDTH { 1'b0 } };
    
    always @ (posedge clk or negedge rst_n)
        if(~rst_n)
            q <= RESET;
        else
            if(we) q <= d;
endmodule

module sm_register_cs
#(
    parameter WIDTH = 1
)
(
    input                        clk,
    input                        rst_n,
    input                        clr_n,
    input      [ WIDTH - 1 : 0 ] d,
    output     [ WIDTH - 1 : 0 ] q
);
    localparam RESET = { WIDTH { 1'b0 } };
    wire [ WIDTH - 1 : 0 ] dc = ~clr_n ? RESET : d;

    sm_register_c #(WIDTH) r_cs (clk, rst_n, dc, q);

endmodule

module sm_register_wes
#(
    parameter WIDTH = 1
)
(
    input                        clk,
    input                        rst_n,
    input                        clr_n,
    input                        we,
    input      [ WIDTH - 1 : 0 ] d,
    output     [ WIDTH - 1 : 0 ] q
);
    localparam RESET = { WIDTH { 1'b0 } };
    wire [ WIDTH - 1 : 0 ] dc = ~clr_n ? RESET : d;

    sm_register_we #(WIDTH) r_cs (clk, rst_n, we, dc, q);

endmodule
