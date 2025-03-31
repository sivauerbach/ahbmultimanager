module arbiter #(parameter MANAGERS = 4) (
    input logic clk,
    input logic [MANAGERS-1:0] requestV, // one-hot vector representing the requests of the manager (bit_0-> manager_0)
    output logic [MANAGERS-1:0] grantedV // vector of zeros with the granted manager's bit set high
    //output logic [MANAGERS-1:0] grantedID // integer representing the granted manager's ID (between [0, MANAGERS-1])
);
    logic [$clog2(WIDTH)-1:0] grantID;      // integer representing the granted manager's ID (between [0, MANAGERS-1])
    logic [$clog2(WIDTH)-1:0] prevgrantID;  // integer representing the previous ID granted (between [0, MANAGERS-1])
    logic [MANAGERS-1:0] rotatedLeft;
    logic [MANAGERS-1:0] priority_vector;
    logic [MANAGERS-1:0] rotatedRight;

    always_comb @ (posedge clk) begin // CHECK, always, always_ff
        prevgrantID <= grantedID //CHECK: use nonblocking?
    end

    rotator rLeft #(MANAGERS) (.X(requestV), .Right(1'b0), .Amt(prevgrantID), .Y(rotatedLeft));

    reversearbiter findPriority #(MANAGERS) (.X(rotatedLeft), .Y(priority_vector));

    rotator rRight #(MANAGERS) (.X(priority_vector), .Right(1'b1), .Amt(prevgrantID), .Y(rotatedRight));

    priorityencoder encode #(MANAGERS) (.onehot(rotatedRight), .Y(grantedID));

    assign grantedV = rotatedRight;

endmodule