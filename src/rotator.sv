///////////////////////////////////////////
// rotator.sv
//
// Written: sivanauerbach@gmail.com 18 April 2025
// Modified: 
//
// Purpose: Rotating bit shifter. Can be any width.
// 
// A component of the Wally configurable RISC-V project.
// 
// Copyright (C) 2025 Harvey Mudd College & Oklahoma State University
//
// MIT LICENSE
// Permission is hereby granted, free of charge, to any person obtaining a copy of this 
// software and associated documentation files (the "Software"), to deal in the Software 
// without restriction, including without limitation the rights to use, copy, modify, merge, 
// publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons 
// to whom the Software is furnished to do so, subject to the following conditions:
//
//   The above copyright notice and this permission notice shall be included in all copies or 
//   substantial portions of the Software.
//
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
//   INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
//   PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS 
//   BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
//   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE 
//   OR OTHER DEALINGS IN THE SOFTWARE.
////////////////////////////////////////////////////////////////////////////////////////////////

module rotator #(parameter WIDTH = 4) (
  input logic [WIDTH-1:0] X,
  input logic RightFlag,
  input logic [$clog2(WIDTH)-1:0] Amt,
  output logic [WIDTH-1:0] Y
);
  always_comb begin
    if (Amt == 0) Y = X;
    else begin
      case (RightFlag)
        1'b1:  Y = (X << (WIDTH - Amt)) | (X >> Amt) ; // rotate right
        1'b0:  Y = (X << Amt) | (X >> (WIDTH - Amt)) ; // rotate left
      endcase
    end
  end
endmodule // rotator


//Example: Left rotate by 2:
// abcd_efgh ---<<2---------- cdef_gh00
// abcd_efgh --->>6 =(8-2)--- 0000_00ab
// OR ------------------------cdef_ghab -> rotated left by 2
