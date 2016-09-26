`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.09.2016 22:59:44
// Design Name: 
// Module Name: spi_handler
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


module spi_handler(
    input   wire             clk,
    input   wire             rst_n,
    
    input   wire             SS,
    input   wire             SCLK,
    input   wire             MOSI,
    output  wire             MISO,
    
    output  reg  [7:0]       RegAddr,
    inout   wire [7:0]       RegData,
    output  reg              RegWE,
    output  reg [15:0]       MemAddr,
    output  reg [23:0]       MemData,
    output  reg              MemWE
    );
    
    wire                     new_data_available;
    wire [7:0]               rx;
    reg  [7:0]               tx;
    
    reg  [7:0]               regInput;
    
    assign RegData = RegWE ? rx : 8'bz;             //  Only wire the RegData to rx if the Write enable signal is being set
    
    localparam  CmdIdle         = 5'b00000,
                CmdWriteRegister= 5'b00001,       //  Write into internal register
                CmdReadRegister = 5'b00010,       //  Read from internal register
                CmdWriteMemory  = 5'b00011,       //  Write into memory
                CmdReadMemory   = 5'b00100,
                
                CmdWriteRegister1 = 5'b01001,       //  WriteRegister Sub state 1
                CmdWriteRegister2 = 5'b10001,       //  WriteRegister Sub state 2
                CmdWriteRegister3 = 5'b11001,       //  WriteRegister Sub state 3
                
                CmdReadRegister1 = 5'b01010,        //  ReadRegister Sub state 1
                CmdReadRegister2 = 5'b10010,        //  ReadRegister Sub state 2
                CmdReadRegister3 = 5'b11010;        //  ReadRegister Sub state 3
                               
    //  SPI low level driver                
    spi #(.MODE(2'b0), .MSBFIRST(1'b1)) spi(
        .clk(clk),
        .SCLK(SS),
        .MISO(MISO),
        .MOSI(MOSI),
        .SS(SS),
        .new_data(new_data_available),
        .tx(tx),
        .rx(rx)
    );
    
    localparam  POSITIVE_EDGE   = 2'b01,        //  Positive edge detected
                NEGATOVE_EDGE   = 2'b10;        //  Negative edge detected
                    
    reg [1:0]       dta_rdy;
    
    reg [4:0]       state;
    reg             addr_recvd;
        
    //  Detect the availability of a new data byte
    //  The vector dta_rdy is the edge detector.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) dta_rdy <= 2'b00;
        else dta_rdy <= {dta_rdy[0],new_data_available};
    end
        
    //  Process the new SPI data
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= CmdIdle;
        else begin
            if (dta_rdy == POSITIVE_EDGE) begin     //  new data transition detected
                case (state)
                    //  CmdIdle is the state in which the FSM resides when the communication was terminated.
                    //  When a new data byte is received, FSM checks what the command in this first data byee
                    //  is and will switch into the requested mode.
                    CmdIdle: 
                        begin
                            addr_recvd <= 1'b0;
                            case (rx[2:0])
                                CmdWriteRegister: state <= CmdWriteRegister;                                
                                CmdReadRegister:  state <= CmdReadRegister;                                
                                CmdWriteMemory:   state <= CmdWriteMemory;                                
                                CmdReadMemory:    state <= CmdReadMemory;
                            endcase
                        end
                       
                    //  FSM received the command to write into the local register, so we expect to receive the
                    //  Register number for writing. FSM will change into the substates where the data bytes for
                    //  the register will be received.
                    CmdWriteRegister: 
                        begin
                            RegAddr = rx;
                            state <= CmdWriteRegister1;
                        end 
                        
                    //  When a data byte has been received FSM will initiate the write cycle. It does that by
                    //  putting the databyte on the output and changing into another substate which will toggle
                    //  the write enable signal.
                    CmdWriteRegister1:
                        begin
                            RegWE <= 1'b1;                  //  rx will automatically be wired to RegData when RegWE is enabled
                            state <= CmdWriteRegister2;
                        end
                        
                    //  FSM recevied the command to read from the local register, so we expect to receive the
                    //  Register number for reading. FSM will change into the substates where the data bytes for
                    //  the register will be transmitted
                    CmdReadRegister:
                        begin
                            RegAddr = rx;
                            tx <= RegData;
                            state <= CmdReadRegister1;
                        end
                        
                    CmdReadRegister1:
                        begin
                            RegAddr = RegAddr + 8'b00000001;        //  Proceed with next register address
                            tx <= RegData;
                        end
                endcase
            end else begin
                case (state)
                    //  Will increment the address so a potential next data byte will be written to the next register
                    CmdWriteRegister2:
                        begin
                            state <= CmdWriteRegister1;
                            RegWE <= 1'b0;
                            RegAddr = RegAddr + 8'b00000001;       //  Proceed with next register address
                        end
                endcase
            end
        end
    end

endmodule
