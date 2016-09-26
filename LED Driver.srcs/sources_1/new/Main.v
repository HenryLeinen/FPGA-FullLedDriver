`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.09.2016 14:30:17
// Design Name: 
// Module Name: Main
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Main(
    input clk,
    input rst_n,
    output LED_CLK,
    output OE_N,
    output LE,
    output [1:0] RED,
    output [1:0] GREEN,
    output [1:0] BLUE,
    output [3:0] A,
    
    input   SS,
    input   MOSI,
    input   SCLK,
    output   MISO
    );

    wire    [23:0]      rd_data_upper, rd_data_lower;
    wire    [15:0]      wr_data;
    
    wire     [9:0]      rd_addr;
    wire    [15:0]      wr_addr;
    wire                wr_ena;
    
    wire                clk100, clk50, clk20;

    //  Here are the local registers
    //  addr0 :         ForeGroundColor
    //  addr1 :         BackGroundColor
    //  addr2 :         CommandRegister
    reg     [7:0]       LocalRegs[3:0];
    
    pll     pll(
        .clkin(clk),
        .clk100(clk100),
        .clk50(clk50),
        .clk20(clk20)
    );    

    dpram   dpram(
        .clk100(clk100),
        .rst_n(rst_n),
        .backbuffer(backbuffer),
        
        .rd_addr_front_buffer(rd_addr),
        .rd_data_front_buffer_upper(rd_data_upper),
        .rd_data_front_buffer_lower(rd_data_lower),
        
        .addr_b(wr_addr[10:0]),
        .data_b(wr_data),
        .wr_ena(wr_ena)
    );
    
    BackBufferHandler BackBufferHandler (
        .rst_n(rst_n),
        .backbuffer_out(backbuffer),
        .v_sync(v_sync),
        .switch_req(switch_reg)
    );
    
`include "gamma_LUT.vh"

    //  Instantiate the LedDriver block
    LedDriver LedDriver(
        .clk50(clk50),
        .rst_n(rst_n),
        .rd_addr(rd_addr),
        .rd_data_upper({gamma_LUT(rd_data_upper[14:10]), gamma_LUT(rd_data_upper[9:5]), gamma_LUT(rd_data_upper[4:0])}),
        .rd_data_lower({gamma_LUT(rd_data_lower[14:10]), gamma_LUT(rd_data_lower[9:5]), gamma_LUT(rd_data_lower[4:0])}),
        .A(A),
        .RED(RED),
        .GREEN(GREEN),
        .BLUE(BLUE),
        .LE(LE),
        .OE_N(OE_N),
        .CLK(LED_CLK),
        .v_sync(v_sync)
    );
    
    spi_handler spi_handler (
        .clk(clk50),
        .rst_n(rst_n),
        
        .SS(SS),
        .SCLK(SCLK),
        .MOSI(MOSI),
        .MISO(MISO),
        
        .RegAddr(),
        .RegData(),
        .RegWE(),
        
        .MemAddr(wr_addr),
        .MemData(wr_data),
        .MemWE(wr_ena)
    );
endmodule
