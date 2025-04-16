interface ahb #(
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32) 
  (
  input logic HCLK,
  input logic HRESETn
  );
  
   // HREADY = Advance the bus
   logic               HREADY;
   logic               HRESP;

   // Address and Data stuff
   logic [ADDR_WIDTH-1:0] HADDR;
   logic [DATA_WIDTH-1:0]    HRDATA;
   logic [DATA_WIDTH-1:0]   HWDATA;

   // State stuff
   logic               HWRITE;
   logic [2:0]         HSIZE;
   logic [1:0]         HTRANS;
   logic [2:0]         HBURST;
   logic [3:0]         HPROT;
   logic               HMASTLOCK;
   logic [DATA_WIDTH/8-1:0] HWSTRB;

   // Sending the bus signals
   modport manager (input HCLK, input HRESETn, 
                    input HREADY, HRESP,HRDATA,
                    output HADDR, HWDATA, HWSTRB, HWRITE, HSIZE, HBURST, HPROT, HTRANS, HMASTLOCK);

   // Receiving the bus signals
   modport subordinate (input HCLK, input HRESETn, 
                       output HREADY, HRESP, HRDATA,
                       input  HADDR, HWDATA, HWSTRB, HWRITE, HSIZE, HBURST, HPROT, HTRANS, HMASTLOCK);


endinterface
