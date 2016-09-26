`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.09.2016 23:42:31
// Design Name: 
// Module Name: pll_tb
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


module pll_tb(
    );
    
    reg clk;
    wire clk100, clk50, clk20;
    
    pll pll (
        .clkin(clk),
        .clk100(clk100),
        .clk50(clk50),
        .clk20(clk20)
   );
   
   initial begin
        clk = 0;
        forever #5 clk = ~clk;
   end
endmodule
