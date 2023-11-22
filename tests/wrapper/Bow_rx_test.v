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
// PROJECT      :   Bow_rx_test
// PRODUCT      :   N/A
// FILE         :   Bow_rx_test.v
// AUTHOR       :   Vilan Jayawardene
// DESCRIPTION  :   bow_rx_tester
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

module Bow_rx_test(
    input 				fec_in,//bow
    input 				aux_in,//bow
    input 	[15:0] 		prdata,//bow

    output 	reg 		clk_pos,//bow
    output 	reg 		clk_neg,//bow
    input 				presetn,// link layer // it shoulld be output all four
    output 	reg 		pready, //apb ready pin should be input ig
    output 	reg 		psel,//link layer
    output 	reg 		penable,//link layer
    output 				pwrite,// link layer
    output 	reg[15:0] 	data_link,
    output 	reg 		fec_link,
    output 	reg 		aux_link,
    output 	reg 		rx_ready,// this should be input from link layer
    output 	reg 		pclk//divided clk
);
//---------------------------------------------------------------------------------------------------------------------
// Internal signals
//---------------------------------------------------------------------------------------------------------------------


  Bow_rx dut(
	  .pclk(pclk),//
	  .presetn(presetn),//
	  .psel(psel),//
	  .penable(penable),//
	  .pwrite(pwrite),//
	  .data_link(data_link),//
	  .prdata(prdata),//
	  .pready(pready),//
	  .fec_link(fec_link),//
	  .aux_link(aux_link),//
	  .clk_pos(clk_pos),//
	  .rx_ready(rx_ready),//
	  .clk_neg(clk_neg),//
	  .fec_in(fec_in),//
	  .aux_in(aux_in)//
  );
//---------------------------------------------------------------------------------------------------------------------
// Implementation
//---------------------------------------------------------------------------------------------------------------------
  initial begin
	  $dumpfile("bow_rx.vcd");
	  $dumpvars;
	  clk_pos	=	0;
	  clk_neg	=	1;
	  forever begin
		  #5 clk_pos	=~	clk_pos;
		     clk_neg	=~	clk_neg;
	  end
  end
endmodule



  