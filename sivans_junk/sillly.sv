// always @(posedge i_pclk or negedge i_prstn)
// if (!i_prstn) begin
//     o_paddr<='0;
//     o_pwrite<='0;
//     o_psel<='0;
//     o_penable<='0;
//     o_pwdata<='0;
//     o_prdata<='0; 
//     o_pready<=1'b0;
//     o_pslverr<=1'b0;
// end
// else begin
//     case (o_gnt)
//     3'b001:                                                    //Master 0 has won the arbitration
//         if ((end_of_transfer==1'b1)&&(|request_vec)) begin       //If a transfer has ended (pready=1'b1) and there are masters that lost the arbitration. Generate a single logic-low penable to comply with APB protocol.
//             o_paddr<=i_paddr_m0;
//             o_pwrite<=i_pwrite_m0;
//             o_psel<=i_psel_m0;
//             o_penable<=1'b0;
//             o_pwdata<=i_pwdata_m0;  

//             case (i_psel_m0)
//             3'b001: begin
//             o_prdata<=i_prdata_s0;
//             o_pready<=i_pready_s0;
//             o_pslverr<=i_pslverr_s0;	
//             end
//             ///// other slaves
//         endcase

//         end
//         else begin
//         o_paddr<=i_paddr_m0;
//         o_pwrite<=i_pwrite_m0;
//         o_psel<=i_psel_m0;
//         o_penable<=i_penable_m0;
//         o_pwdata<=i_pwdata_m0; 

//         case (i_psel_m0)
//         3'b001: begin
//             o_prdata<=i_prdata_s0;
//             o_pready<=i_pready_s0;
//             o_pslverr<=i_pslverr_s0;	
//         end
//             ///// other slaves

//         endcase
//     end

//     3'b010:                                               //Master 1 has won the arbitration
//         if ((end_of_transfer==1'b1)&&(|request_vec)) begin  //If a transfer has ended (pready=1'b1) and there are masters that lost the arbitration. Generate a single logic-low penable to comply with APB protocol.
//             o_paddr<=i_paddr_m1;
//             o_pwrite<=i_pwrite_m1;
//             o_psel<=i_psel_m1;
//             o_penable<=1'b0;
//             o_pwdata<=i_pwdata_m1;  

//             case (i_psel_m1)
//             3'b001: begin
//             o_prdata<=i_prdata_s0;
//             o_pready<=i_pready_s0;
//             o_pslverr<=i_pslverr_s0;	
//             end
//         ///// other slaves

//         endcase
//     end 
    
//         else begin
//         o_paddr<=i_paddr_m1;
//         o_pwrite<=i_pwrite_m1;
//         o_psel<=i_psel_m1;
//         o_penable<=i_penable_m1;
//         o_pwdata<=i_pwdata_m1; 

//         case (i_psel_m1)
//         3'b001: begin
//             o_prdata<=i_prdata_s0;
//             o_pready<=i_pready_s0;
//             o_pslverr<=i_pslverr_s0;	
//         end
//         ///// other slaves

//         endcase
//         end

//     3'b100:                                                 //Master 2 has won the arbitration
//         if ((end_of_transfer==1'b1)&&(|request_vec)) begin    //If a transfer has ended (pready=1'b1) and there are masters that lost the arbitration. Generate a single logic-low penable to comply with APB protocol.
//             o_paddr<=i_paddr_m2;
//             o_pwrite<=i_pwrite_m2;
//             o_psel<=i_psel_m2;
//             o_penable<=1'b0;
//             o_pwdata<=i_pwdata_m2;  

//         case (i_psel_m2)
//         3'b001: begin
//             o_prdata<=i_prdata_s0;
//             o_pready<=i_pready_s0;
//             o_pslverr<=i_pslverr_s0;	
//         end
//         ///// other slaves

//         endcase
//         end 
//         else begin
//         o_paddr<=i_paddr_m2;
//         o_pwrite<=i_pwrite_m2;
//         o_psel<=i_psel_m2;
//         o_penable<=i_penable_m2;
//         o_pwdata<=i_pwdata_m2;

//         case (i_psel_m2)
//         3'b001: begin
//             o_prdata<=i_prdata_s0;
//             o_pready<=i_pready_s0;
//             o_pslverr<=i_pslverr_s0;	
//         end
//         ///// other slaves

//         endcase
//         end

//     endcase
//   end
