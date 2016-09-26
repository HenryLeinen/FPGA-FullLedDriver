`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.09.2016 21:47:51
// Design Name: 
// Module Name: FillMemory
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: This module will fill the memory with the given data word. Filling will start with a negative edge of
//              the CS_N signal. As soon as the filling process completes, the done signl will go high.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FillMemory(
    input clk,
    input cs_n,
    output reg done,
    output  [10:0] wr_addr,
    output reg [23:0] wr_data,
    output reg wr_ena,
    input [23:0] fill_color
    );
    
    reg    [5:0]    col;
    reg    [4:0]    row;
    
    localparam  SET_ADDR = 2'b00,
                SET_ENA = 2'b01,
                DONE = 2'b11;
                
    reg [1:0] state;
    
    assign wr_addr = {col,row};    
    
    always @(posedge clk or negedge cs_n) begin
        if (cs_n) begin
            done <= 1'bz;
            wr_data <= 23'bz;
            wr_ena <= 1'b0;
            col <= 0;
            row <= 0;
            state <= SET_ENA;
        end else begin
            case (state)
                SET_ADDR:
                    begin
                        wr_ena <= 0;
                        state <= SET_ENA;                             
                        if (col == 63) begin
                            if (row == 31) begin
                                done <= 1'b1;
                                state <= DONE;
                            end else begin
                                col <= 0;
                                row = row + 1;
                            end
                        end else begin
                            col = col + 1;
                        end                    
                    end
                    
                SET_ENA:
                    begin
                        wr_ena <= 1;
                        state <= SET_ADDR;
                    end

                DONE:
                    begin
                        wr_data = 23'bz;
                        wr_ena = 1'b0;
                    end                    
                default:
                    begin
                        wr_data <= fill_color;
                        done <= 1'b0;
                    end
            endcase            
        end
    end
    
endmodule
