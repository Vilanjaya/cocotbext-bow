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
// PROJECT      :   lfsr_test
// PRODUCT      :   N/A
// FILE         :   lfsr_test.v
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

module lfsr_test (
  
  input 			reset_n,
  output 	[1:16] 	y
  output 	reg 	clk,
);
//---------------------------------------------------------------------------------------------------------------------
// Internal signals
//---------------------------------------------------------------------------------------------------------------------
 
  lfsr lfsr(
	  .clk(clk),
	  .reset_n(reset_n),
	  .y(y)
  );
//---------------------------------------------------------------------------------------------------------------------
// Implementation
//---------------------------------------------------------------------------------------------------------------------
  initial begin
	  $dumpfile("lfsr_test.vcd");
	  $dumpvars;
	  clk	=	0;
	  forever begin
		  #5 clk	=~	clk;
	  end
  end
endmodule
