
// external devices
module ahb_matrix
(
    input            HCLK,
    input            HRESETn,
    input            HWRITE,
    input     [ 1:0] HTRANS,
    input     [31:0] HADDR,
    output    [31:0] HRDATA,
    input     [31:0] HWDATA,
    output           HREADY,
    output           HRESP       
);
    //TODO: add another devices and bus logic

    //RAM
    ahb_ram ahb_ram
    (
        .HCLK      ( HCLK    ),
        .HRESETn   ( HRESETn ),
        .HSEL      ( 1'b1    ),
        .HWRITE    ( HWRITE  ),
        .HREADY    ( HREADY  ),
        .HTRANS    ( HTRANS  ),
        .HADDR     ( HADDR   ),
        .HRDATA    ( HRDATA  ),
        .HWDATA    ( HWDATA  ),
        .HREADYOUT ( HREADY  ),
        .HRESP     ( HRESP   ) 
    );

endmodule
