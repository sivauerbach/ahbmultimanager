`timescale 10ns/1ns
module testbench;

  logic clk;
  
  initial begin
    clk = 1'b1;
    forever #5 clk = ~clk;
  end

  initial begin
    #100 $stop;
  end

endmodule
