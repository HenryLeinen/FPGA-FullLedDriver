`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.09.2016 00:43:59
// Design Name: 
// Module Name: spi
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


module spi #(parameter MODE=2'b0, MSBFIRST=0) (
    input wire clk,                     
    input wire SCLK,                    //  Only works with sclk being of smaller frequency than clk
    input wire MOSI,
    output wire MISO,
    input wire SS,
    input wire [7:0] tx,
    output reg [7:0] rx,
    
    output reg  new_data
    );
    
    localparam M0 = 2'b00,           //  Clock Idle Polarity low, Shift on first edge (Low->High)
               M1 = 2'b01,           //  Clock Idle Polarity low, Shift on second edge (High->Low)
               M2 = 2'b10,           //  Clock Idle Polarity high, Shift on first edge (High->Low)
               M3 = 2'b11;           //  Clock Idle Polarity high, Shift on second edge (Low-->High)
        
    localparam  PosEdge = 3'b001,
                NegEdge = 3'b110;
        
    reg [3:0]   count;                  //  Counts the number of bits shifted
    reg [2:0]   edge_detect;            //  Edge detector for the SCLK signal
    reg [1:0]   edge_detect_SS;         //  Edge detector for the SS signal
    
    reg         edge_count;             //  If 1, this indicates the second edge
    reg [7:0]   ltx;                    //  Local copy of tx (we want to avoid that tx changes while we are sending)    
    reg [7:0]   lrx;                    //  Local copy of rx
    
    wire        miso_bit;
    wire        miso_bit_msb = ltx[3'b111-count];
    wire        miso_bit_lsb = ltx[count];
    assign miso_bit =  (MSBFIRST ? miso_bit_msb : miso_bit_lsb);
    
    assign MISO = (SS == 0) ? 1'bz : miso_bit;

    always @(*) begin
        if (new_data)  ltx <= tx;
    end
    
    always @(posedge clk) begin
        //  Detect a positive edge of SS and reset control signals in this case
        edge_detect_SS <= {edge_detect_SS[0],SS};
    end    
    
    always @(posedge new_data) begin
        rx <= lrx;
    end
    
    always @(posedge clk) begin
    
        if (edge_detect_SS == PosEdge[1:0]) begin
            new_data <= 1'b0;           
            count <= 3'b0;
            edge_detect = {SCLK, SCLK, SCLK};
            edge_count <= 0;
        end else begin
            if (edge_detect_SS == 2'b11) begin                   //  We just react in case we are addressed by a solid SS high level
                edge_detect = {edge_detect[1:0], SCLK}; //  Perform edge debouncing
                
                new_data <= 0;
                if ((edge_detect == PosEdge) || (edge_detect == NegEdge)) begin 
                
                    case (MODE)
                        M0:
                            begin
                                if (edge_detect == PosEdge) begin
                                    //  take over new RX data
                                    if (MSBFIRST == 1) begin
                                        lrx <= {lrx[6:0],MOSI};
                                    end else begin
                                        lrx <= {MOSI, lrx[7:1]};
                                    end
                                end else begin
                                    //  Push out new TX data
                                    if (count == 3'b111) begin
                                        new_data <= 1'b1;
                                        count <= 3'b0;
                                    end else count <= count + 3'b001;
                                end
                            end
                        
                        M1:
                            begin
                                if (edge_detect == NegEdge) begin
                                    //  take over new RX data
                                    edge_count <= 1'b1;
                                    if (MSBFIRST == 1) begin
                                        lrx <= {lrx[6:0],MOSI};
                                    end else begin
                                        lrx <= {MOSI, lrx[7:1]};
                                    end
                                    if (count == 3'b111) begin
                                        new_data <= 1'b1;
                                        edge_count <= 1'b0;
                                    end
                                end else begin
                                    //  is this the second transition ?
                                    if (edge_count == 1'b1) begin
                                        //  Push out new TX data
                                        count <= count + 3'b001;
                                    end else if (count == 3'b111) begin
                                        count <= 0;
                                    end
                                end
                            end
                            
                        M2:
                            begin
                                if (edge_detect == NegEdge) begin
                                    //  take over new RX data
                                    if (MSBFIRST == 1) begin
                                        lrx <= {lrx[6:0],MOSI};
                                    end else begin
                                        lrx <= {MOSI, lrx[7:1]};
                                    end
                                end else begin
                                    //  Push out new TX data
                                    if (count == 3'b111) begin
                                        new_data <= 1'b1;
                                        count <= 3'b0;
                                    end else count <= count + 3'b001;
                                end
                            end
                            
                        M3:
                            begin
                                if (edge_detect == PosEdge) begin
                                    //  take over new RX data
                                    edge_count <= 1'b1;
                                    if (MSBFIRST == 1) begin
                                        lrx <= {lrx[6:0],MOSI};
                                    end else begin
                                        lrx <= {MOSI, lrx[7:1]};
                                    end
                                    if (count == 3'b111) begin
                                        new_data <= 1'b1;
                                        edge_count <= 1'b0;
                                    end
                                end else begin
                                    if (edge_count == 1'b1) begin
                                            //  Push out new TX data
                                            count <= count + 3'b001;
                                    end else if (count == 3'b111) begin
                                        count <= 3'b0;
                                    end
                                end
                            end
                    endcase
                end
                            
            end
        end
    end
    
endmodule
