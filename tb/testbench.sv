`timescale 10ns/1ns
module testbench;
   localparam MANAGERS = 4;
   logic [MANAGERS-1:0] granted;
   logic [MANAGERS-1:0] grantedD;
   
   logic clk;

   ahb ahb_managers [MANAGERS-1:0] (clk);
   ahb mainbus (clk);
   
   arbiter #(MANAGERS) dut(ahb_managers, mainbus, granted, grantedD);
   
   initial begin
      clk = 1'b1;
      forever #5 clk = ~clk;
   end
   
   initial begin
      #100 $stop;
   end
   
endmodule
