`timescale 1ns/100ps
//AHB-lite TB. Please see documentation for further details and examplary results. 

module AHB_TB();

//Parameter declarations
parameter CLK_PERIOD=20;                                         //Clock period
parameter ADDR_WIDTH=32;                                         //Address bus width
parameter DATA_WIDTH=32;                                         //Data bus width
parameter MEMORY_DEPTH=80;                                     //Subordinate memory 
parameter SUBORDINATE_COUNT=1;                                         //Number of connected AHB slaves
parameter MANAGER_COUNT=1;                                         //Number of connected AHB slaves

parameter WAIT_WRITE=1;                                          //Number of wait cycles issued by the subordinate in response to a 'write' transfer
parameter WAIT_READ=2;                                           //Number of wait cycles issued by the subordinate in response to a 'read' transfer

localparam BYTE=3'b000;                                          //Transfer size encodding for 1-byte transfers. Note: 32-bit databus is assumed
localparam HALFWORD=3'b001;                                      //Transfer size encodding for 2-byte transfers, i.e. halfword. Note: 32-bit databus is assumed
localparam WORD=3'b010;                                          //Transfer size encodding for 4-byte transfers, i.e. word. Note: 32-bit databus is assumed

localparam SINGLE=3'b000;                                        //Single burst
localparam WRAP4=3'b010;                                         //4-beat wrapping burst
localparam INCR4=3'b011;                                         //4-beat incrementing burst
localparam WRAP8=3'b100;                                         //8-beat wrapping burst
localparam INCR8=3'b101;                                         //8 beat incrementing burst
localparam WRAP16=3'b110;                                        //16-beat wrapping burst
localparam INCR16=3'b111;                                        //16-beat incrementing burst

localparam REGISTER_SELECT_BITS=12;                              //Memory mapping - each subordinate's internal memory has maximum 2^REGISTER_SELECT_BITS-1 bytes (depends on MEMORY_DEPTH)
localparam SUBORDINATE_SELECT_BITS=20;                                 //Memory mapping - width of subordinate address


// Testing signals
logic test_failed;

//Internal signals declarations
logic clk;                                                       //System's clock
logic rstn;                                                      //Active high logic  
integer SEED=15;                                                  //Used for randomization
logic start_0;                                                    //Read/Write transer is initiated if the 'start' signal is logic high upon positive edge of clk

// input/outputs arrays of 'initiate_transfer task', corresponding to each manager
logic [MANAGER_COUNT-1:0]                  hready_m;                                                    //hready from each manager signal indicates if the manager-mmgr bus is busy
logic [MANAGER_COUNT-1:0]                  rw_m;                                                      //Dictates transfer direction. '1' for Manager-->Subordinate (write) and '0' for Subordinate-->Manager (read)
logic [MANAGER_COUNT-1:0][2:0]             hburst_m;                                            //Burst type
logic [MANAGER_COUNT-1:0][2:0]             hsize_m;                                             //transfer size for Manager_0
logic [MANAGER_COUNT-1:0][ADDR_WIDTH-1:0]  haddr_m;                                //
logic [MANAGER_COUNT-1:0][DATA_WIDTH-1:0]  hwdata_m;                              //Randomized data to be written by a Manager_0 to a Subordinate

// Output of DUT
logic [MANAGER_COUNT-1:0][DATA_WIDTH-1:0] data_out_m;                              //Received data from one of the slaves as sampled by manager #0 following a valid read command

logic [SUBORDINATE_COUNT-1:0][MEMORY_DEPTH-1:0][7:0]mem;               //mimic memory for subordinate 0



//Task declarations 

//Write to mimic memory task: upon invoking this task the relevant data and adress buses are sampled and written into the mimic memory after three 'hready' negative edges.
//This is since the data, address, subordinate number etc. which are generated within the TB are written into the subordinate internal memory with latency due to the pipeline nature of the architecture.
//This task is declared 'automatic' to allow parallel executions in case of consecutive 'write' commands 
task automatic write_to_mimic_task(input logic manager_index, input logic [2:0] hsize, input logic [SUBORDINATE_COUNT-1:0] sub_idx, input logic [ADDR_WIDTH-1:0] addr_rand, input logic [DATA_WIDTH-1:0] data_rand);

  logic [2:0] hsize_s;                                           //Holds the value of hsize upon invocation
  logic [SUBORDINATE_COUNT-1:0] sub_idx_s;                           //Holds the value of sub_idx upon invocation
  logic [ADDR_WIDTH-1:0] addr_rand_s;                            //Holds the value of haddr_m upon invocation
  logic [DATA_WIDTH-1:0] data_rand_s;                            //Holds the value of data_rand upon invocation

  hsize_s=hsize;
  sub_idx_s=sub_idx;
  addr_rand_s=addr_rand;
  data_rand_s=data_rand;

  repeat (3) begin                                               //wait for 3 hclk positive edges where the hready is logic high due to pipeline related latency
    #1
    wait (hready_m[manager_index]==1'b1) 
    #1
    @(posedge clk);
  end
  
  
  case (hsize_s)                                                 //Write the value to the relevant mimic memory
    BYTE : mem[sub_idx_s][addr_rand_s]=data_rand_s[31:24];

    HALFWORD : begin
    mem[sub_idx_s][addr_rand_s]=data_rand_s[31:24];
    mem[sub_idx_s][addr_rand_s+1]=data_rand_s[23:16];
    end

    WORD : begin 
    mem[sub_idx_s][addr_rand_s]=data_rand_s[31:24];
    mem[sub_idx_s][addr_rand_s+1]=data_rand_s[23:16];
    mem[sub_idx_s][addr_rand_s+2]=data_rand_s[15:8];
    mem[sub_idx_s][addr_rand_s+3]=data_rand_s[7:0];
    end
  endcase	
endtask

//compare_task: upon invoking this task, the relevant data, subordinate index and address buses are sampled and after the latency period of 3 hready edges compared with the data obtained by the manager at the end of a 'read' transfer
task automatic compare_task(input logic [2:0] hsize, input logic [MANAGER_COUNT-1:0] manager_idx, input logic [SUBORDINATE_COUNT-1:0] sub_idx, input logic [ADDR_WIDTH-1:0] addr_rand, input logic [4:0] wait_period);
  logic [2:0] hsize_s;                                           //Holds the value of hsize upon invocation
  logic [SUBORDINATE_COUNT-1:0] sub_idx_s;                           //Holds the value of sub_idx upon invocation
  logic [ADDR_WIDTH-1:0] addr_rand_s;                            //Holds the value of haddr_m upon invocation
 
  #1;
  hsize_s=hsize;
  sub_idx_s=sub_idx;
  addr_rand_s=addr_rand;

  repeat (wait_period) begin
    #1
    wait (hready_m[manager_idx]==1'b1) 
    #1
    @(posedge clk);                                              //wait for 3 hclk positive edges where the hready is logic high due to pipeline related latency
  end
  #1;
 
  case (hsize_s)                                                 //Compare the value with the relevant mimic memory
    BYTE: 
    if (mem[sub_idx_s][addr_rand_s]==data_out_m[manager_idx][31:24])
      $display("Data stored in mimic memory number %d in address %d is: %h, Data read from subordinate %d is: %2h - GREAT SUCCESS",sub_idx_s, addr_rand_s, mem[sub_idx_s][addr_rand_s],sub_idx_s, data_out_m[manager_idx][31:24]);
    else begin
      test_failed = 1'b1;
      $display ("Data stored in mimic memory number %d in address %d is: %h, Data read from subordinate %d is: %2h - FAILURE",sub_idx_s, addr_rand_s, mem[sub_idx_s][addr_rand_s],sub_idx_s, data_out_m[manager_idx][31:24]);
      $timeformat(-9,2,"ns");
      $display("Time is %t", $realtime); 
      //$finish;
  end 
	
    HALFWORD :
    if ({mem[sub_idx_s][addr_rand_s],mem[sub_idx_s][addr_rand_s+1]}==data_out_m[manager_idx][31:16]) //TODO: input manager id
      $display("Data stored in mimic memory number %d in address %d is: %4h, Data read from subordinate %d is: %4h - GREAT SUCCESS",sub_idx_s, addr_rand_s, {mem[sub_idx_s][addr_rand_s],mem[sub_idx_s][addr_rand_s+1]},sub_idx_s, data_out_m[manager_idx][31:16]);
    else begin
        test_failed = 1'b1;
      $display("Data stored in mimic memory number %d in address %d is: %4h, Data read from subordinate %d is: %4h - FAILURE",sub_idx_s, addr_rand_s, mem[sub_idx_s][addr_rand_s+:1],sub_idx_s, data_out_m[manager_idx][31:16]);
      $timeformat(-9,2,"ns");
      $display("Time is %t", $realtime);
      //$finish;
    end 

    WORD :
    if ({mem[sub_idx_s][addr_rand_s],mem[sub_idx_s][addr_rand_s+1],mem[sub_idx_s][addr_rand_s+2],mem[sub_idx_s][addr_rand_s+3]}==data_out_m[manager_idx][31:0])
      $display("Data stored in mimic memory number %d in address %d is: %8h, Data read from subordinate %d is: %8h - GREAT SUCCESS", sub_idx_s, addr_rand_s,{mem[sub_idx_s][addr_rand_s],mem[sub_idx_s][addr_rand_s+1],mem[sub_idx_s][addr_rand_s+2],mem[sub_idx_s][addr_rand_s+3]},sub_idx_s,data_out_m);
    else begin
      $display("Data stored in mimic memory number %d in address %d is: %8h, Data read from subordinate %d is: %8h - FAILURE",sub_idx_s, addr_rand_s, {mem[sub_idx_s][addr_rand_s],mem[sub_idx_s][addr_rand_s+1],mem[sub_idx_s][addr_rand_s+2],mem[sub_idx_s][addr_rand_s+3]}, sub_idx_s,data_out_m);
      $timeformat(-9,2,"ns");
      $display("Time is %t", $realtime);
    //   $finish;
  end 
  endcase 
endtask

//Initiate transfer task : issues T consecutive transfers with randomized parameters (addr,size,width,etc.)
task automatic initiate_transfer ( input logic [MANAGER_COUNT-1:0] manager_index, input int T);    

    // local task variables
    logic [2:0] burst_type;                                          //Supported burst types: Single, WRAP4, INCR4, WRAP8, INCR8, WRAP16 and INCR16
    logic [4:0] burst_len;                                           //Indicates the burst length: 1,4,8 or 16. 
    logic [3:0] beat_counter;                                        //Indicates the location within a certain burst
    logic [2:0] addr_delta;                                          //Indicates the width of the transfer: byte=1, half word=2, word=4. 
    logic [ADDR_WIDTH-1:0]  addr_uniformdistr;                               //Randomized register address prior to byte/half word/ word alighment
    logic [ADDR_WIDTH-1:0]  slave_prefix;                              //Randomizes subordinate address
    logic [ADDR_WIDTH-1:0]  addr_size_aligned;                              //Address for the transfer issued by Manager_0
    logic [ADDR_WIDTH-1:0]  addr_mimc;                              //addr_mimc mimics the internal logic within the manager which calculates the address
    logic rw_rand;                                                      //Dictates transfer direction. '1' for Manager-->Subordinate (write) and '0' for Subordinate-->Manager (read)
    logic [2:0] hburst_rand;                                            //Burst type
    logic [2:0] hsize_rand;
    logic [ADDR_WIDTH-1:0] haddr_rand;                                             //transfer size for Manager_0
    logic [DATA_WIDTH-1:0]  hwdata_rand;                              //Randomized data to be written by a Manager_0 to a Subordinate





    // DEBUG:
    // $timeformat(-9,2,"ns");
    // $display("Shtuz hachi shlemut, initiate transfer bgins.Time is %t", $realtime); 

    burst_len=1;                                                       //Initializaion of the burst length 
    beat_counter=0;                                                    //Initiatlization of the beat counter
    @(posedge clk)
    start_0=1'b1;                                                      //Transfer initiation is synchronized to positive clock edge
    @(posedge clk)

    for (int i=0; i<T; i++) begin

            if (beat_counter==(burst_len-1)) begin                             //Execute only on the last iteration of a burst - the manager's output buses will be updted on the first beat of the following transfer
                beat_counter='0;

                rw_rand=$dist_uniform(SEED,0,1);                                    //Randomize transfer command, i.e. read/write
                hsize_rand=$dist_uniform(SEED,0,2);                                 //Randomize transfer size
                burst_type= $dist_uniform(SEED,0,7);                             //Randomize burst type and length

                case (burst_type)
                    SINGLE: begin 
                        hburst_rand=SINGLE;
                        burst_len=1;
                    end 
                    WRAP4: begin
                        hburst_rand=WRAP4;
                        burst_len=4;
                    end
                    INCR4: begin
                        hburst_rand=INCR4;
                        burst_len=4;
                    end
                    WRAP8: begin
                        hburst_rand=WRAP8;
                        burst_len=8;
                    end
                    INCR8: begin 
                        hburst_rand=INCR8;
                        burst_len=8;
                    end
                    WRAP16: begin
                        hburst_rand=WRAP16;
                        burst_len=16;
                    end
                    INCR16: begin 
                        hburst_rand=INCR16;
                        burst_len=16;
                    end
                    default: begin 
                        hburst_rand=SINGLE;
                        burst_len=1;
                    end 
                    endcase

                    // DEBUG
                // $timeformat(-9,2,"ns");
                // $display("burst type is %d, rw_rand is %h, Time is %t", hburst_rand, rw_rand, $realtime);


                    addr_uniformdistr= $dist_uniform(SEED,0,MEMORY_DEPTH-1-16*4);                //Selecting a register to communicate with. NOTE: I have restricted accesses to memory locations are prone to overflow in a case of 16 beat trasnfers of 32-bit length each - I will add the required logic that will limit access based on the burst leng and hsize product someday :)  
                    case (hsize_rand)                                                        //Address must be alighed according to the transfer size
                        BYTE : begin
                        addr_size_aligned = addr_uniformdistr;
                        addr_delta=1; 
                        end
                        HALFWORD : begin 
                        addr_size_aligned = {addr_uniformdistr[ADDR_WIDTH-1:1],1'b0};
                        addr_delta=2; 
                        end
                        WORD : begin 
                        addr_size_aligned = {addr_uniformdistr[ADDR_WIDTH-1:2],2'b00};
                        addr_delta=4; 
                        end
                    endcase
                
                    slave_prefix = (SUBORDINATE_COUNT <= 1) ? 0 : $dist_uniform(SEED,0,SUBORDINATE_COUNT-1);                   //Selecting a subordinate to initiate a trasfer with   
                    haddr_rand = {slave_prefix[SUBORDINATE_SELECT_BITS-1:0],addr_size_aligned[REGISTER_SELECT_BITS-1:0]};
                    addr_mimc = addr_size_aligned;
            end 
            else 
                beat_counter=beat_counter+$bits(beat_counter)'(1);

            //Calculate address for the mimic memory write task
            if (beat_counter>0)
            if ((hburst_rand==INCR4)||(hburst_rand==INCR8)||(hburst_rand==INCR16))         //Incrementing bursts: INCR4, INCR8, INCR16
                addr_mimc= addr_mimc+$bits(addr_mimc)'(addr_delta);
            else if (hburst_rand==WRAP4)                                             //4-beat wrapping burst
                case (hsize_rand)
                    BYTE: begin 
                    addr_mimc[31:2]= addr_mimc[31:2];
                    addr_mimc[1:0]= addr_mimc[1:0]+2'd1;
                    end 

                    HALFWORD: begin
                    addr_mimc[31:3]= addr_mimc[31:3];
                        addr_mimc[2:0]=addr_mimc[2:0]+3'd2;
                        end

                    WORD: begin
                    addr_mimc[31:4]= addr_mimc[31:4];
                    addr_mimc[3:0]=addr_mimc[3:0]+4'd4;
                    end
                endcase   
            else if (hburst_rand==WRAP8)                                             //8-beat wrapping burst 
                case (hsize_rand)
                    BYTE: begin 
                    addr_mimc[31:3]= addr_mimc[31:3];
                    addr_mimc[2:0]= addr_mimc[2:0]+3'd1;
                    end 

                    HALFWORD: begin
                    addr_mimc[31:4]= addr_mimc[31:4];
                    addr_mimc[3:0]=addr_mimc[3:0]+4'd2;
                    end

                    WORD: begin
                    addr_mimc[31:5]= addr_mimc[31:5];
                    addr_mimc[4:0]=addr_mimc[4:0]+5'd4;
                    end
                endcase 	
            else if (hburst_rand==WRAP16)                                            //16-beat wrapping burst
                case (hsize_rand)
                    BYTE: begin 
                    addr_mimc[31:4]= addr_mimc[31:4];
                    addr_mimc[3:0]= addr_mimc[3:0]+4'd1;
                    end 

                    HALFWORD: begin
                    addr_mimc[31:5]= addr_mimc[31:5];
                    addr_mimc[4:0]=addr_mimc[4:0]+5'd2;
                    end

                    WORD: begin
                    addr_mimc[31:6]= addr_mimc[31:6];
                    addr_mimc[5:0]=addr_mimc[5:0]+6'd4;
                    end
                endcase

            
            if (rw_rand) begin 
                hwdata_rand= $dist_uniform(SEED,0,100000000);                        //Randomized write data for a 'write' transfer	
                fork                                                                 //Execute the 'write_to_mimic_task' which runs in the background
                write_to_mimic_task(manager_index, hsize_rand,slave_prefix,addr_mimc, hwdata_rand);
                join_none;
            end
            else begin
                fork
                compare_task(.hsize(hsize_rand), .manager_idx(manager_index), .sub_idx(slave_prefix), .addr_rand(addr_mimc), .wait_period(3));                               //Execute the 'compare_task' which runs in the background	
                //wait (start_0==1'b0);                                              //Terminate comparison operations when TB-generated 'start' signal falls to logic low - stop comparison tasks for the last iteration of the simulation, can also be solved with changing the loop dimensions for comparison
                join_none;
            end 

         rw_m[manager_index] = rw_rand;
         hburst_m[manager_index] = hburst_rand;
         hsize_m[manager_index] = hsize_rand;
         haddr_m [manager_index]= haddr_rand;
         hwdata_m[manager_index] = hwdata_rand;


        #1
        wait(hready_m[manager_index]);                                                                                  //Prevents from issueing new transfers while the bus is busy
        @(posedge clk);
    
    end
    start_0=1'b0;

endtask : initiate_transfer

//DUT instantiation
AHB_DUT #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .MEMORY_DEPTH(MEMORY_DEPTH), .SUBORDINATE_COUNT(SUBORDINATE_COUNT), .MANAGER_COUNT(MANAGER_COUNT), .WAIT_WRITE(WAIT_WRITE), .WAIT_READ(WAIT_READ)) d0(.i_hclk(clk),
                                                                                                                                                                       .i_hreset(rstn),
                                                                                                                                                                       .i_start_0(start_0),
                                                                                                                                                                       .i_hburst_tb(hburst_m),
                                                                                                                                                                       .i_haddr_tb(haddr_m),
                                                                                                                                                                       .i_hwrite_tb(rw_m),
                                                                                                                                                                       .i_hsize_tb(hsize_m),
                                                                                                                                                                       .i_hwdata_tb(hwdata_m),
                                                                                                                                                                       .o_hrdata_m(data_out_m),
                                                                                                                                                                       .o_hready_m(hready_m)
);

//Initial and Clock blocks:
    initial begin
        test_failed = 1'b0;
        rstn=1'b0;
        clk=1'b0;
        start_0=1'b0;
        mem='0;

        #CLK_PERIOD
        rstn=1'b1;
        #200

        initiate_transfer ( .manager_index(0), .T(5000) );

        #1000
        $display("\n -----------------------");
        
        if (!test_failed) $display("\n ALL tests have passed - Hallelujah!");
        else $display("\n At least one test failed");

        // $finish;
    end

    //Clock generation
    always
        begin
        #(CLK_PERIOD/2);
        clk=~clk;
    end
// End

endmodule