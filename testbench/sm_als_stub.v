


module sm_als_stub
#(
    parameter value = 8'hAB
)
(
    input             cs,
    input             sck,
    output reg        sdo
);
    wire [7:0]  tvalue  = value;
    wire [15:0] tpacket = { 4'b0, tvalue, 4'b0 };

    reg  [15:0] buffer;

    always @(negedge sck) begin
        if(!cs)
            { sdo, buffer } <= { buffer, 1'b0 };
        else
            buffer <= tpacket;
    end

endmodule
