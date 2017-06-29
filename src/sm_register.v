

module sm_register
(
    input                 clk,
    input                 rst,
    input      [ 31 : 0 ] d,
    output reg [ 31 : 0 ] q
);
    always @ (posedge clk or negedge rst)
        if(~rst)
            q <= 32'b0;
        else
            q <= d;
endmodule


module sm_register_we
(
    input                 clk,
    input                 rst,
    input                 we,
    input      [ 31 : 0 ] d,
    output reg [ 31 : 0 ] q
);
    always @ (posedge clk or negedge rst)
        if(~rst)
            q <= 32'b0;
        else
            if(we) q <= d;
endmodule
