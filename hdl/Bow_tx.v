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
// PROJECT      :   Bow_tx
// PRODUCT      :   N/A
// FILE         :   Bow_tx.v
// AUTHOR       :   Vilan Jayawardene
// DESCRIPTION  :   bow_tx_tester
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
module Bow_tx (
  input 			presetn,
  input 			txclk,
  input 			fec_in,
  input 			aux_in,
  input 			psel,
  input 			penable,
  input 			pwrite,
  input 	[15:0]  pwdata,
  input 			rx_ready,									//comes from link layer, for link layer it comes from i2c protocol(link controller)
  
  output 	reg 	pclk,
  output 	reg 	[15:0] prdata,							//output data
  output 	reg 	fec_out=1'bz,
  output 	reg 	aux_out=1'bz,
  output 	reg 	pready=1'b0,
  output 	reg 	clk_pos,clk_neg
);
//---------------------------------------------------------------------------------------------------------------------
// Internal signals
//---------------------------------------------------------------------------------------------------------------------

	
  reg 		[0:15] 	mem [0:31];
  reg 		[0:31] 	fec_reg;
  reg 		[0:31] 	aux_reg;
  reg 		[2:0] 	idle = 3'd0;
  reg 		[2:0] 	setup = 3'd1;
  reg 		[2:0] 	access = 3'd2;
  reg 		[2:0] 	complete = 3'd3;
  reg 		[2:0] 	state = idle;
  reg 		[5:0] 	addr = 6'd0;
  reg 		[5:0] 	addrx = 0;
  reg 		[5:0] 	count = 0;
  reg 		[5:0] 	count1 = 0;
  reg 				mem_full = 0;
  reg 		[2:0] 	clkd = 3'b000;
  reg 		[2:0] 	pstate;
  wire 		[15:0] 	lfsr_out;
  reg 				sent_to_rx,sent_to_rx_enable;
  reg 				preset_flag=0;
  reg 				preset_flag_flag=0;
  
  lfsr lfsr_for_bow(
	  .clk(txclk),
	  .reset_n(presetn),
	  .y(lfsr_out)
  );
/---------------------------------------------------------------------------------------------------------------------
// Implementation
//---------------------------------------------------------------------------------------------------------------------
  initial begin
 	clk_pos		=	1'b1;
 	clk_neg		=	1'b0;
 	prdata		=	16'd0;
	count		<=	1'b0;
	count1		<= 	1'b0;
	sent_to_rx	<=	1'b0;
  end
  
  always @(posedge txclk,negedge txclk)begin
  	clk_pos		<=~		clk_pos;
  	clk_neg		<=~		clk_neg;
  end
  
  always @(posedge txclk)begin 						// clk divider for pclk
    clkd		<=		clkd+1'b1;
    pclk		<=		clkd[1];
  end
  
  always @(posedge txclk) begin 						// ps ns logic
   	if(presetn == 1'b0) begin
       pstate	<=		idle;
	   count	<=		1'b0;
	    count1	<=		1'b0;
       preset_flag <= 	1'b1;
	end else begin
       pstate <= state;
       if(preset_flag_flag == 1'b1) begin
       	preset_flag 	<=	 1'b0;
       end
	end
  end
  
  
	
  always @(posedge pclk) begin
	if (presetn == 1'b0) begin 						// active low
  		state 	<= 	idle;
  		pready 	<= 	1'b0;
      	for (int i = 0; i < 32; i++) begin 			//initialize full memory to 0
    		mem[i]	 <=	 0;
  		end
	end
	else begin
  	case (state)
  		idle: begin
    		pready 	<= 	1'b0;							//ready is zero as it is in idle
          	sent_to_rx_enable	<=	1'b0;
			for (int i = 0; i < 32; i++) begin		//initialize full memory to 0
    			mem[i] 	<= 	0;
  			end
    		if ((psel == 1'b0) && (penable == 1'b0)) begin
      			state <= setup;
    		end
  		end

  		setup: begin								// if any cases where ready should go low
    		if ((psel == 1'b1) && (penable == 1'b0)) begin
        		state 		<= 	access;
        		pready 		<= 	1'b0;
          		mem_full 	<= 	1'b0;
    		end else begin
      			state 		<= 	setup;
    		end
  		end

  		access: begin
          	if (psel && pwrite && penable && count== 1'b0) begin	//for writing data onto internal registers
          		mem[addr] <= pwdata;
          		fec_reg[addr] 	<= 	fec_in;
          		aux_reg[addr] 	<= 	aux_in;
        		addr<=addr+6'd1;
        		if(addr[5]==0) begin
    				state 		<= 	access;
    				pready	 	<= 	1'b1;
       			end else begin
        			pready 		<= 	1'b0;
        			state 		<= 	complete;
        			mem_full 	<= 	1'b1;
        			addr 		<= 	0;
					count1		<= 	1'b1;
       			end
    		end
    		else begin
    			state 			<= 	access;
    		end
  		end
      
    	complete: begin
          	if(sent_to_rx==1) begin
        		sent_to_rx_enable<=1'b1;
        		state	<=	setup;
          	end else begin
          		state	<=	complete;
          	end
     	end

     
  		default: state 	<= 	idle;
  	endcase
	end
  end

////////////////lfsr


	always @(posedge clk_pos or posedge clk_neg) begin //prbs generation
	  if(rx_ready==0)begin
	  	addrx<=0;
	  	if(preset_flag==1'b1 && presetn == 1'b1) begin
  			prdata	 <= 	lfsr_out;
  			preset_flag_flag	=	1'b0;
  		end
  		else begin
  			prdata <= 16'hzzzz;
  		end
	  end
	  else if(rx_ready==1) begin // only if rx ready is 1 transmission should start
	  	
		preset_flag_flag=1'b1;
	  	if(mem_full == 1'b1) begin
       	  	if(addrx[5]==0 && count== 1'b0) begin
            	prdata		<=		mem[addrx];
            	fec_out		<=		fec_reg[addrx];
            	aux_out		<=		aux_reg[addrx];
              	addrx		<=		addrx+6'd1;
				//$display("hello");
          	end else begin
            	prdata		<=		16'hzzzz;
            	fec_out		<=		32'hzzzzz;
            	aux_out		<=		32'hzzzzz;
              	sent_to_rx 	<= 		1'b1;
            	addrx		<=		0;
				count		<=		1;
      		end
      	end
      	else begin
      		prdata	<=	16'hzzzz;
			addrx	<=	0;
      	end
        if(sent_to_rx_enable==1'b1)begin
          sent_to_rx	<=	0;
        end
	  end
	end
	
	always @(negedge pready) begin
		prdata 	<= 	16'h7FFE;
	end
	
endmodule
