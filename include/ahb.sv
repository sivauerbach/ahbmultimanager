interface ahb #(
  parameter WIDTH = 32,
  parameter PA_BITS = 52,
  parameter AHBW=32
)(
  input logic HCLK
);
   
   logic               HRESETn;

   // HREADY = Advance the bus
   logic               HREADY;
   logic               HRESP;

   // Address and Data stuff
   logic [PA_BITS-1:0] HADDR;
   logic [AHBW-1:0]    HRDATA;
   logic [WIDTH-1:0]   HWDATA;

   // State stuff
   logic               HWRITE;
   logic [WIDTH/8-1:0] HWSTRB;
   logic [2:0]         HSIZE;
   logic [2:0]         HBURST;
   logic [3:0]         HPROT;
   logic [1:0]         HTRANS;
   logic               HMASTLOCK;

   // Sending the bus signals
   modport manager (HCLK, input HREADY, HRESP,
                    output HADDR, HWDATA, HWSTRB, HWRITE, HSIZE, HBURST,
                    output HPROT, HTRANS, HMASTLOCK);

   // Receiving the bus signals
   modport subordinate (HCLK, output HREADY, HRESP,
                        input HADDR, HWDATA, HWSTRB, HWRITE, HSIZE, HBURST,
                        input HPROT, HTRANS, HMASTLOCK);

endinterface
