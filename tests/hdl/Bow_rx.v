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
// PROJECT      :   Bow_rx
// PRODUCT      :   N/A
// FILE         :   Bow_rx.v
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

module Bow_rx(
    input           fec_in,//bow
    input           aux_in,//bow
    input   [15:0]  prdata,//bow
    input           clk_pos,//bow
    input           clk_neg,//bow
    input           presetn,// link layer // it shoulld be output all four

    output  reg     pready, //apb ready pin should be input ig
    output  reg     psel,//link layer
    output  reg     penable,//link layer
    output  reg     pwrite,// link layer
    output  reg     [15:0] data_link,
    output  reg     fec_link,
    output  reg     aux_link,
    output  reg     rx_ready,// this should be input from link layer
    output  reg     pclk//divided clk
);

//---------------------------------------------------------------------------------------------------------------------
// Internal signals
//---------------------------------------------------------------------------------------------------------------------


    // Clock Divider and LFSR
    reg     [2:0]       clkd = 3'b000;
    wire    [15:0]      lfsr_out;

    // State Machine
    reg     [2:0]       pstate;
    reg     [2:0]       state = 3'd0;
    reg     [2:0]       idle = 3'd0;
    reg     [2:0]       setup = 3'd1;
    reg     [2:0]       access = 3'd2;
    reg     [2:0]       complete = 3'd3;

    // Memory and Addressing
    reg     [0:1]       fec_reg [0:31];
    reg     [0:1]       aux_reg [31:0];
    reg     [0:15]      mem [0:31];
    reg     [5:0]       addr = 6'd0;
    reg                 mem_full = 0;
    reg     [5:0]       count = 0;

    // Counters and Flags
    integer             j = 0;
    integer             i = 0;

//---------------------------------------------------------------------------------------------------------------------
// Implementation
//---------------------------------------------------------------------------------------------------------------------
    initial begin
        psel        =       0;
        penable     =       0;
        pwrite      =       0;
        data_link   =       0;
        fec_link    =       0;
        aux_link    =       0;
        rx_ready    =       0;
        count       =       0;
        pready      =       0;
        // pready_rx=0;
    end
    always @ (posedge clk_pos or posedge clk_neg) begin
        // pclk_rx <= clk_pos;
        // pready_rx <= pready;
    end
    // Clock Divider
    always @(posedge clk_pos) begin
        clkd     <=     clkd + 1'b1;
        pclk    <=      clkd[1];
    end

    // Linear Feedback Shift Register (LFSR)
    lfsr lfsr_for_bow_rx(
        .clk(clk_pos),
        .reset_n(presetn),
        .y(lfsr_out)
    );

    // State Machine Logic
    always @(posedge clk_pos) begin
        if (presetn == 1'b0)
            pstate  <=      setup;
        else
            pstate  <=      state;
    end

    // Access and Control Logic
    always @(posedge pclk) begin
        if (presetn == 1'b0 && psel == 1'b0) begin
            state   <=  idle;
            for (i = 0; i < 32; i = i + 1) begin
                mem[i]      <=      0;
                fec_reg[i]  <=      0;
                aux_reg[i]  <=      0;
            end
        end else if (psel == 1'b1) begin
            case (state)
                setup: begin
                    if (psel == 1'b1) begin
                        penable     <=  1'b1;
                        state       <= access;
                        pready      <= 1'b0;
                        mem_full    <= 1'b0;
                    end else begin
                        state       <= setup;
                    end
                end
                access: begin
                    if (addr < 6'd32) begin
                        pwrite      <= 1'b1;
                        data_link   <= mem[addr];
                        fec_link    <= fec_reg[addr];
                        aux_link    <= aux_reg[addr];
                        addr        <= addr + 6'd1;
                        state       <= access;
                    end else begin
                        pwrite      <= 1'b0;
                        state       <= setup;
                        addr        <= 0;
                        psel        <= 0;
                    end
                end
                default: state      <= setup;
            endcase
        end
    end
//---------------------------------------------------------------------------------------------------------------------
// Internal signals
//---------------------------------------------------------------------------------------------------------------------

    // State Machine Control
    reg     [1:0]   ps, ns;
    reg     [1:0]   idle1 = 2'd0;
    reg     [1:0]   setup1 = 2'd1;
    reg     [1:0]   dat_capture = 2'd2;
    integer         k = 0;
    reg             start = 1'b0;

    //---------------------------------------------------------------------------------------------------------------------
    // Implementation
    //---------------------------------------------------------------------------------------------------------------------
    always @ (posedge clk_pos or posedge clk_neg) begin
        if (presetn == 1'b0)
            ps  <=  idle1;
        else
            ps  <=  ns;
    end

    // State Transitions
    always @ (posedge clk_pos or posedge clk_neg) begin
        case (ps)
            idle1: begin
                if (presetn == 1'b0)
                    ns  <=  idle1;
                    
                else
                    ns      <=  setup1;
                    k       <=  1'b0;
                    count   <=  0;
            end
            setup1: begin
                if (k < 8) begin
                    k       <=  k + 1;
                    ns      <=  setup1;
                end else begin
                    ns      <=  dat_capture;
                end
            end
            dat_capture: begin
                if (prdata != 16'h7FFE && start == 1'b0) begin
                    ns          <=  dat_capture;
                    rx_ready    <=  1'b1;
                end else if (prdata == 16'h7FFE && start == 1'b0) begin
                    start       <=  1;
                    $display("prdata: %d", prdata);
                    ns <= dat_capture;
                end else if (start == 1 && j < 32 && count ==0) begin
                    mem[j]     <=   prdata;
                    fec_reg[j] <=   fec_in;
                    aux_reg[j] <=   aux_in;
                    j          <=  j + 1;
                    ns <= dat_capture;
                end else if (j == 32) begin
                    j          <=   0;
                    k          <=   0;
                    start      <=   0;
                    psel       <=   1'b1;
                    rx_ready   <=   1'b0;
                    ns         <=   idle1;
                    count      <=   1;
                end
            end
            default: begin
                ns             <=  idle1;
            end
        endcase
    end

endmodule
