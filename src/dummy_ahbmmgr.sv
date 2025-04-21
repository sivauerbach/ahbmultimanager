module dummy_ahbmmgr #(parameter MANAGERS = 4) (
  input logic HCLK,
  input logic HRESETn,
  ahb.subordinate managers[MANAGERS-1:0],
  ahb.manager mainbus
);	
	// General parameters
  localparam ADDR_WIDTH = $bits(mainbus.HADDR);
  localparam DATA_WIDTH = $bits(mainbus.HRDATA);
  localparam CABLE = 1'b0, REGISTER = 1'b1;

  logic [MANAGERS-1:0] connectTo;

  // FSM variables and parameters
  typedef enum {s_IDLE, s_STORED, s_GRANTED} states_enum ;
  states_enum  state [MANAGERS-1:0], next_state[MANAGERS-1:0];
  localparam IDLE = 2'b00;
  localparam BUSY = 2'b01;
  localparam NONSEQ = 2'b10;
  localparam SEQ = 2'b11;

  localparam HRESP_OKAY = 1'b0;
  localparam HRESP_ERROR = 2'b01;




  // Arbiter enable, input and outputs
  logic arb_enable;
  logic [MANAGERS-1:0] requestV, grantedV;
  logic [$clog2(MANAGERS)-1:0] grantedID, prevgrantID;

  // Instantiate save register for each manager cable
  ahb #(ADDR_WIDTH, DATA_WIDTH) regs [MANAGERS-1:0] (HCLK ,HRESETn);

  arbiter #(MANAGERS) arb (arb_enable, requestV, grantedV);
  onehotdecoder #(MANAGERS) decoder(grantedV, grantedID);
  always_ff @ (posedge HCLK) prevgrantID <= grantedID;

  //Create onehot vector from managers' requests
  for (genvar i = 0; i < MANAGERS; i++) begin 
      always_comb begin : assignrequestV
        requestV[i] = (managers[i].HTRANS == NONSEQ); // requestV[i] is HIGH if managers[i].TRANS != IDLE
      end

    //save registers flip flop
    always_ff @(posedge HCLK or negedge HRESETn) begin
      regs[i].HADDR <= managers[i].HADDR;
      regs[i].HWDATA <= managers[i].HWDATA;
      regs[i].HWRITE <= managers[i].HWRITE;
      regs[i].HSIZE <=  managers[i].HSIZE;
      regs[i].HTRANS <=  managers[i].HTRANS;
      regs[i].HBURST <=  managers[i].HBURST;
      // regs[i].HPROT <=  managers[i].HPROT;
      // regs[i].HMASTLOCK <=  managers[i].HMASTLOCK;
    end
  end

  // for RESETn signal, send IDLE to mainbus
  // always_ff @(posedge HCLK or negedge HRESETn) begin 
  //   if (!HRESETn) begin
  //     mainbus.HTRANS <= 2'b00;      // indicate IDLE transmition state to subordinates
  //   end
    
  // end

  // forward signals from mainbus to the previosly granted manager. Set signals to default for the non-granted managers.
  for (genvar i = 0; i < MANAGERS; i++) begin
    always_comb begin
      if (!HRESETn) 
        managers[i].HREADY = 1'b1;
      else begin
        managers[i].HREADY = (i==prevgrantID) ? mainbus.HREADY : ~(requestV[i]); // Default: Low for stored requests, High for not stored requests.
        managers[i].HRESP = (i==prevgrantID) ? mainbus.HRESP : HRESP_OKAY; // Default: HRESP=OKAY
        managers[i].HRDATA = (i==prevgrantID) ? mainbus.HRDATA : managers[i].HRDATA;
        end    
      end
    end

  // // forward signals from current granted master to mainbus
  // for (genvar i = 0; i < MANAGERS; i++) begin
  //   always @(*) begin
  //       if (i == grantedID) begin
  //         case (connectTo[i]) 
  //         REGISTER: begin
  //           mainbus.HADDR <= regs[i].HADDR;
  //           mainbus.HWDATA <= regs[i].HWDATA;  
  //           mainbus.HWRITE <= regs[i].HWRITE;
  //           mainbus.HSIZE <= regs[i].HSIZE;
  //           mainbus.HTRANS <= regs[i].HTRANS;
  //           mainbus.HBURST <= regs[i].HBURST;
  //           //mainbus.HPROT <= regs[i].HPROT;
  //           //mainbus.HMASTLOCK <= regs[i].HMASTLOCK;
          
  //         end
  //         CABLE: begin
  //           mainbus.HADDR <= managers[i].HADDR;
  //           mainbus.HWDATA <= managers[i].HWDATA;  
  //           mainbus.HWRITE <= managers[i].HWRITE;
  //           mainbus.HSIZE <= managers[i].HSIZE;
  //           mainbus.HTRANS <= managers[i].HTRANS;
  //           mainbus.HBURST <= managers[i].HBURST;
  //           //mainbus.HPROT <= managers[i].HPROT;
  //           //mainbus.HMASTLOCK <= managers[i].HMASTLOCK;
  //         end
  //       endcase
  //       end    
  //     end
  //   end
  
  // forward signals from current granted master to mainbus
    // mainbus.HWDATA = 'z;  
    // mainbus.HWRITE = 'z; 
    // mainbus.HSIZE = 'z;
    // mainbus.HTRANS = 'z;
    // mainbus.HBURST = 'z;
    // if (!HRESETn) mainbus.HTRANS <= 2'b00;      // indicate IDLE transmition state to subordinates
    // else begin 
    for (genvar i = 0; i < MANAGERS; i++) begin
        always @(*) begin
        if (i == grantedID) begin
          mainbus.HADDR = (connectTo[i] == REGISTER) ? regs[i].HADDR : managers[i].HADDR;
          mainbus.HWDATA = (connectTo[i] == REGISTER) ? regs[i].HWDATA : managers[i].HWDATA;
          mainbus.HWRITE = (connectTo[i] == REGISTER) ? regs[i].HWRITE : managers[i].HWRITE;
          mainbus.HSIZE = (connectTo[i] == REGISTER) ? regs[i].HSIZE : managers[i].HSIZE;
          mainbus.HTRANS = (connectTo[i] == REGISTER) ? regs[i].HTRANS : managers[i].HTRANS;
          mainbus.HBURST = (connectTo[i] == REGISTER) ? regs[i].HBURST : managers[i].HBURST;
          // mainbus.HPROT = (connectTo[i] == REGISTER) ? regs[i].HPROT : managers[i].HPROT;
          // mainbus.HMASTLOCK = (connectTo[i] == REGISTER) ? regs[i].HMASTLOCK : managers[i].HMASTLOCK;
        end
        end    
      end
    // end


// always_comb 
// begin
//    o_data = 'z;
//    for(int i = 0; i < X; i++) begin
//       if (onehot == (1 << i))
//          o_data = i_data[i];
//    end
// end




initial arb_enable = 0;

for (genvar i = 0; i < MANAGERS; i++) begin
 
  // always_ff @ (posedge HCLK) begin
  always @ (posedge HCLK) begin
    if ((state[i]== s_GRANTED ) && (next_state[i] !=s_GRANTED)) arb_enable <= ~arb_enable;
    state[i] <= next_state[i];
  end
  
  // next state logic
  always @(*) begin 
  // always_comb begin 
    // arb_enable = 0;
    next_state[i] = s_IDLE;
    case (state[i])
      s_IDLE: begin
        // arb_enable = 1;
        // if (i == grantedID) arb_enable = HCLK;
        if ((managers[i].HTRANS == NONSEQ) && (i==grantedID)) begin 
          connectTo[i] = CABLE;
          next_state[i] = s_GRANTED;
        end
        else if ((managers[i].HTRANS == NONSEQ) && (i !=grantedID)) next_state[i] = s_STORED;
        else next_state[i] = s_IDLE;
      end
      s_STORED: begin 
        // arb_enable=1;
        connectTo[i] = REGISTER;
        if ((regs[i].HTRANS == NONSEQ) && (i ==grantedID)) next_state[i] = s_GRANTED;
        else if (regs[i].HTRANS == IDLE) next_state[i] = s_IDLE;
        else next_state[i] = s_STORED;
      end

      s_GRANTED: begin 
          // arb_enable =0;
          if ((managers[i].HTRANS == NONSEQ) && (mainbus.HREADY == 0)) begin 
          next_state[i] = s_STORED;
          // arb_enable = ~arb_enable;
        end
        else if (managers[i].HTRANS == IDLE) begin 
          next_state[i] = s_IDLE;
          // arb_enable = ~arb_enable;
        end else next_state[i] = s_GRANTED;
      end
    endcase
  end

  end



















endmodule
