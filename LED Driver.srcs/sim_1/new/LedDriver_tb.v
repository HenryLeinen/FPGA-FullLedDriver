`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.09.2016 16:52:26
// Design Name: 
// Module Name: LedDriver_tb
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


module LedDriver_tb(
    );

    reg clk50;
    reg rst_n;
    
    reg [23:0]  rd_data_upper, rd_data_lower;
    
    LedDriver   DUT (
        .clk50(clk50),
        .rst_n(rst_n),
        
        .rd_addr(rd_addr),
        .rd_data_upper(rd_data_upper),
        .rd_data_lower(rd_data_lower),
        
        .A(A),
        .RED(RED),
        .GREEN(GREEN),
        .BLUE(BLUE),
        .LE(LE),
        .OE_N(OE_N),
        .CLK(CLK),
        
        .v_sync(v_sync)
    );

    initial begin
        clk50 = 0;
        forever #20 clk50 = ~clk50;      
    end
    
    initial begin
        rst_n = 0;
        repeat (2) @(posedge clk50);
        rd_data_upper = 24'b000000010000001000000001;
        rd_data_lower = 24'b000000100000000100000010;
        rst_n = 1;
    end
endmodule
