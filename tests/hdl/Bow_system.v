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
// PROJECT      :   Bow_system
// PRODUCT      :   N/A
// FILE         :   Bow_sysytem.v
// AUTHOR       :   Vilan Jayawardene
// DESCRIPTION  :   bow_system_tester
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
module Bow_system(
    input           presetn,
    input           txclk,
    input           fec_in,
    input           aux_in,
    input           psel_tx,
    input           penable_tx,
    input           pwrite_tx,
    input   [15:0]  pwdata_tx,

    output  reg     pclk_tx,
    output  reg     pready_rx, //apb ready pin should be input ig
    output  reg     psel_rx,//link layer
    output  reg     penable_rx,//link layer
    output  reg     pwrite_rx,// link layer
    output  reg     [15:0] data_link,
    output  reg     fec_link,
    output  reg     aux_link,
    output  reg     pclk_rx,//divided clk
    output  reg     [15:0]prdata
    );
//---------------------------------------------------------------------------------------------------------------------
// Internal signals
//---------------------------------------------------------------------------------------------------------------------

//wire pclk_tx;

    wire     fec_out;
    wire    aux_out;
    wire    pready_tx;
    wire    clk_pos;
    wire    clk_neg;

    wire rx_ready;


    Bow_tx transmitter(presetn,
                    txclk,
                    fec_in,
                    aux_in,
                    psel_tx,
                    penable_tx,
                    pwrite_tx,
                    pwdata_tx,
                    rx_ready,
                    pclk_tx,
                    prdata,
                    fec_out,a
                    ux_out,
                    pready_tx,
                    clk_pos,
                    clk_neg
        );

    Bow_rx receiver(fec_out,
                    aux_out,
                    prdata,
                    clk_pos,
                    clk_neg,
                    presetn,
                    pready_rx,
                    psel_rx,
                    penable_rx,
                    pwrite_rx,
                    data_link,
                    fec_link,
                    aux_link,
                    rx_ready,
                    pclk
        );

endmodule