`timescale 1ns/1ps

//`define CPOLL

module spi_basic_tb (
                    );
        
        
    task SendM0;
        input [7:0] tx;
        begin
            SCLK = 0;
            MOSI = tx[7];
            #50 SCLK = 1;
            #50 SCLK = 0;
            MOSI = tx[6];
            #50 SCLK = 1;
            #50 SCLK = 0;
            MOSI = tx[5];
            #50 SCLK = 1;
            #50 SCLK = 0;
            MOSI = tx[4];
            #50 SCLK = 1;
            #50 SCLK = 0;
            MOSI = tx[3];
            #50 SCLK = 1;
            #50 SCLK = 0;
            MOSI = tx[2];
            #50 SCLK = 1;
            #50 SCLK = 0;
            MOSI = tx[1];
            #50 SCLK = 1;
            #50 SCLK = 0;
            MOSI = tx[0];
            #50 SCLK = 1;
            #50 SCLK = 0;
        end
    endtask

    task SendM1;
        input [7:0] tx;
        
        begin
            SCLK = 0;
            #50 SCLK = 1;
            MOSI = tx[7];
            #50 SCLK = 0;
            #50 SCLK = 1;
            MOSI = tx[6];
            #50 SCLK = 0;
            #50 SCLK = 1;
            MOSI = tx[5];
            #50 SCLK = 0;
            #50 SCLK = 1;
            MOSI = tx[4];
            #50 SCLK = 0;
            #50 SCLK = 1;
            MOSI = tx[3];
            #50 SCLK = 0;
            #50 SCLK = 1;
            MOSI = tx[2];
            #50 SCLK = 0;
            #50 SCLK = 1;
            MOSI = tx[1];
            #50 SCLK = 0;
            #50 SCLK = 1;
            MOSI = tx[0];
            #50 SCLK = 0;
        end
    endtask


    task SendM2;
        input [7:0] tx;
        
        begin
            SCLK = 1;
            MOSI = tx[7];
            #50 SCLK = 0;
            #50 SCLK = 1;
            MOSI = tx[6];
            #50 SCLK = 0;
            #50 SCLK = 1;
            MOSI = tx[5];
            #50 SCLK = 0;
            #50 SCLK = 1;
            MOSI = tx[4];
            #50 SCLK = 0;
            #50 SCLK = 1;
            MOSI = tx[3];
            #50 SCLK = 0;
            #50 SCLK = 1;
            MOSI = tx[2];
            #50 SCLK = 0;
            #50 SCLK = 1;
            MOSI = tx[1];
            #50 SCLK = 0;
            #50 SCLK = 1;
            MOSI = tx[0];
            #50 SCLK = 0;
            #50 SCLK = 1;
        end
    endtask

    task SendM3;
        input [7:0] tx;
        
        begin
            #50 SCLK = 1;
            #50 SCLK = 0;
            MOSI = tx[7];
            #50 SCLK = 1;
            #50 SCLK = 0;
            MOSI = tx[6];
            #50 SCLK = 1;
            #50 SCLK = 0;
            MOSI = tx[5];
            #50 SCLK = 1;
            #50 SCLK = 0;
            MOSI = tx[4];
            #50 SCLK = 1;
            #50 SCLK = 0;
            MOSI = tx[3];
            #50 SCLK = 1;
            #50 SCLK = 0;
            MOSI = tx[2];
            #50 SCLK = 1;
            #50 SCLK = 0;
            MOSI = tx[1];
            #50 SCLK = 1;
            #50 SCLK = 0;
            MOSI = tx[0];
            #50 SCLK = 1;
        end
    endtask
        
    reg clk, MOSI, SS, SCLK;
    reg [7:0] tx;
    wire MISO, new_data;
    wire [7:0] rx;
                    
    spi #(
        .MODE({1'b1/*CPOL*/,1'b0/*CPHA*/}),
        .MSBFIRST(1'b1)
    )   DUT (
        .clk(clk),
        .SCLK(SCLK),
        .MOSI(MOSI),
        .MISO(MISO),
        .SS(SS),
        
        .tx(tx),
        .rx(rx),
        
        .new_data(new_data)
    );
    
    initial begin
        SS = 0;
        clk = 0;
`ifdef CPOLL
        SCLK = 0;
`else
        SCLK = 1;
`endif
        tx = 8'b00000001;
        forever #5 begin clk = ~clk; tx = tx + 1; end
    end
    
    initial begin
        MOSI = 0;
        #50 SS = 1;
        SendM2(8'h96);
        SendM2(8'haa);
        SendM2(8'h55);
        #50 SS = 0;
        #50 SCLK = ~SCLK;
        #50 SCLK = ~SCLK;
        #50 SCLK = ~SCLK;
        #50 SCLK = ~SCLK;
        #50 SCLK = ~SCLK;
        #50 SCLK = ~SCLK;
        #50 SCLK = ~SCLK;
        #50 SCLK = ~SCLK;
        #50 SCLK = ~SCLK;
        #50 SCLK = ~SCLK;
        $finish;
    end
endmodule
