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
// PROJECT      :   Bow_test
// PRODUCT      :   N/A
// FILE         :   Bow_test.v
// AUTHOR       :   Vilan Jayawardene
// DESCRIPTION  :   bow_test
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

module Bow_test (
  input 			presetn,
  output 	reg 	txclk,

  input 			fec_in,
  input 			aux_in,
  input 			psel,
  input 			penable,
  input 			pwrite,
  input 			[15:0]  pwdata,
  input 			rx_ready,									//comes from link layer, for link layer it comes from i2c protocol(link controller)
  
  output 	reg 	pclk,
  output 	reg 	[15:0] prdata,							//output data
  output 			fec_out,
  output 			aux_out,
  output 	reg 	pready,
  output 	reg 	clk_pos,clk_neg
);
//---------------------------------------------------------------------------------------------------------------------
// Internal signals
//---------------------------------------------------------------------------------------------------------------------
 
  Bow_tx dut(
	  .pclk(pclk),
	  .presetn(presetn),
	  .psel(psel),
	  .penable(penable),
	  .pwrite(pwrite),
	  .pwdata(pwdata),
	  .prdata(prdata),
	  .pready(pready),
	  .txclk(txclk),
	  .fec_in(fec_in),
	  .aux_in(aux_in),
	  .rx_ready(rx_ready),
	  .clk_pos(clk_pos),
	  .clk_neg(clk_neg),
	  .fec_out(fec_out),
	  .aux_out(aux_out)
  );
//---------------------------------------------------------------------------------------------------------------------
// Implementation
//---------------------------------------------------------------------------------------------------------------------
  initial begin
	  $dumpfile("bow.vcd");
	  $dumpvars;
	  txclk	=	0;
	  forever begin
		  #5 txclk	=~	txclk;
	  end
  end
  endmodule
