module arbiter #(parameter MANAGERS = 4) (
    input logic enable,
    input logic [MANAGERS-1:0] requestV, // one-hot vector representing the requests of the manager (bit_0-> manager_0)
    output logic [MANAGERS-1:0] grantedV // vector of zeros with the granted manager's bit set high
    //output logic [MANAGERS-1:0] grantedID // integer representing the granted manager's ID (between [0, MANAGERS-1])
);
    logic [$clog2(MANAGERS)-1:0] grantedID;      // integer representing the granted manager's ID (between [0, MANAGERS-1])
    logic [$clog2(MANAGERS)-1:0] nextgrantID;  // integer representing the previous ID granted (between [0, MANAGERS-1])
    logic [MANAGERS-1:0] rotatedRight;
    logic [MANAGERS-1:0] priority_vector;
    logic [MANAGERS-1:0] rotatedLeft;

    initial nextgrantID = 0;
    always @ (posedge enable) begin // CHECK, always, always_ff, CHECK: use only enable or on posedge clk { if(en)}
        if (grantedID == MANAGERS-1) nextgrantID <= 0;
        else if (requestV == '0)
            nextgrantID <= nextgrantID;
        else 
            nextgrantID <= grantedID + 1; //CHECK: use nonblocking?
        
        grantedV <= rotatedLeft;
    end

    rotator  #(MANAGERS) rRight(.X(requestV), .RightFlag(1'b1), .Amt(nextgrantID), .Y(rotatedRight));

    fixedpriority #(MANAGERS) findPriority (.X(rotatedRight), .Y(priority_vector));

    rotator #(MANAGERS) rLeft (.X(priority_vector), .RightFlag(1'b0), .Amt(nextgrantID), .Y(rotatedLeft));
    
    onehotdecoder #(MANAGERS) encode (.onehot(rotatedLeft), .decodedint(grantedID));

    

endmodule
//CHECK: should prevGrant be given as input? how to initialize prevGrant
