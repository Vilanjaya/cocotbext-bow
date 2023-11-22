// ************************************************************************************************
//
// Copyright(C) 2023 PRIVATE
// All rights reserved.
//
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE.
//
// This copy of the Source Code is intended for internal use only and is
// intended for view by persons duly authorized. No
// part of this file may be reproduced or distributed in any form or by any
// means without written approval.
//
// Private Use Only
// No contact information provided
//
// ************************************************************************************************
//
// PROJECT      :   lfsr
// PRODUCT      :   N/A
// FILE         :   lfsr.v
// AUTHOR       :   Vilan Jayawardene
// DESCRIPTION  :   lfsr_tester
//
// ************************************************************************************************
//
// REVISIONS:
//
//  Date            Developer     Description
//  -----------     ---------     -----------
//  09-Nov-2023      vilan         creation
//
//**************************************************************************************************
`timescale 1ns / 1ps
module lfsr#(parameter N=16)(
  input   clk,
  input   reset_n,
  output  reg [1:N] y
);
//---------------------------------------------------------------------------------------------------------------------
// Internal signals
//---------------------------------------------------------------------------------------------------------------------

reg       [1:N]   yreg='d1;
reg       [1:N]   xreg='d1;

initial begin
y='d1;
end
//---------------------------------------------------------------------------------------------------------------------
// Implementation
//---------------------------------------------------------------------------------------------------------------------
  always @(posedge clk,negedge clk,negedge reset_n)
    begin
      if(~reset_n) begin
        xreg=y;
        yreg={y[16]^y[15]^y[13]^y[4],y[1:N-1]};
        if (toggle_count(yreg,xreg) > 7) begin
      		y = ~yreg;
    	end else begin
    		y   = yreg;
    	end
      end
      else begin
      	xreg=y;
        yreg={y[16]^y[15]^y[13]^y[4],y[1:N-1]};
        if (toggle_count(yreg,xreg) > 7) begin
      		y = ~yreg;
    	end else begin
    		y   = yreg;
    	end
      end
    end

  function integer toggle_count(input reg [1:N] y,input reg [1:N] x);
    integer i, count;
    count = 0;
    for (i=0; i<N; i=i+1) begin
      if (x[i]^y[i]) count = count + 1;
    end
    return count;
  endfunction

endmodule



