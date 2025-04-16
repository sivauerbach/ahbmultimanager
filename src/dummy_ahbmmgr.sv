module dummy_ahbmmgr #(parameter MANAGERS = 4) (
  input logic HCLK,
  input logic HRESETn,
  ahb.subordinate managers[MANAGERS-1:0],
  ahb.manager mainbus
  // output logic [MANAGERS-1:0] granted,
  // output logic [MANAGERS-1:0] grantedD // Maybe not needed?
);	
	
  //AHB.subordinate managerSaveRegister; // CHECK
  // logic [MANAGERS-1:0] requestV;
  // logic [MANAGERS-1:0] grantedV;
  // logic arb_enable;

  logic [$clog2(MANAGERS)-1:0] grantedID;

  //arbiter #(MANAGERS) arb (arb_enable, requestV, grantedV);
  //onehotdecoder #(MANAGERS) decoder(grantedV, grantedID);

  // Use a seperate module? connectmodports (managers[grantedID], mainbus);

  // TODO: write logic that changes arb_enable to select new manager

    assign grantedID = 0;

  //Create onehot vector from managers' requests
  // for (genvar i = 0; i < MANAGERS; i++) begin 
  //     always_comb begin : assignrequestV
  //       requestV[i] = ~(managers[i].HTRANS == 2'b00); // requestV[i] is HIGH if managers[i].TRANS != IDLE
  //     end
  // end

  // for RESETn signal, send IDLE to mainbus
  always_ff @(posedge HCLK or negedge HRESETn) begin 
    if (!HRESETn) begin
      mainbus.HTRANS <= 2'b00;      // indicate IDLE transmition state to subordinates
    end
  end

  // on clk: forward signals from granted master to mainbus and
  // forward signals from mainbus to the selected manager. Set HREADY=LOW to all others
  for (genvar index = 0; index < MANAGERS; index++) begin
    always_ff @(posedge HCLK or negedge HRESETn) begin
      if (!HRESETn) 
        managers[index].HREADY <= 1'b1;
      else begin
        managers[index].HREADY <=  mainbus.HREADY;
        // managers[index].HREADY <= (index==grantedID) ? mainbus.HREADY: 1'b0;
        managers[index].HRESP <= (index==grantedID) ? mainbus.HRESP: 'b0;
        managers[index].HRDATA <= (index==grantedID) ? mainbus.HRDATA: 'b0;

        if (index == grantedID) begin
          mainbus.HADDR <= managers[index].HADDR;
          mainbus.HWDATA <= managers[index].HWDATA;  
          mainbus.HWRITE <= managers[index].HWRITE;
          mainbus.HSIZE <= managers[index].HSIZE;
          mainbus.HTRANS <= managers[index].HTRANS;
          mainbus.HBURST <= managers[index].HBURST;
          //mainbus.HPROT <= managers[index].HPROT;
          //mainbus.HMASTLOCK <= managers[index].HMASTLOCK;
        end    
      end
    end
  end


  // always_ff @(posedge AHB.HCLK or negedge AHB.HRESETn) begin
  //   if (!AHB.HRESETn) begin
  //     mainbus.HTRANS <= 2'b00;      // indicate IDLE transmition state to subordinates
  //     for (int i = 0; i < MANAGERS; i++) begin
  //       managers[i].HREADY <= 1'b1; // set HREADY signals to managers as HIGH
  //       end
  //     end

  //   else begin   
      
  //       for (int j = 0; j < MANAGERS; j++) begin:saveregs
  //         managers[j].HREADY <= (j==grantedID) ? mainbus.HREADY: 1'b0;
  //         managers[j].HRESP <= (j==grantedID) ? mainbus.HRESP: 'b0;
  //         managers[j].HRDATA <= (j==grantedID) ? mainbus.HRDATA: 'b0;
  //       end
      

  //   end
  // end



















endmodule
