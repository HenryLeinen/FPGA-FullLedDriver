`timescale 10ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.09.2016 17:44:37
// Design Name: 
// Module Name: BackBufferHandler
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


module BackBufferHandler(
    input  wire     rst_n,
    output reg      backbuffer_out,
    input  wire     v_sync,
    input  wire     switch_req,
    output reg      clr_switch_req
    );
            
    always @(negedge rst_n or posedge v_sync ) begin
        if (!rst_n) backbuffer_out <= 1'b0;
            else if (v_sync && switch_req) backbuffer_out <= ~backbuffer_out;
    end
    
    always @(negedge rst_n or posedge v_sync or negedge v_sync ) begin
        if (!rst_n) clr_switch_req <= 1'b0;
            else if (v_sync && switch_req) clr_switch_req <= 1'b1;
                else clr_switch_req <= 1'b0;
    end
endmodule
