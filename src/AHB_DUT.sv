module AHB_DUT(i_hclk,i_hreset,
               i_start_0,i_hburst_tb,i_haddr_tb,i_hwrite_tb,i_hsize_tb,i_hwdata_tb,o_hrdata_m,
               o_hready_m);

//Parameters
parameter ADDR_WIDTH=32;                               //Address bus width
parameter DATA_WIDTH=32;                               //Data bus width
parameter MEMORY_DEPTH=512;                            //Slave memory 
parameter SUBORDINATE_COUNT=1;                               //Number of connected AHB slaves
parameter MANAGER_COUNT=4;                               //Number of connected AHB slaves
parameter WAIT_WRITE=0;                                //Number of wait cycles issued by the slave in response to a 'write' transfer
parameter WAIT_READ=0;                                 //Number of wait cycles issued by the slave in response to a 'read' transfer

parameter REGISTER_SELECT_BITS=12;                     //Memory mapping - each slave's internal memory has maximum 2^REGISTER_SELECT_BITS-1 bytes (depends on MEMORY_DEPTH)
parameter SLAVE_SELECT_BITS=20;                        //Memory mapping - width of slave address

//Inputs From Testbench
input logic i_hclk;                                    //All signal timings are related to the rising edge of hclk
input logic i_hreset;                                  //Active low bus reset
input logic i_start_0;                                 //Transfer initiation indicator. If i_start is logic high at a riding edge of hclk, a transfer is issued

input logic [MANAGER_COUNT-1:0][2:0]             i_hburst_tb;                            //Burst type indicates if the transfer is a single transfer of forms a part of a burst. Here, fixed bursts of 4, 8 and 16 are supported for both incrementing/wrapping types.
input logic [MANAGER_COUNT-1:0][ADDR_WIDTH-1:0]  i_haddr_tb;                //Address bus
input logic [MANAGER_COUNT-1:0]                  i_hwrite_tb;                                //Indicates the transfer direction. Logic high values indicates a 'write' and logic low a 'read'
input logic [MANAGER_COUNT-1:0][2:0]             i_hsize_tb;                           //Indicates the size of the transfer, i.e. byte, half word or word 
input logic [MANAGER_COUNT-1:0][DATA_WIDTH-1:0]  i_hwdata_tb;               //Write data bus for 'write' transfers from the master to a slave

//Outpus
output logic [MANAGER_COUNT-1:0][DATA_WIDTH-1:0] o_hrdata_m;             //Data read by master 0 after a 'read' transfer
output logic [MANAGER_COUNT-1:0] o_hready_m;                                 //AHB side ready signal. Declared as output to be used in the various transfer initiation tasks

// MASTER SIGNALS
logic [MANAGER_COUNT-1:0][ADDR_WIDTH-1:0] hadder_m;                       //Master 0
logic [MANAGER_COUNT-1:0]hwrite_m;                                        //Indicates the transfer direction issued by Master 0
logic [MANAGER_COUNT-1:0][2:0] hsize_m;                                   //Indicates the size of the transfer issued by Master 0
logic [MANAGER_COUNT-1:0][1:0] htrans_m;                                  //Indicates the transfer type, i.e. IDLE, BUSY, NONSEQUENTIAL, SEQUENTIAL for Master 0
logic [MANAGER_COUNT-1:0][DATA_WIDTH-1:0] hwdata_m;                       //Write data bus of Master 0
logic [MANAGER_COUNT-1:0][2:0] o_hburst_m;                                //Burst type indicates if the transfer is a single transfer of forms a part of a burst. Here, fixed bursts of 4, 8 and 16 are supported for both incrementing/wrapping types.

logic [MANAGER_COUNT-1:0] hresp_m;                                           //Transfer response, selected by the decoder
logic [MANAGER_COUNT-1:0][DATA_WIDTH-1:0] hrdata_m;                         //Read data bus, selected by the decoder


// SLAVE 0
logic hreadyout_s0;                                     //Slave 0 ready signal
logic hresp_0;                                         //Slave 0 response signal
logic [DATA_WIDTH-1:0] hrdata_0;                       //Read data bus of Slave 0

logic [ADDR_WIDTH-1:0] hadder_s0;                      //slave 0
logic hwrite_s0;                                        //Indicates the transfer direction issued by Master 0
logic [2:0] hsize_s0;                                   //Indicates the size of the transfer issued by Master 0
logic [1:0] htrans_s0;                                  //Indicates the transfer type, i.e. IDLE, BUSY, NONSEQUENTIAL, SEQUENTIAL for Master 0
logic [DATA_WIDTH-1:0] hwdata_s0;                       //Write data bus of Master 0

// logic hreadyout_1;                                     //Slave 1 ready signal
// logic hresp_1;                                         //Slave 1 response signal
// logic [DATA_WIDTH-1:0] hrdata_1;                       //Read data bus of Slave 1

// logic hreadyout_2;                                     //Slave 2 ready signal
// logic hresp_2;                                         //Slave 2 response signal
// logic [DATA_WIDTH-1:0] hrdata_2;                       //Read data bus of Slave 2


logic [SUBORDINATE_COUNT-1:0] hsel = 1'b1;                          //Slave select bus 

//HDL code
//ahb #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) ahb_if (i_hclk, i_hreset);
ahb #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) mast_mmgr [MANAGER_COUNT-1:0] (i_hclk, i_hreset);
ahb #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) mmgr_sub (i_hclk, i_hreset);


// *** Port assignments for Managers <-> AHBmmgr cables
for (genvar i = 0; i < MANAGER_COUNT; i++) begin

  // into manager
  assign o_hready_m[i] = mast_mmgr[i].HREADY;
  assign hresp_m[i] = mast_mmgr[i].HRESP;
  assign hrdata_m[i] = mast_mmgr[i].HRDATA;

  // out of manager
  assign mast_mmgr[i].HADDR = hadder_m[i];
  assign mast_mmgr[i].HWDATA = hwdata_m[i];
  assign mast_mmgr[i].HWRITE = hwrite_m[i];
  assign mast_mmgr[i].HSIZE = hsize_m[i];
  assign mast_mmgr[i].HTRANS = htrans_m[i];
  assign mast_mmgr[i].HBURST = o_hburst_m[i];
  // assign mast_mmgr[i].HPROT = ;
  // assign mast_mmgr[i].HMASTLOCK = ;

end


// *** Port assignments for AHBmmgr <-> Uncore Subordinate cable
// out of subordinate
assign mmgr_sub.HREADY = hreadyout_s0;
assign mmgr_sub.HRESP = hresp_0;
assign mmgr_sub.HRDATA = hrdata_0;

// into subordinate
assign hadder_s0 = mmgr_sub.HADDR;
assign hwdata_s0 = mmgr_sub.HWDATA;
assign hwrite_s0 = mmgr_sub.HWRITE;
assign hsize_s0 = mmgr_sub.HSIZE; 
assign htrans_s0 = mmgr_sub.HTRANS;
// assign i_hburst_s0 = mmgr_sub.HBURST;
// assign mmgr_sub.HPROT = ;
// assign mmgr_sub.HMASTLOCK = ;


dummy_ahbmmgr #(.MANAGERS(MANAGER_COUNT)) my_mmgr ( .HCLK(i_hclk), .HRESETn(i_hreset), .managers(mast_mmgr), .mainbus(mmgr_sub));


//AHB master instantiation
for (genvar i = 0; i < MANAGER_COUNT; i++) begin
  AHB_manager #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) mo(.i_hclk(i_hclk),
                                                                    .i_hreset(i_hreset),
                                                                    .i_start(i_start_0),
                                                                    .i_haddr(i_haddr_tb[i]),
                                                                    .i_hwrite(i_hwrite_tb[i]),
                                                                    .i_hsize(i_hsize_tb[i]),
                                                                    .i_hwdata(i_hwdata_tb[i]),
                                                                    .i_hready(o_hready_m[i]),
                                                                    .i_hresp(hresp_m[i]),
                                                                    .i_hrdata(hrdata_m[i]),
                                                                    .i_hburst(i_hburst_tb[i]),

                                                                    .o_haddr(hadder_m[i]),
                                                                    .o_hwrite(hwrite_m[i]),
                                                                    .o_hsize(hsize_m[i]),
                                                                    .o_htrans(htrans_m[i]),
                                                                    .o_hwdata(hwdata_m[i]),
                                                                    .o_hrdata(o_hrdata_m[i]),
                                                                    .o_hburst(o_hburst_m[i])
  );
end

//AHB slave instantiation
AHB_subordinate #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .MEMORY_DEPTH(MEMORY_DEPTH), .WAIT_WRITE(WAIT_WRITE), .WAIT_READ(WAIT_READ)) so(
                    .i_hclk(i_hclk),
                    .i_hreset(i_hreset),
                    .i_hsel(hsel[0]),
                    .i_haddr(hadder_s0),
                    .i_hwrite(hwrite_s0),
                    .i_hsize(hsize_s0),
                    .i_htrans(htrans_s0),
                    .i_hreadyin(hreadyout_s0), // For one slave: Feed s0 hreadyout back to s0 as i_hreadyin
                    .i_hwdata(hwdata_s0),

                    .o_hreadyout(hreadyout_s0),
                    .o_hresp(hresp_0),
                    .o_hrdata(hrdata_0)
                  );


//AHB interconnect fabric instantiation
// AHB_IF #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .SUBORDINATE_COUNT(SUBORDINATE_COUNT)) f0(.i_hclk(i_hclk),
//                                                                                          .i_hreset(i_hreset),
//                                                                                          .i_haddr(hadder_0),

//                                                                                          .i_hresp_0(hresp_0),
//                                                                                          .i_hrdata_0(hrdata_0),
//                                                                                          .i_hready_0(hreadyout_s0),

//                                                                                         //  .i_hresp_1(hresp_1),
//                                                                                         //  .i_hrdata_1(hrdata_1),
//                                                                                         //  .i_hready_1(hreadyout_1),

//                                                                                         //  .i_hresp_2(hresp_2),
//                                                                                         //  .i_hrdata_2(hrdata_2),
//                                                                                         //  .i_hready_2(hreadyout_2),

//                                                                                           .o_sel(hsel),
//                                                                                         .o_sel(2'b00),                                                                                       
//                                                                                          .o_hrdata(hrdata),
//                                                                                          .o_hresp(hresp),
//                                                                                          .o_hready(o_hready)
// );


endmodule