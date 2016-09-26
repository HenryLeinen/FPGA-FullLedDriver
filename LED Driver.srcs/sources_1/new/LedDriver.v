`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     Henry Leinen 
// Engineer:    Henry Leinen
// 
// Create Date: 11.09.2016 14:30:17
// Design Name: LedDriver
// Module Name: LedDriver
// Project Name: LED Driver
// Target Devices: XILINX Artix 7, Spartan 6
// Tool Versions: Vivado 2916.2
// Description: This module drives 2 cascaded 32x32 RGB LED Panels. Refresh Frequency is close to 100Hz. Data resides in an external memory.
//              
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module LedDriver(
    input               clk50,
    input               rst_n,
    output wire  [9:0]  rd_addr,
    input  wire [23:0]  rd_data_upper,
    input  wire [23:0]  rd_data_lower,
    output reg   [3:0]  A,
    output wire  [1:0]  RED,
    output wire  [1:0]  GREEN,
    output wire  [1:0]  BLUE,
    output reg          LE,
    output reg          OE_N,
    output reg          CLK,
    output reg          v_sync              //  This serves as an internal signal which indicates that a full frame has been completed --> shall be used to exchange front and back buffer memory
    );
    
//////
//  Registers to store the current row and current column
    reg     [3:0]       row;                //  The display is organised into two separate 16 line display, which will be displayed simultaneously. 
    reg     [5:0]       col;                //  We need to address all of the 64 pixels individually
    reg     [2:0]       bitplane;           //  Address each bitplane 7..0 individually
    
    reg     [14:0]      bitplane_timer;     //  This bitplane_timer keeps track of the on time for each bitplane. If it expires, the LEDs will be switched off and the proceesing is advanced to the next bitplane or row
    

///////
//  Wires to construct the actual address in memory
    assign              rd_addr     = { row, col };    //  Address for external memory is coded
    
    assign              RED[0]      = rd_data_upper[bitplane];
    assign              RED[1]      = rd_data_lower[bitplane];
    assign              GREEN[0]    = rd_data_upper[bitplane + 8];
    assign              GREEN[1]    = rd_data_lower[bitplane + 8];
    assign              BLUE[0]     = rd_data_upper[bitplane + 16];
    assign              BLUE[1]     = rd_data_lower[bitplane + 16];
    
///////
//  State variable
    localparam          WAIT        = 3'b000,
                        LATCH       = 3'b001,
                        START       = 3'b010,
                        SET_COLOR   = 3'b011,
                        CLOCK_OUT   = 3'b100;
    reg [3:0]           state;                  //  The state variable

    function [14:0] getTimer ;
         input [2:0] plane;
        case (plane)
            3'b000: getTimer = 14'd8186;
            3'b001: getTimer = 14'd58;
            3'b010: getTimer = 14'd122;
            3'b011: getTimer = 14'd250;
            3'b100: getTimer = 14'd506;
            3'b101: getTimer = 14'd1018;
            3'b110: getTimer = 14'd2042;
            3'b111: getTimer = 14'd4090;
        endcase
    endfunction
       
  
    // Set LED Clock only high during SET_COLOR state     
    always @(*) begin
        if (state == CLOCK_OUT) CLK <= 1;
            else CLK <= 0;
    end
    
    //  Set Latch Enable to high only if state = START
    always @(*) begin
        if (state == START) LE <= 1'b1;
            else LE <= 1'b0;
    end
        
    always @(posedge clk50 or negedge rst_n) begin
        if (!rst_n) begin
            //  Reset processing
            row <= 4'b0;
            col <= 6'b0;
            bitplane <= 2'b0;
//            bitplane_timer <= 14'd0;        // Initial bitplane timer for bitplane 0 is 128 - 4 clocks overhead (LE, OE, etc)
            A <= 3'b0;
//            LE <= 0;
            OE_N <= 1;
            state <= SET_COLOR;                   // Start 
        end else begin
            //  Regular function processing
            v_sync <= 0;

            if (bitplane_timer != 14'b0) begin
                //  if bitplane timer is expired, switch off LEDs by activating OE_N
                bitplane_timer <= bitplane_timer - 14'b1;
            end else OE_N <= 1'b1;  //  Timer expired so switch off the LEDs.
                        
            case (state)
                WAIT: 
                    begin
                        //  Just wait until the timer expired, then we can move into the next state
                        if (bitplane_timer == 14'b0) state <= LATCH;
                    end
                    
                LATCH:
                    begin
                        A[3:0] <= row[3:0];           //  Set the current row as row selector (do this before we modify the row register)
  //                      LE <= 1;            //  Latch the previously shifted data, this will put it into the buffers
                        //  Now either switch to new bitplane, or if all bitplanes have been shown already, 
                        //  switch to new row, so that the next data will be shown. If all rows have been shown
                        if (bitplane == 3'h7) begin
                            //  All bitplanes have been shown, so we need to reset to 0 and goto next row
                            bitplane = 3'b000;
                            if (row == 4'b1111) begin
                                //  All rows shown, goto row 0 and bitplane 0
                                row <= 4'b0;
                                v_sync <= 1'b1;              //  Indicate the vertical sync, because we start with the next frame
                            end else row = row + 4'b0001;
                        end else bitplane = bitplane + 3'b001;                 
                        col <= 6'b0;
                        state <= START;
                    end
                    
                START:
                    begin
    //                    LE <= 0;
                        OE_N <= 0;          //  Activate the outputs, so that the data becomes visible
                        // Start new timer. The timer length depends on the bitplane. Need to consider, that the bitplane to use
                        // is already advanced by one
                        bitplane_timer <= getTimer(bitplane);
                        state <= SET_COLOR;
                    end
                    
                SET_COLOR:
                    begin
                        state <= CLOCK_OUT;
//                        CLK <= 1;
                    end
                    
                CLOCK_OUT:
                    begin
//                        CLK <= 0;
                        if (col == 6'd63) begin
                            col = 6'b0;
                            state <= WAIT;
                        end else begin
                            col = col + 6'b00001;
                            state <= SET_COLOR;
                        end
                    end
                
                default:
                    begin
                    end
            endcase
        end
    end
endmodule
