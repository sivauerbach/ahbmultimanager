module ahbmmgr #(parameter MANAGERS = 4) (
  ahb AHB,
  ahb.subordinate managers[MANAGERS-1:0],
  ahb.manager mainbus,
  output logic [MANAGERS-1:0] granted,
  output logic [MANAGERS-1:0] grantedD
);	
	
   
   logic [MANAGERS-1:0] onehotvector;
   logic [MANAGERS-1:0] grantedID;
   logic [MANAGERS-1:0] desination;
   logic arb_enable;

   arbiter Arbiter (arb_enable, onehotvector, grantedID);
   addressdecoder decoder[MANAGERS-1:0] (
    .clk ( AHB.HCLK ),
    .address ( ahb.managers[i].HADDR,
    .destination (destination[i])   
   );


   logic clk;
   logic [WIDTH-1:0] a_i;
   logic [WIDTH-1:0] b_i;
   module_name instance_name[WIDTH-1:0] (
    .clk ( clk ), //Single bit is replicated across instance array
    .a   ( a_i ), //connected wire a_i is wider than port so split across instances
    .b   ( b_i )
   );
 
   genvar i;
   generate
   for (i = 0; i < MANAGERS; i++) begin:saveregs
         
     address decoder add_decoder[MANAGERS-1:0] (
      .clk ( ahb.HCLK ),
      .address ( ahb.managers[i].HADDR,
      .destination (destination[i])   
     );

   end
  endgenerate



















endmodule
