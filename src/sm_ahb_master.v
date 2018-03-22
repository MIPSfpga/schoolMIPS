
`include "ahb_lite.vh"

module sm_ahb_master
(
    input             clk,
    input             rst_n,

    input      [31:0] a,        // address
    input             we,       // write enable
    input      [31:0] wd,       // write data
    input             valid,    // read/write request
    input             sel,      // select by address selector
    output            ready,    // read/write done
    output     [31:0] rd,       // read data

    output            HCLK,
    output            HRESETn,
    output            HWRITE,
    output     [ 1:0] HTRANS,
    output     [31:0] HADDR,
    input      [31:0] HRDATA,
    output     [31:0] HWDATA,
    input             HREADY,
    input             HRESP          
);
    assign HCLK     = clk;
    assign HRESETn  = rst_n;
    assign HWRITE   = we;
    assign HTRANS   = valid ? `HTRANS_NONSEQ : `HTRANS_IDLE; //AHB single transfer only
    assign HADDR    = a;

    assign ready    = HREADY & ~HRESP; // AHB Ready and NoError
    assign rd       = HRDATA;

    sm_register_we #(32) r_hwdata (clk, rst_n, valid, wd, HWDATA);
endmodule
