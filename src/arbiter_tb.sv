// xz.sv
// David_Harris@hmc.edu 30 January 2022
// Demonstrate impact of x and z.

// load with vsim xz.sv

module testbench #(parameter MANAGERS = 4) ();
  logic [MANAGERS-1:0] requestV, grantedV, grantedD;
  logic       clk;

  arbiter dut(clk, requestV, grantedD);

  initial begin
      requestV = 0000;
      #13;  // y should be floating
      requestV = 1110;
      #13;  // y should be floating
      requestV = 0001;
      #13;  // y should be floating
      requestV = 0011;
      #13;  // y should be floating
      requestV = 1011;
      #13;  // y should be floating
      
  end

    always begin
        #10 clk = ~clk;
    end

endmodule