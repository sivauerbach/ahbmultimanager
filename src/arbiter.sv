module arbiter #(parameter MANAGERS = 4) (
  ahb.subordinate managers[MANAGERS-1:0],
  ahb.manager mainbus,
  output logic [MANAGERS-1:0] granted,
  output logic [MANAGERS-1:0] grantedD
);

  
  
endmodule
