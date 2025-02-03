module arbiter #(parameter CHANNELS = 4) (
  AHB.subordinate managers[CHANNELS-1:0],
  AHB.manager mainbus,
  output logic [CHANNELS-1:0] granted,
  output logic [CHANNELS-1:0] grantedD
);

  
  
endmodule
